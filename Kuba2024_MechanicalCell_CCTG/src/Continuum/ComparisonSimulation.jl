function ComparisonSim(N,m1,m2,R₀,D,l₀,kf,η,growth_dir,Tmax,δt,btype,dist_type, prolif, death, embed, α, β, γ, event_δt, seed, Av)
    ### Discrete Simulation
    
    # simulation with m1 cells
    sols2D_m1 = GrowthSimulation(N,m1,R₀,D,0,l₀,kf,η,growth_dir,"2D",Tmax,δt,[btype],"nonlinear2",dist_type,
    prolif, death, embed, α, β, γ, event_δt, seed, 11);

    # simulation with m2 cells
    sols2D_m2 = GrowthSimulation(N,m2,R₀,D,0,l₀,kf,η,growth_dir,"2D",Tmax,δt,[btype],"nonlinear2",dist_type,
    prolif, death, embed, α, β, γ, event_δt, seed, 11);


    ### Continuum Simulation
    ρ₀ = sols2D_m1[1].Density[1][1];

    #using FVM for low diffusivity and FD for mid-high diffusivity
    if D <= 1
        if D >= 0.005
            θ_cont,R_cont,ρ_cont = FD_SolveContinuumLim_Polar(D,kf,Av,ρ₀,Tmax,R₀,btype,growth_dir);
        else 
            θ_cont,R_cont,ρ_cont = FVM_SolveContinuumLim_Polar(D,kf,Av,ρ₀,Tmax,R₀,btype, growth_dir);
        end
    else
        if D >= 5
            θ_cont,R_cont,ρ_cont = FD_SolveContinuumLim_Polar(D,kf,Av,ρ₀,Tmax,R₀,btype,growth_dir);
        else 
            θ_cont,R_cont,ρ_cont = FVM_SolveContinuumLim_Polar(D,kf,Av,ρ₀,Tmax,R₀,btype, growth_dir);
        end
    end


    # plotting
    Discrete_Solution_m1 = sols2D_m1[1];
    Discrete_Solution_m2 = sols2D_m2[1];
    Continuum_Solution = (θ_cont,R_cont,ρ_cont);
    return Discrete_Solution_m1, Discrete_Solution_m2, Continuum_Solution
end

function ComparisonSim_Density(N,m,R₀,D_array,l₀,kf,η,growth_dir,Tmax,δt,btype,dist_type, prolif, death, embed, α, β, γ, event_δt, seed, Av)
    Discrete_Solution = [];
    Continuum_Solution = [];

    for D in D_array
   
        ### Discrete Simulation
        
        # simulation with m1 cells
        sol_Discrete = GrowthSimulation(N,m,R₀,D,0,l₀,kf,η,growth_dir,"2D",Tmax,δt,[btype],"nonlinear",dist_type,
        prolif, death, embed, α, β, γ, event_δt, seed, 11);

        ### Continuum Simulation
        ρ₀ = sol_Discrete[1].Density[1][1];

        #using FVM for low diffusivity and FD for mid-high diffusivity
        #if D <= 1
        #    if D >= 0.005
        #        θ_cont,R_cont,ρ_cont = TissueGrowth.FD_SolveContinuumLim_Polar(D,kf,Av,ρ₀,Tmax,R₀,btype,growth_dir);
        #    else 
        #        θ_cont,R_cont,ρ_cont = TissueGrowth.FVM_SolveContinuumLim_Polar(D,kf,Av,ρ₀,Tmax,R₀,btype, growth_dir);
        #    end
        #else
            if D >= 5
                θ_cont,R_cont,ρ_cont = FD_SolveContinuumLim_Polar(D,kf,Av,ρ₀,Tmax,R₀,btype,growth_dir);
            else 
                θ_cont,R_cont,ρ_cont = FVM_SolveContinuumLim_Polar(D,kf,Av,ρ₀,Tmax,R₀,btype, growth_dir);
            end
        #end


        # plotting
        push!(Discrete_Solution, sol_Discrete[1]);
        push!(Continuum_Solution,(θ_cont,R_cont,ρ_cont));
    end

    return Discrete_Solution, Continuum_Solution
end