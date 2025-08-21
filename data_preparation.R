library(tidyverse)
library(arrow)

# Simulation set v1
# - only tax regime "wealth" and "wealth gains" (no "realized wealth gains") 
# - without allowance_fraction_median
# - no immobility computation for bottom50 and 50to90 group
# Broad coverage of parameter space up to N = 100,000, 100 runs per combination
# 1,000 runs for N = 1,000, and 10,000 
# Additionally 100 longer runs with stop_tick = 1,000 (instead of 200) time steps
# Always 51 taxrates per configuration of (tax_regime, N, stop_tick): 
#    0-0.05 for "wealth"
#    0-0.25 for "wealth gains" 
data <- read_csv(c(
 "simdata_v1/WealthGrowthRedistribution_StrippedDown experiment tax wealth gains-table.csv",
 "simdata_v1/WealthGrowthRedistribution_StrippedDown experiment tax wealth-table.csv",
 "simdata_v1/WealthGrowthRedistribution_StrippedDown experiment tax wealth N 100K-table.csv",
 "simdata_v1/WealthGrowthRedistribution_StrippedDown experiment tax wealth N 2,5,20,50 -.000-table.csv",
 "simdata_v1/WealthGrowthRedistribution_StrippedDown experiment tax wealth gains N 2,5,20,50 -.000-table.csv",
 "simdata_v1/WealthGrowthRedistribution_StrippedDown experiment tax wealth gains N 100K-table.csv"),
 skip = 6
) |> bind_rows(read_csv(c(
 "simdata_v1/WealthGrowthRedistribution_StrippedDown experiment tax wealth long-table.csv",
 "simdata_v1/WealthGrowthRedistribution_StrippedDown experiment tax wealth gains long-table.csv",
 "simdata_v1/WealthGrowthRedistribution_StrippedDown experiment tax wealth more-table.csv",
 "simdata_v1/WealthGrowthRedistribution_StrippedDown experiment tax wealth gains more-table.csv"),
 skip = 6
))
data |> write_parquet("simdata_v1/WealthGrowthRedistribution_StrippedDown experiments v1 all.parquet")
# Check coverage
data |> count(N, stop_tick, tax_regime) |> View()
# data |> count(tax_regime, taxrate) |> View()

# Simulation set v2
# - 3 tax regime "wealth" and "wealth gains" and "realized wealth gains" 
# - only one value realization_scale 1.5 (necessary for "realized wealth gains")
# - with three levels of tax allowance: no, small, high. 
#   Quantified by allowance_fraction_median = 0 (identical to v1), 1 ,and 10
# - immobility computation also for bottom50 and 50to90 group
# - omitting several output measures at past_tick_1, past_tick_2, and past_tick_3
#   focus is on output measures on stop_tick, a picture of the variance is covered by high numbers of runs and
#   can be studied in v1 for variation over time in a run
# - no coverage for N > 10,000
# - all combination with 100 runs (no larger samples of 1,000 as for v1)
# - long runs (stop_tick = 1,000) only for N = 1,000
# Always 51 taxrates per configuration of (tax_regime, N, stop_tick, allowance_fraction_median): 
#    0-0.05 for "wealth" (steps of 0.001)
#    0-0.25 for "wealth gains" (steps of 0.005)
#    0-0.5 for "realized wealth gains" (steps of 0.01)
#    (parameter sweep based on the variable base_taxrate_wealth which is scaled transformed to taxrate upon 
#    simulation start by factors 1 for "wealth", 5 for "wealth gains" and 10 for "realized wealth gains")
data <- read_csv(c(
 "simdata_v2/WealthGrowthRedistribution_StrippedDown experiment tax N 1000-table.csv",
 "simdata_v2/WealthGrowthRedistribution_StrippedDown experiment tax N 2000 5000 10000-table.csv",
 "simdata_v2/WealthGrowthRedistribution_StrippedDown experiment tax N 1000 long-table.csv",
 "simdata_v2/WealthGrowthRedistribution_StrippedDown experiment tax N 10000 more-table.csv",
 "simdata_v2/WealthGrowthRedistribution_StrippedDown experiment tax N 10000 even more-table.csv"),
 skip = 6
)
data |> write_parquet("simdata_v2/WealthGrowthRedistribution_StrippedDown experiments v2 all.parquet")
# Check coverage
# data |> count(N, stop_tick, tax_regime,allowance_fraction_median) |> View()
# data |> count(tax_regime, taxrate, allowance_fraction_median, realization_scale) |> View()
# data |> count(taxrate) |> View() # check taxrate overlapping for different tax_regime

# Simulation set distribution
data_lists <- read_csv(c(
 "simdata_distribution/WealthGrowthRedistribution_StrippedDown experiment distribution-lists.csv"
),
 skip = 6
)
data_table <- read_csv(c(
 "simdata_distribution/WealthGrowthRedistribution_StrippedDown experiment distribution-table.csv"
),
 skip = 6
) |> 
  select(-`[wealth] of turtles`)

data_lists |> pivot_longer(15:ncol(data_lists)) |> 
  select(N, mu, sigma, tax_regime, realization_scale, allowance_fraction_median, 
    base_taxrate_wealth, `[run number]`, ID = name, wealth = value) |> 
  left_join(data_table |> select(`[run number]`, taxrate)) |> 
  select(`[run number]`, tax_regime, taxrate, ID, wealth, everything()) |> 
  write_csv("simdata_distribution/WealthGrowthRedistribution_StrippedDown experiments distribution lists LONG.csv")
