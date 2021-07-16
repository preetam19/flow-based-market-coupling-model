cd("./results/D-1_market_coupling")

# Export
df_d_1_curt = DataFrame(d_1_curt, :auto)
rename!(df_d_1_curt, Dict(names(df_d_1_curt)[i] => Symbol.(N)[i] for i = 1:ncol(df_d_1_curt)))
CSV.write(string("df_d_1_curt.csv"), df_d_1_curt)
df_d_1_gen = DataFrame(d_1_gen, :auto)
rename!(df_d_1_gen, Dict(names(df_d_1_gen)[i] => Symbol.(P)[i] for i = 1:ncol(df_d_1_gen)))
CSV.write(string("df_d_1_gen.csv"), df_d_1_gen)
df_d_1_gen_costs = DataFrame(d_1_gen_costs, :auto)
rename!(df_d_1_gen_costs, Dict(names(df_d_1_gen_costs)[i] => Symbol.(Z)[i] for i = 1:ncol(df_d_1_gen_costs)))
CSV.write(string("df_d_1_gen_costs.csv"), df_d_1_gen_costs)
df_d_1_curt_costs = DataFrame(d_1_curt_costs, :auto)
rename!(df_d_1_curt_costs, Dict(names(df_d_1_curt_costs)[i] => Symbol.(Z)[i] for i = 1:ncol(df_d_1_curt_costs)))
CSV.write(string("df_d_1_curt_costs.csv"), df_d_1_curt_costs)
df_d_1_np = DataFrame(d_1_np, :auto)
rename!(df_d_1_np, Dict(names(df_d_1_np)[i] => Symbol.(Z_FBMC)[i] for i = 1:ncol(df_d_1_np)))
CSV.write(string("df_d_1_np.csv"), df_d_1_np)
df_d_1_nodal_price = DataFrame(d_1_nodal_price, :auto)
rename!(df_d_1_nodal_price, Dict(names(df_d_1_nodal_price)[i] => Symbol.(Z)[i] for i = 1:ncol(df_d_1_nodal_price)))
CSV.write(string("df_d_1_nodal_price.csv"), df_d_1_nodal_price)

cd("..")
cd("..")
println("Saved D-1 market coupling results.")