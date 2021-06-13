using Pkg
using CSV, XLSX, DataFrames
using Gurobi
using JuMP
using Statistics
using Plots
import Pkg
## LOAD DATA, FUNCTIONS, COMPUTE PRELIMINARIES
#cd("...") #may have to change
include("data_and_functions.jl")
include("fbmc_preliminaries.jl")

## PARAMETER CHOICES
# Flow-based preliminaries
cne_alpha = 0.1
gsk_cne = gsk_flat_unit
gsk_mc = gsk_flat_unit
frm = 0.2
include_cb_lines = true
include("cne_selection.jl")

# Market coupling
cost_curt_mc = 0
#
# ## MODELlING

nodal_analysis = true
zonal_analysis = true

if nodal_analysis == true && zonal_analysis == true
    include("model_D-2_base_case.jl")
    include("model_D-1_fbmc.jl")
    include("model_D-1_nodal_pricing.jl")
    include("model_D-0_congestion_management.jl")
elseif nodal_analysis == false && zonal_analysis == true
    include("model_D-2_base_case.jl")
    include("model_D-1_fbmc.jl")
    include("model_D-0_congestion_management.jl")
elseif nodal_analysis == true && zonal_analysis == false
    include("model_D-2_base_case.jl")
    include("model_D-1_nodal_pricing.jl")
else
    println("No market coupling method selected")
end

