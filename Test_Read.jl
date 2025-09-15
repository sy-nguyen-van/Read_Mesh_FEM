using LinearAlgebra
using AbaqusReader
# ====================
push!(LOAD_PATH, "Mesh_Files")
include("read_inp_mesh.jl")
path = "Mesh_Files/"
# ================= Example Usage =================
file_name = path * "U_Shape_Size_4_0.inp"
model = read_inp_mesh(file_name)

# Access
ind_nodes = sort(collect(keys(model["nodes"])))
nnodes = length(ind_nodes)
ndim = length(first(values(model["nodes"])))
FE_coords = hcat([model["nodes"][nid] for nid in ind_nodes]...)  # 3 × n_nodes

elem_ids = sort(collect(keys(model["elements"])))
nelem = length(elem_ids)
nen = length(model["elements"][1][2])
FE_elem_node = hcat([model["elements"][eid][2] for eid in elem_ids]...)
FE_elem_type = Symbol.((getindex.(values(model["elements"]), 1)))

dim = FE_elem_type[1] in (:CPS3, :CPS4) ? 2 : 3

# NonDesign=  model["elem_sets"]["NonDesign"]
# DirichletBC = model["node_sets"]["DirichletBC"]
# NeumannBC = model["node_sets"]["NeumannBC"]
# RollersBC = model["node_sets"]["RollersBC"]

model["elem_sets"]["NonDesign"]



