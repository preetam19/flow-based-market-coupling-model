### Set path:
cd("./data")

### Import data:
df_bus_load = CSV.read("df_bus_load_added_abroad_final.csv", DataFrame)
df_bus = CSV.read("df_bus_new.csv", DataFrame)
df_branch = CSV.read("df_branch_final.csv", DataFrame)
df_plants = CSV.read("df_gen_final.csv", copycols=true, DataFrame)
#df_plants = CSV.read("df_gen_final_high_RES.csv", copycols=true, DataFrame)
incidence = CSV.read("matrix_A_final.csv", DataFrame)
susceptance = CSV.read("matrix_Bd_final.csv", DataFrame)
xf_renew_new = CSV.read("data_renew.csv", DataFrame)



# Adjustment of capacities:
df_bus.ZoneRes = df_bus.Zone


### Sets:Z_
## General sets:
T = 1:size(df_bus_load,1)
R = names(xf_renew_new)[3:end]
P = df_plants.GenID[[!(x in R) for x in df_plants[:,:Type]]]
N = df_bus[:,:BusID]
L = df_branch[:,:BranchID]
Z = sort(unique(df_bus[:,:Zone]))

# This function is used to assign units to zones,
# in case new zone configurations are used in df_bus
function replaced_zones()
	zone_p_new = []
	for i in df_plants.OnBus
		zone_p_new = vcat(zone_p_new,df_bus.Zone[df_bus[:,:BusID].==i][1])
		#df_plants.Zone[df_plants[:,:GenID].==p] = zone_p_new
	end
	return zone_p_new
end

df_plants.Zone = replaced_zones()

## Flow-based sets:

Z_FBMC = Z[(length(Z)-2):length(Z)]
N_FBMC = df_bus.BusID[[x in Z_FBMC for x in df_bus[:,:Zone]]]
Z_not_in_FBMC = Z[1:(length(Z)-3)]
 N_not_in_FBMC = df_bus.BusID[[!(x in Z_FBMC) for x in df_bus[:,:Zone]]]
## Redispatch:
P_RD = df_plants.GenID[[x in ["Oil", "Natural gas",  "Biomass" ,"Coal"] for x in df_plants[:,:Type]]]

## Mapping:
 n_in_z = Dict(map(z -> z => [n for n in N if df_bus[df_bus[:,:BusID].==n, :Zone][1] == z], Z))
 p_at_n = Dict(map(n -> n => [p for p in P if df_plants[df_plants[:,:GenID].==p, :OnBus][1] == n], N))
 p_rd_at_n = Dict(map(n-> n=> [p for p in P_RD if df_plants[df_plants[:,:GenID].==p, :OnBus][1] == n], N))
 p_in_z = Dict(map(z -> z => [p for p in P if df_plants[df_plants[:,:GenID].==p, :Zone][1] == z], Z))

 z_to_z = Dict(map(z-> z=> [zz for zz in Z if
 	     (zz in df_bus.Zone[[(x in df_branch.FromBus[(x in n_in_z[z] for x in df_branch.FromBus) .|
 					              (x in n_in_z[z] for x in df_branch.ToBus)]) .|
 	 		 (x in df_branch.ToBus[(x in n_in_z[z] for x in df_branch.FromBus) .|
 				 	              (x in n_in_z[z] for x in df_branch.ToBus)]) for x in df_bus.BusID]]) .& (zz!=z)], Z))

### Calculations and functions:
## Susceptance matrices:

# line_sus_mat = convert(Matrix, susceptance)*convert(Matrix, incidence)
# node_sus_mat = transpose(convert(Matrix, incidence))*convert(Matrix, susceptance)*convert(Matrix, incidence)
susceptance = Matrix(susceptance)
incidence = Matrix(incidence)
line_sus_mat = susceptance*incidence
node_sus_mat = transpose(incidence)* susceptance*incidence


function get_line_sus(l,n)
	return line_sus_mat[findfirst(L .== l), findfirst(N .== n)]
end

function get_node_sus(n,nn)
	return node_sus_mat[findfirst(N .== n), findfirst(N .== nn)]
end

H_mat = Dict((l,n) => get_line_sus(l,n)
	for (l,l) in enumerate(L), (n,n) in enumerate(N))

B_mat = Dict((n,nn) => get_node_sus(n,nn)
	for (n,n) in enumerate(N), (nn,nn) in enumerate(N))

## Marginal costs:
function get_mc(p)
	return df_plants[df_plants[:,:GenID].==p, :Costs][1]
end

function find_maximum_mc()
	max_temp = 0
    for p in P_RD
        mc_temp = get_mc(p)
        if mc_temp > max_temp
            max_temp = mc_temp
        end
    end
	return max_temp
end

## Demand:
function get_dem(t,n)
	return df_bus_load[t,Symbol.(n)]
end

## Renewables:
function create_res_table()
    res_temp = zeros(Float64, length(T),length(N))
    ren_temp_pv = zeros(Float64, length(T))
    ren_temp_wind = zeros(Float64, length(T))
    ren_temp_hydro = zeros(Float64, length(T))

    for n in N

        for r in R
            genID_temp = df_plants.GenID[(df_plants[:,:Type].==r) .& (df_plants[:,:OnBus].==n)]
            if isempty(genID_temp) == true
                continue
            end
            ren_temp = zeros(Int64, size(df_renew,1))

            for i in 1:length(genID_temp)
                ren_temp = hcat(ren_temp, df_renew[:,string(genID_temp[i])])
            end
            ren_temp = ren_temp[:,2:end]

            if r == "solar"
                ren_temp_pv = sum(ren_temp[:,i] for i in 1:size(ren_temp,2))
            elseif r == "Wind"
                ren_temp_wind = sum(ren_temp[:,i] for i in 1:size(ren_temp,2))
            else
                ren_temp_hydro = sum(ren_temp[:,i] for i in 1:size(ren_temp,2))
            end
        end
        res_temp[:, findfirst(N.==n)] = ren_temp_pv + ren_temp_wind + ren_temp_hydro

        ren_temp_pv = zeros(Float64, length(T))
        ren_temp_wind = zeros(Float64, length(T))
        ren_temp_hydro = zeros(Float64, length(T))
    end
    return res_temp
end

res_table = create_res_table()


function get_renew(t,n)
	return res_table[findfirst(T .== t), findfirst(N .== n)]
end

## Get conventional capacity
function get_gen_up(p)
	return df_plants.Pmax[df_plants[:,:GenID].==p][1]
end

## Get line capacity
function get_line_cap(l)
	return df_branch.Pmax[df_branch[:,:BranchID].==l][1]
end

## Get line capacity
function find_cross_border_lines()
	cb_lines_temp = []
	for l in L
		from_zone_temp = df_bus.Zone[df_bus[:,:BusID].==df_branch.FromBus[df_branch[:,:BranchID].==l][1]][1]
		to_zone_temp = df_bus.Zone[df_bus[:,:BusID].==df_branch.ToBus[df_branch[:,:BranchID].==l][1]][1]
		if (from_zone_temp in Z_FBMC && to_zone_temp in Z_FBMC && (from_zone_temp!=to_zone_temp))
			cb_lines_temp = vcat(cb_lines_temp,l)
		end
	end
	return cb_lines_temp
end

cd("..")