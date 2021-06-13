cd("./results/D-1_market_coupling/NP")

df_d_1_nodal_curt = DataFrame(d_1_nodal_curt, :auto)
rename!(df_d_1_nodal_curt, Dict(names(df_d_1_nodal_curt)[i] => Symbol.(N)[i] for i = 1:ncol(df_d_1_nodal_curt)))
CSV.write(string("df_d_1_nodal_curt.csv"), df_d_1_nodal_curt)

df_d_1_nodal_delta = DataFrame(d_1_nodal_delta, :auto)
rename!(df_d_1_nodal_delta, Dict(names(df_d_1_nodal_delta)[i] => Symbol.(N)[i] for i = 1:ncol(df_d_1_nodal_delta)))
CSV.write(string("df_d_1_nodal_delta.csv"), df_d_1_nodal_delta)

df_d_1_nodal_nod_inj = DataFrame(d_1_nodal_nod_inj, :auto)
rename!(df_d_1_nodal_nod_inj, Dict(names(df_d_1_nodal_nod_inj)[i] => Symbol.(N)[i] for i = 1:ncol(df_d_1_nodal_nod_inj)))
CSV.write(string("df_d_1_nodal_nod_inj.csv"), df_d_1_nodal_nod_inj)

df_d_1_nodal_line_f = DataFrame(d_1_nodal_line_f, :auto)
rename!(df_d_1_nodal_line_f, Dict(names(df_d_1_nodal_line_f)[i] => Symbol.(L)[i] for i = 1:ncol(df_d_1_nodal_line_f)))
CSV.write(string("df_d_1_nodal_line_f.csv"), df_d_1_nodal_line_f)

df_d_1_nodal_gen = DataFrame(d_1_nodal_gen, :auto)
rename!(df_d_1_nodal_gen, Dict(names(df_d_1_nodal_gen)[i] => Symbol.(P)[i] for i = 1:ncol(df_d_1_nodal_gen)))
CSV.write(string("df_d_1_nodal_gen.csv"), df_d_1_nodal_gen)

df_d_1_nodal_gen_costs = DataFrame(d_1_nodal_gen_costs, :auto)
rename!(df_d_1_nodal_gen_costs, Dict(names(df_d_1_nodal_gen_costs)[i] => Symbol.(Z)[i] for i = 1:ncol(df_d_1_nodal_gen_costs)))
CSV.write(string("df_d_1_nodal_gen_costs.csv"), df_d_1_nodal_gen_costs)

df_d1_nodal_curt_costs = DataFrame(d_1_nodal_curt_costs, :auto)
rename!(df_d1_nodal_curt_costs, Dict(names(df_d1_nodal_curt_costs)[i] => Symbol.(Z)[i] for i = 1:ncol(df_d1_nodal_curt_costs)))
CSV.write(string("df_d1_nodal_curt_costs.csv"), df_d1_nodal_curt_costs)

df_d_1_nodal_nodal_price = DataFrame(d_1_nodal_nodal_price, :auto)
rename!(df_d_1_nodal_nodal_price, Dict(names(df_d_1_nodal_nodal_price)[i] => Symbol.(N)[i] for i = 1:ncol(df_d_1_nodal_nodal_price)))
CSV.write(string("df_d_1_nodal_nodal_price.csv"), df_d_1_nodal_nodal_price)

df_d_1_nodal_np = DataFrame(d_1_nodal_np, :auto)
rename!(df_d_1_nodal_np, Dict(names(df_d_1_nodal_np)[i] => Symbol.(Z_FBMC)[i] for i = 1:ncol(df_d_1_nodal_np)))
CSV.write(string("df_d_1_nodal_np.csv"), df_d_1_nodal_np)


cd("..")
cd("..")
cd("..")
println("Saved D-1 Nodal Pricing results.")
