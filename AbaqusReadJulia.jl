"""
Read nodes, elements (with types), and node sets from an Abaqus .inp file.

Returns:
    Dict with:
      "nodes"       => Dict(node_id => [x,y,z])
      "elements"    => Dict(elem_id => (etype, [node_ids...]))
      "node_sets"   => Dict("SETNAME" => [node_ids])
"""
function AbaqusReadJulia(file_path::String)
    nodes = Dict{Int, Vector{Float64}}()
    elements = Dict{Int, Tuple{String, Vector{Int}}}()  # elem_id => (etype, connectivity)
    node_sets = Dict{String, Vector{Int}}()

    current_section = nothing
    current_set_key = nothing
    current_elem_type = nothing

    open(file_path, "r") do io
        for line in eachline(io)
            line = strip(line)

            # Skip empty lines or comments
            if isempty(line) || startswith(line, "**")
                continue
            end

            # Section headers
            if startswith(uppercase(line), "*NODE")
                current_section = :nodes
                continue

            elseif startswith(uppercase(line), "*ELEMENT")
                # Example: *Element, type=C3D4
                m = match(r"(?i)type\s*=\s*([A-Za-z0-9_]+)", line)
                current_elem_type = m === nothing ? "UNKNOWN" : m.captures[1]
                current_section = :elements
                continue

            elseif startswith(uppercase(line), "*NSET")
                m = match(r"(?i)nset\s*=\s*([A-Za-z0-9_]+)", line)
                setname = m === nothing ? "UNKNOWN" : m.captures[1]
                m2 = match(r"(?i)instance\s*=\s*([A-Za-z0-9_\-]+)", line)
                instname = m2 === nothing ? "" : m2.captures[1]
                current_set_key = instname == "" ? setname : "$(setname)"
                node_sets[current_set_key] = Int[]
                current_section = :nset
                continue

            elseif startswith(line, "*")
                current_section = nothing
                current_set_key = nothing
                continue
            end

            # Parse data
            if current_section == :nodes
                parts = split(line, ',')
                try
                    node_id = parse(Int, strip(parts[1]))
                    coords = parse.(Float64, strip.(parts[2:end]))
                    push!(nodes, node_id => coords)
                catch
                    continue
                end

            elseif current_section == :elements
                parts = split(line, ',')
                try
                    elem_id = parse(Int, strip(parts[1]))
                    connectivity = parse.(Int, strip.(parts[2:end]))
                    push!(elements, elem_id => (current_elem_type, connectivity))
                catch
                    continue
                end

            elseif current_section == :nset && current_set_key !== nothing
                parts = split(line, ',')
                for p in parts
                    p = strip(p)
                    if !isempty(p)
                        push!(node_sets[current_set_key], parse(Int, p))
                    end
                end
            end
        end
    end

    return Dict(
        "nodes" => nodes,
        "elements" => elements,
        "node_sets" => node_sets,
    )
end

