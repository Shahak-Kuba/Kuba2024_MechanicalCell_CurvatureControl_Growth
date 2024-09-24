"""
    Growth_ODE!(du, u, p, t)

Define the ODE system for 2D mechanical relaxation with initial conditions. This function computes the derivatives `du` based on the current state `u` and parameters `p`.

# Arguments
- `du`: Array to store the derivatives of `u`.
- `u`: Current position array of all spring boundary nodes.
- `p`: Parameters tuple `(N, kₛ, η, kf, l₀, δt, growth_dir)`.
- `t`: Current time.

# Description
Calculates the mechanical relaxation and normal velocity in a 1D system with periodic boundary conditions. The derivatives are based on spring forces and mechanical properties defined in `p`.
"""
function Growth_ODE!(du,u,p,t) 
    m,kₛ,η,kf,l₀,δt,growth_dir,domain_type,btype = p
    uᵢ₊₁ = circshift(u',1)
    uᵢ₋₁ = circshift(u',-1)

    if domain_type == "2D"
        du .= ((1/η) .* diag((Fₛ⁺(u',uᵢ₊₁,uᵢ₋₁,kₛ,l₀) + Fₛ⁻(u',uᵢ₊₁,uᵢ₋₁,kₛ,l₀)) * transpose(τ(uᵢ₊₁,uᵢ₋₁))).*τ(uᵢ₊₁,uᵢ₋₁) +
                       Vₙ(uᵢ₋₁,u',uᵢ₊₁,kf,δt,growth_dir))'
    else
        if btype == "InvertedBellCurve"
            dom = 1500; # For Bell curve
        else
            dom = 2*pi; # FOR Cosine SineWave
        end
        uᵢ₋₁[end,:] = uᵢ₋₁[end,:]+[dom;0]
        uᵢ₊₁[1,:] = uᵢ₊₁[1,:]-[dom;0]
        du .= ((1/η) .* diag((Fₛ⁺(u',uᵢ₊₁,uᵢ₋₁,kₛ,l₀) + Fₛ⁻(u',uᵢ₊₁,uᵢ₋₁,kₛ,l₀)) * transpose(τ(uᵢ₊₁,uᵢ₋₁))).*τ(uᵢ₊₁,uᵢ₋₁) +
                            Vₙ(uᵢ₋₁,u',uᵢ₊₁,kf,δt,growth_dir))'
    end
    nothing
end

"""
    Growth_ODE!(du, u, p, t)

Define the ODE system for 2D mechanical relaxation with initial conditions. This function computes the derivatives `du` based on the current state `u` and parameters `p`.

# Arguments
- `du`: Array to store the derivatives of `u`.
- `u`: Current position array of all spring boundary nodes.
- `p`: Parameters tuple `(N, kₛ, η, kf, l₀, δt, growth_dir)`.
- `t`: Current time.

# Description
Calculates the mechanical relaxation and normal velocity in a 1D system with periodic boundary conditions. The derivatives are based on spring forces and mechanical properties defined in `p`.
"""
function Growth_ODE2!(du,u,p,t) 
    m,kₛ,η,kf,l₀,δt,growth_dir,domain_type,btype,restoring_force = p
    uᵢ₊₁ = circshift(u',1)
    uᵢ₋₁ = circshift(u',-1)

    if domain_type == "2D"
        du .= ((1/η) .* diag((Fₛ⁺(u',uᵢ₊₁,uᵢ₋₁,kₛ,l₀,restoring_force) + Fₛ⁻(u',uᵢ₊₁,uᵢ₋₁,kₛ,l₀,restoring_force)) * transpose(τ(uᵢ₊₁,uᵢ₋₁))).*τ(uᵢ₊₁,uᵢ₋₁) +
                       Vₙ(uᵢ₋₁,u',uᵢ₊₁,kf,δt,growth_dir))'
        # Below is unstable normal vlocity
         #du .= ((1/η) .* diag((Fₛ⁺(u',uᵢ₊₁,uᵢ₋₁,kₛ,l₀,restoring_force) + Fₛ⁻(u',uᵢ₊₁,uᵢ₋₁,kₛ,l₀,restoring_force)) * transpose(τ(uᵢ₊₁,uᵢ₋₁))).*τ(uᵢ₊₁,uᵢ₋₁) +
        #                Vₙ(uᵢ₋₁, u', uᵢ₊₁, kf,"inward"))'
    else
        if btype == "InvertedBellCurve"
            dom = 1500; # For Bell curve
        else
            dom = 2*pi; # FOR Cosine SineWave
        end
        uᵢ₋₁[end,:] = uᵢ₋₁[end,:]+[dom;0]
        uᵢ₊₁[1,:] = uᵢ₊₁[1,:]-[dom;0]
        du .= ((1/η) .* diag((Fₛ⁺(u',uᵢ₊₁,uᵢ₋₁,kₛ,l₀,restoring_force) + Fₛ⁻(u',uᵢ₊₁,uᵢ₋₁,kₛ,l₀,restoring_force)) * transpose(τ(uᵢ₊₁,uᵢ₋₁))).*τ(uᵢ₊₁,uᵢ₋₁) +
                            Vₙ(uᵢ₋₁,u',uᵢ₊₁,kf,δt,growth_dir))'
    end
    nothing
end


# Callback for stopping at a density limit ρ_lim
density_lim_affect!(integrator) = terminate!(integrator)

function density_lim_condition(u,t,integrator)
    (m,kₛ,η,kf,l₀,δt,growth_dir,domain_type,btype,prolif,death,embed,α,β,γ,q_lim) = integrator.p
    q = calc_cell_densities(u,m)
    flag = sum(q .> q_lim)
    return flag > 0.0 ? true : false
end