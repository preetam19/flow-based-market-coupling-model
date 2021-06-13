cd("./results/D-2_base_case")

d_2_line_f =  CSV.read(string("df_d_2_line_f.csv"), DataFrame)
d_2_line_f = Array{Float64}(d_2_line_f)
d_2_np =  CSV.read(string("df_d_2_np.csv"), DataFrame)
d_2_np = Array{Float64}(d_2_np)
d_2_gen =  CSV.read(string("df_d_2_gen.csv"), DataFrame)
d_2_gen = Array{Float64}(d_2_gen)

cd("..")
cd("..")

PTDF_Z = PTDF*gsk_mc
PTDF_Z_CNEC = PTDF_Z[findall(x->x in CNEC, L),:]

# Create empty matrices to store values
d_1_fbmc_curt = zeros(Float64, length(T), length(N))
d_1_fbmc_gen = zeros(Float64, length(T), length(P))
d_1_fbmc_np = zeros(Float64, length(T), length(Z_FBMC))
d_1_fbmc_dump_dem = zeros(Float64, length(T), length(Z))
d_1_fbmc_gen_costs = zeros(Float64, length(T), length(Z))
d_1_fbmc_curt_costs = zeros(Float64, length(T), length(Z))
d_1_fbmc_zonal_price = zeros(Float64, length(T), length(Z_FBMC))


hours_per_horizon = 4*168
days_foresight = 1

for horizon in 1:ceil(Int, length(T)/hours_per_horizon)

	println("Horizon: ", horizon, "/", ceil(Int, length(T)/hours_per_horizon))
	Tsub = ((horizon-1)*hours_per_horizon+1):min((horizon*hours_per_horizon+(days_foresight-1)*24), length(T))

	m = Model(Gurobi.Optimizer)

	@variable(m, 0 <= CURT[t in Tsub, n in N] <= get_renew(t,n)) # Eq. (10d)
	@variable(m, NP[t in Tsub, z in Z_FBMC])
	@variable(m, 0 <= GEN[t in Tsub, p in P] <= get_gen_up(p)) # Eq. (10e)
	@variable(m, GEN_COSTS[t in Tsub, z in Z])
	@variable(m, CURT_COSTS[t in Tsub, z in Z])

# Eq. (10a)
	@objective(m, Min,
		sum(GEN[t,p]*get_mc(p) for t in Tsub for p in P)
		+ sum(CURT[t,n]*cost_curt_mc for t in Tsub for n in N)
		)
	println("Variables done.")

#Eq. (10b)
	@constraint(m, costs_gen[t=Tsub, z=Z],
	sum(GEN[t,p]*get_mc(p) for p in p_in_z[z]) == GEN_COSTS[t,z])
	println("Built constraints costs_gen.")

#Eq. (10c)
	@constraint(m, costs_curt[t=Tsub, z=Z],
	sum(CURT[t,n]*cost_curt_mc for n in n_in_z[z]) == CURT_COSTS[t,z])
	println("Built constraints costs_curt.")

#Eq. (10f)
	@constraint(m, zonal_balance[t=Tsub, z=Z_FBMC],
		sum(GEN[t,p] for p in p_in_z[z])
		+ sum(get_renew(t,n) for n in n_in_z[z])
		- sum(CURT[t,n] for n in n_in_z[z])
		- NP[t,z]
		==
		sum(get_dem(t,n) for n in n_in_z[z])
		)
	println("Built constraints zonal_balance.")

# Eq. (10i)
	@constraint(m, net_position_fbmc[t=Tsub],
	sum(NP[t,z] for z in Z_FBMC) == 0)
	println("Net positions sum-zero inside of FBMC.")

# Eq. (10j) positive RAM
	@constraint(
	m, flow_on_cnes_pos[t=Tsub, j=CNEC],
	sum(PTDF_Z_CNEC[findfirst(CNEC .== j),findfirst(Z_FBMC .== z_fb)]*
		(NP[t,z_fb]-d_2_np[t,findfirst(Z .== z_fb)]) for z_fb in Z_FBMC)
	<= get_line_cap(j)*(1-frm)-d_2_line_f[t,findfirst(L .== j)]
	)
	println("Flows on CNECs (pos).")

# Eq. (10k) negative RAM
	@constraint(
	m, flow_on_cnes_neg[t=Tsub, j=CNEC],
	sum(PTDF_Z_CNEC[findfirst(CNEC .== j),findfirst(Z_FBMC .== z_fb)]*
		(NP[t,z_fb]-d_2_np[t,findfirst(Z .== z_fb)]) for z_fb in Z_FBMC)
	>= -get_line_cap(j)*(1-frm)-d_2_line_f[t,findfirst(L .== j)]
	)
	println("Flows on CNECs (neg).")

	println("Constraints done.")

	status = optimize!(m)

	d_1_fbmc_curt[Tsub,:] = JuMP.value.(CURT[:,:])
	d_1_fbmc_np[Tsub,:] = JuMP.value.(NP[:,:])
	d_1_fbmc_gen[Tsub,:] = JuMP.value.(GEN[:,:])
	d_1_fbmc_gen_costs[Tsub,:] = JuMP.value.(GEN_COSTS[:,:])
	d_1_fbmc_curt_costs[Tsub,:] = JuMP.value.(CURT_COSTS[:,:])
	d_1_fbmc_zonal_price[Tsub,:] = dual.(zonal_balance[:,:])

	m = nothing
end

include("export_D-1_fbmc_results.jl")
