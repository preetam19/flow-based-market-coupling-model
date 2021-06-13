cd("./results/D-1_market_coupling/FBMC")

# Export
df_d_1_fbmc_curt = DataFrame(d_1_fbmc_curt, :auto)
rename!(df_d_1_fbmc_curt, Dict(names(df_d_1_fbmc_curt)[i] => Symbol.(N)[i] for i = 1:ncol(df_d_1_fbmc_curt)))
CSV.write(string("df_d_1_fbmc_curt.csv"), df_d_1_fbmc_curt)

df_d_1_fbmc_gen = DataFrame(d_1_fbmc_gen, :auto)
rename!(df_d_1_fbmc_gen, Dict(names(df_d_1_fbmc_gen)[i] => Symbol.(P)[i] for i = 1:ncol(df_d_1_fbmc_gen)))
CSV.write(string("df_d_1_fbmc_gen.csv"), df_d_1_fbmc_gen)

df_d_1_fbmc_gen_costs = DataFrame(d_1_fbmc_gen_costs, :auto)
rename!(df_d_1_fbmc_gen_costs, Dict(names(df_d_1_fbmc_gen_costs)[i] => Symbol.(Z)[i] for i = 1:ncol(df_d_1_fbmc_gen_costs)))
CSV.write(string("df_d_1_fbmc_gen_costs.csv"), df_d_1_fbmc_gen_costs)

df_d_1_fbmc_curt_costs = DataFrame(d_1_fbmc_curt_costs, :auto)
rename!(df_d_1_fbmc_curt_costs, Dict(names(df_d_1_fbmc_curt_costs)[i] => Symbol.(Z)[i] for i = 1:ncol(df_d_1_fbmc_curt_costs)))
CSV.write(string("df_d_1_fbmc_curt_costs.csv"), df_d_1_fbmc_curt_costs)

df_d_1_fbmc_np = DataFrame(d_1_fbmc_np, :auto)
rename!(df_d_1_fbmc_np, Dict(names(df_d_1_fbmc_np)[i] => Symbol.(Z_FBMC)[i] for i = 1:ncol(df_d_1_fbmc_np)))
CSV.write(string("df_d_1_fbmc_np.csv"), df_d_1_fbmc_np)

df_d_1_fbmc_zonal_price = DataFrame(d_1_fbmc_zonal_price, :auto)
rename!(df_d_1_fbmc_zonal_price, Dict(names(df_d_1_fbmc_zonal_price)[i] => Symbol.(Z)[i] for i = 1:ncol(df_d_1_fbmc_zonal_price)))
CSV.write(string("df_d_1_fbmc_zonal_price.csv"), df_d_1_fbmc_zonal_price)

cd("..")
cd("..")
cd("..")
println("Saved D-1 flow-based market coupling results.")
