module TopOptProblems

using JuAFEM, StaticArrays, LinearAlgebra
using SparseArrays, Setfield, CuArrays
using CUDAnative
using ..GPUUtils
using CUDAdrv: CUDAdrv
#using Makie
#using GeometryTypes

import JuAFEM: assemble!
import ..GPUUtils: whichdevice

abstract type AbstractTopOptProblem end

const dev = CUDAdrv.device()
const ctx = CUDAdrv.CuContext(dev)

include("grids.jl")
include("metadata.jl")
include("problem_types.jl")
include("matrices_and_vectors.jl")
include("penalties.jl")
include("assemble.jl")
include(joinpath("IO", "IO.jl"))
using .IO
#include("makie.jl")

export PointLoadCantilever, HalfMBB, LBeam, TieBeam, InpStiffness, StiffnessTopOptProblem, AbstractTopOptProblem, GlobalFEAInfo, ElementFEAInfo, YoungsModulus, assemble, assemble_f!, RaggedArray, ElementMatrix, rawmatrix, bcmatrix

end # module
