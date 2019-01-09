abstract type SolverResult end
abstract type SolverType end
abstract type SolverSubtype end

struct Displacement <: SolverResult end

struct Direct <: SolverType end
struct CG  <: SolverType end

struct MatrixFree <: SolverSubtype end
struct Assembly <: SolverSubtype end

Utilities.getpenalty(solver::AbstractFEASolver) = solver.penalty
function Utilities.setpenalty!(solver::AbstractFEASolver, p)
    solver.prev_penalty = solver.penalty
    penalty = solver.penalty
    solver.penalty = @set penalty.p = p
    solver
end
Utilities.getprevpenalty(solver::AbstractFEASolver) = solver.prev_penalty

function FEASolver(::Type{Displacement}, ::Type{Direct}, problem::StiffnessTopOptProblem{dim, T}; 
    xmin=T(1)/1000, 
    penalty=PowerPenalty{T}(1), 
    quad_order=default_quad_order(problem)) where {dim, T}

    return DirectDisplacementSolver(problem, 
        xmin=xmin, 
        penalty=penalty, 
        quad_order=quad_order)
end

function FEASolver(::Type{Displacement}, ::Type{CG}, problem; kwargs...)
    FEASolver(Displacement, CG, MatrixFree, problem; kwargs...)
end

function FEASolver(::Type{Displacement}, ::Type{CG}, ::Type{MatrixFree}, problem::StiffnessTopOptProblem{dim, T}; 
    xmin=T(1)/1000, 
    cg_max_iter=700, 
    tol=xmin, 
    penalty=PowerPenalty{T}(1), 
    preconditioner=identity, 
    quad_order=default_quad_order(problem)) where {dim, T}

    return StaticMatrixFreeDisplacementSolver(problem, 
        xmin=xmin, 
        cg_max_iter=cg_max_iter, 
        tol=tol, 
        penalty=penalty, 
        preconditioner=preconditioner, 
        quad_order=quad_order) 
end

function FEASolver(::Type{Displacement}, ::Type{CG}, ::Type{Assembly}, problem::StiffnessTopOptProblem{dim, T}; 
    xmin=T(1)/1000, 
    cg_max_iter=700, 
    tol=xmin, 
    penalty=PowerPenalty{T}(1), 
    preconditioner=identity, 
    quad_order=default_quad_order(problem)) where {dim, T}

    return PCGDisplacementSolver(problem,
        xmin=xmin, 
        cg_max_iter=cg_max_iter, 
        tol=tol, 
        penalty=penalty, 
        preconditioner=preconditioner, 
        quad_order=quad_order)
end

default_quad_order(problem) = TopOptProblems.getgeomorder(problem) == 2 ? 6 : 4