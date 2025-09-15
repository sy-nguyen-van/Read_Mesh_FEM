using LinearAlgebra
# ====================
push!(LOAD_PATH, "Mesh_Files")
include("AbaqusReadJulia.jl")
path = "Mesh_Files/"
# ================= Example Usage =================
file_name = path * "Vframe3d_Size_2_0.inp"
model = AbaqusReadJulia(file_name)

# Access
ind_nodes = sort(collect(keys(model["nodes"])))
nnodes    = length(ind_nodes)
ndim      = length(first(values(model["nodes"])))
FE_coords = hcat([model["nodes"][nid] for nid in ind_nodes]...)  # 3 × n_nodes

elem_ids     = sort(collect(keys(model["elements"])))
nelem        = length(elem_ids)
nen          = length(model["elements"][1][2])
FE_elem_node = hcat([model["elements"][eid][2] for eid in elem_ids]...)
FE_elem_type = Symbol.((getindex.(values(model["elements"]), 1)))


