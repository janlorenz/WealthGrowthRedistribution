library(tidyverse)
library(arrow)
d <- read_parquet("simdata_v1/WealthGrowthRedistribution_StrippedDown experiments v1 all.parquet") |> 
 mutate(Ns = format(N, scientific = FALSE, big.mark = ","),
        `Tax Regime` = if_else(tax_regime == "wealth", "Wealth Tax", "Wealth Gains Tax"))

d |> count(tax_regime, N, taxrate) |> View()


# Growth rate
vizspecs_growthrate <- function(g) g +
 geom_point(alpha = 0.05) +
 geom_point(stat = "summary", fun.data = mean_cl_boot, color = "blue") + # mean_cl_boot uses 0.95 confidence interval by default
 geom_errorbar(stat = "summary", fun.data = mean_cl_boot, color = "blue") +
 # geom_smooth() +
 geom_hline(aes(yintercept = exp(mean(mu))), color = "gray") + 
 facet_grid(Ns ~ `Tax Regime`, scales = "free_x") + 
 scale_y_continuous(minor_breaks = seq(1.01, 1.03, 0.001)) +
 labs(title = "Long term growth factors", y = "Long term growth factor", x = "Tax rate",
      caption = "Longterm growth factor measured after 200 time steps. 100 runs per tax rate.\nThe gray horizontal line marks the expected ensemble growth rate. ") +
 theme_minimal()
# Growth rate means
vizspecs_growthrate_means <- function(g) g +
 geom_point(stat = "summary", fun.data = mean_cl_boot) + # mean_cl_boot uses 0.95 confidence interval by default
 geom_errorbar(stat = "summary", fun.data = mean_cl_boot) +
 # geom_smooth() +
 geom_hline(aes(yintercept = exp(mean(mu))), color = "gray") + 
 facet_grid(~`Tax Regime`, scales = "free_x") + 
 scale_y_continuous(minor_breaks = seq(1.01, 1.03, 0.001)) +
 labs(title = "Long term growth factors", y = "Long term growth factor", x = "Tax rate",
      caption = "Longterm growth factor measured after 200 time steps. 100 runs per tax rate.\nThe gray horizontal line marks the expected ensemble growth rate. ") +
 theme_minimal()
vizspecs_growthrate_meanstderr <- function(g) g +
 geom_point(stat = "summary", fun.data = mean_cl_boot) + # mean_cl_boot uses 0.95 confidence interval by default
 geom_errorbar(stat = "summary", fun.data = mean_cl_boot) +
 geom_hline(aes(yintercept = exp(mean(mu))), color = "gray") +
 facet_grid(N ~ tax_regime, scales = "free_x") + 
 scale_y_continuous(minor_breaks = seq(1.01, 1.03, 0.001)) +
 labs(title = paste("Long term growth factors, mean with standard errors"), y = "Long term growth factor", x = "Tax rate",
      caption = "Longterm growth factor measured after 200 time steps. 100 runs per tax rate.\nThe gray horizontal line marks the expected ensemble growth rate. ") +
 theme_minimal()

d |> filter(N == 10000 | N == 100000) |> ggplot(aes(taxrate, growth_rate_all)) |> vizspecs_growthrate()
d |> ggplot(aes(taxrate, growth_rate_all, color = N)) |> vizspecs_growthrate_means()
d |> ggplot(aes(taxrate, growth_rate_all, color = N)) |> vizspecs_growthrate_meanstderr()



d |> summarize(mean_growth_rate_all = mean(growth_rate_all), .by = c(Ns, `Tax Regime`, taxrate)) |> 
 ggplot(aes(taxrate, mean_growth_rate_all, color = Ns)) +
 geom_line() +
 facet_grid(~`Tax Regime`, scales = "free_x") + 
 scale_y_continuous(minor_breaks = seq(1.01, 1.03, 0.001))
d |> summarize(mean_mean_wealth_stop_tick = mean(mean_wealth_stop_tick), .by = c(Ns, `Tax Regime`, taxrate)) |> 
 ggplot(aes(taxrate, mean_mean_wealth_stop_tick, color = Ns)) +
 geom_line() +
 facet_grid(~`Tax Regime`, scales = "free_x")
d |> summarize(mean_mean_wealth_stop_tick = mean(mean_wealth_stop_tick), .by = c(Ns, `Tax Regime`, taxrate)) |> 
 ggplot(aes(taxrate, mean_mean_wealth_stop_tick, color = Ns)) +
 geom_line() +
 facet_grid(~`Tax Regime`, scales = "free_x")

d |> filter(tax_regime == "wealth") |> 
 ggplot(aes(taxrate, growth_rate_all)) |> vizspecs_growthrate_meanstderr()


d |> ggplot(aes(taxrate, share_top1_stop_tick)) +
 geom_point(alpha = 0.05) + geom_smooth() +
 facet_grid(N ~ tax_regime, scales = "free") + theme_minimal()

d |> ggplot(aes(taxrate, gini_stop_tick)) +
 geom_point(alpha = 0.05) + geom_smooth() +
 facet_grid(N ~ tax_regime, scales = "free") + theme_minimal()

d |> ggplot(aes(taxrate, tailexp_top1_stop_tick)) +
 geom_point(alpha = 0.05) + geom_smooth() +
 facet_grid(N ~ tax_regime, scales = "free") + theme_minimal()

d |> ggplot(aes(taxrate, volatility_past_tick_1)) +
 geom_point(alpha = 0.05) + geom_smooth() +
 facet_grid(N ~ tax_regime, scales = "free") + theme_minimal()

d |> ggplot(aes(taxrate, stillintop10_past_tick_2)) +
 geom_point(alpha = 0.05) + geom_smooth() +
 facet_grid(N ~ tax_regime, scales = "free") + theme_minimal()

d |> filter(tax_regime == "wealth gains") |> 
 ggplot(aes(factor(taxrate), growth_rate_past_tick_1)) +
 #geom_point(alpha = 0.05) + geom_smooth() +
 geom_boxplot() + 
 geom_hline(aes(yintercept = exp(mean(mu))), color = "gray") + 
 facet_wrap(~N, scales = "free") + theme_minimal()


d |> filter(tax_regime == "wealth gains", N == 10000) |> 
 ggplot(aes(x = share_top1_stop_tick, y = growth_rate_all, color = taxrate)) +
 geom_point(alpha = 0.3) + geom_smooth() + scale_color_viridis_c()

d |> filter(tax_regime == "wealth gains", N == 10000) |> 
 ggplot(aes(x = stillintop10_past_tick_1, y = growth_rate_all, color = taxrate)) +
 geom_point(alpha = 0.3) + geom_smooth() + scale_color_viridis_c()

d |> filter(tax_regime == "wealth gains", N == 10000) |> 
 ggplot(aes(x = share_top10_stop_tick, y = stillintop10_past_tick_1, color = taxrate)) +
 geom_point(alpha = 0.3) + geom_smooth() + scale_color_viridis_c()·

d |> filter(tax_regime == "wealth gains", N == 10000) |> 
 ggplot(aes(x = share_top10_stop_tick, y = stillintop10_past_tick_1, color = taxrate)) +
 geom_point(alpha = 0.3) + geom_smooth() + scale_color_viridis_c()

d |> filter(tax_regime == "wealth gains", N == 10000) |> 
 ggplot(aes(x = volatility_past_tick_1, y = growth_rate_past_tick_2, color = taxrate)) +
 geom_point(alpha = 0.3) + geom_smooth() + scale_color_viridis_c()
