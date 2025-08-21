library(tidyverse)
library(arrow)
library(glue)

# Hand-picked rescale parameters
## Low tax regime fitting
scale_down_low_wealthgains = 7.75
scale_down_low_realizedwealthgains1_5 = 19
## High tax regime fitting
scale_down_high_wealthgains = 5.5
shift_high_wealthgains = -0.005
scale_down_high_realizedwealthgains1_5 = 10
shift_high_realizedwealthgains1_5 = -0.01

# Compute a few more variables
wrangle <- function(d) d |> 
  mutate(Ns = format(N, scientific = FALSE, big.mark = ","), # renaming for plots
         `Tax Regime` = case_when(
          tax_regime == "wealth" ~ "Wealth Tax", 
          tax_regime == "wealth gains" ~ "Wealth Gains Tax", 
          tax_regime == "realized wealth gains" ~ "Realized Wealth Gains Tax"), # renaming for plots
         taxrate_wealth_scaled_1 = case_when(
          tax_regime == "wealth" ~ taxrate,
          tax_regime == "wealth gains" ~ taxrate/scale_down_low_wealthgains,
          tax_regime == "realized wealth gains" ~ taxrate/scale_down_low_realizedwealthgains1_5),
         taxrate_wealth_scaled_2 = case_when(
          tax_regime == "wealth" ~ taxrate,
          tax_regime == "wealth gains" ~ taxrate/scale_down_high_wealthgains + shift_high_wealthgains,
          tax_regime == "realized wealth gains" ~ taxrate/scale_down_high_realizedwealthgains1_5 + shift_high_realizedwealthgains1_5),
         across(starts_with("tailexp"), \(x) x - 1)) 
d1 <- read_parquet("simdata_v1/WealthGrowthRedistribution_StrippedDown experiments v1 all.parquet") |> wrangle()
d2 <- read_parquet("simdata_v2/WealthGrowthRedistribution_StrippedDown experiments v2 all.parquet") |> wrangle()|> 
 mutate(`Tax Regime` = 
         if_else(tax_regime == "realized wealth gains", paste0(`Tax Regime`, " (", realization_scale, ")"), `Tax Regime`))

# fig-cap: #Comparison of tax regimes with scales tax rates, version 1
d2_taxshare <- d2 |> filter(N == 10000, stop_tick == 200, allowance_fraction_median == 0) |> 
 rename(`Tail Exponent 10%` = tailexp_top10_stop_tick, 
        `Tail Exponent 1%` = tailexp_top1_stop_tick, 
        Gini =gini_stop_tick, 
        `Share Top 1%` = share_top1_stop_tick, 
        `Share Top 10%` = share_top10_stop_tick, 
        `Immobility Top 10%` = stillintop10_past_tick_3,
        `Immobility Bottom 50%` = stillinbottom50_past_tick_3,
        `Long-term Realized Growth Rate` = growth_rate_all,  
        Taxshare = taxshare_stop_tick,
        Taxrate = taxrate) |> 
 pivot_longer(c(`Tail Exponent 10%`, `Tail Exponent 1%`, `Gini`, `Share Top 1%`, `Share Top 10%`, 
                `Immobility Top 10%`,`Immobility Bottom 50%`,`Long-term Realized Growth Rate`,Taxrate))  |>
  mutate(name = factor(name, 
       levels = c("Taxrate", "Long-term Realized Growth Rate", "Gini",
       "Tail Exponent 1%", "Share Top 1%", "Immobility Top 10%", 
       "Tail Exponent 10%", "Share Top 10%", "Immobility Bottom 50%"))) |> 
 mutate(Taxshare_rounded = round(Taxshare, digits = 3)) |>
 summarize(median = median(value),mean = mean(value), n = n(), sd = sd(value), q1=quantile(value, 0.25), q3=quantile(value,0.75),
           stderr = sd/sqrt(n), .by = c(name, Taxshare_rounded, `Tax Regime`)) 
d2_taxshare |>   
  filter(Taxshare_rounded <= 0.03, `Tax Regime` %in% c("Wealth Tax", "Wealth Gains Tax", "Realized Wealth Gains Tax (1.5)")) |> 
  summarize(n = mean(n), .by = c(Taxshare_rounded, `Tax Regime`)) |>
  ggplot(aes(Taxshare_rounded, n, color = `Tax Regime`)) + geom_line() + geom_point() +
  labs(x = "Tax Revenue Rate at Total Wealth", 
       y = "Number of Runs", 
       title = "Number of runs behind each Data Point",
       caption = "Revenus Rates grouped in bins of width 0.001.") +
  guides(color = guide_legend(position = "bottom", nrow = 1)) +
  theme_minimal()
ggsave("figs/taxshare_numruns.pdf", width = 6, height = 6)
g <- d2_taxshare |> 
  filter(Taxshare_rounded <= 0.03, `Tax Regime` %in% c("Wealth Tax", "Wealth Gains Tax", "Realized Wealth Gains Tax (1.5)")) |> 
  ggplot() + 
  facet_wrap(~name, scales = "free_y") +
  labs(caption = "All measures for runs of 10,000 agents, after 200 time steps.
              More than 700 runs behind each data point except for Realized Wealth Gains above 0.024.") +
  guides(color = guide_legend(position = "bottom", nrow = 1)) +
  theme_minimal()
# Median
g + aes(Taxshare_rounded, median, color = `Tax Regime`) + geom_line() + geom_point() +
  geom_errorbar(aes(ymin = q1, ymax = q3), width = 0.0005) +
  labs(x = "Tax Revenue Rate at Total Wealth", 
       y = "Median (error bars: IQR)", 
       title = "Median of Output Measures by Tax Revenue Rate at Total Wealth") 
ggsave("figs/taxshare_median.pdf", width = 10, height = 8)
# Mean
g + aes(Taxshare_rounded, mean, color = `Tax Regime`) + geom_line() + geom_point() +
  labs(x = "Tax Revenue Rate at Total Wealth", 
       y = "Mean", 
       title = "Mean of Output Measures by Tax Revenue Rate at Total Wealth") 
ggsave("figs/taxshare_mean.pdf", width = 10, height = 8)
# Mean + SD
g + aes(Taxshare_rounded, mean, color = `Tax Regime`) + geom_line() + geom_point() +
  geom_errorbar(aes(ymin = mean - sd, ymax = mean + sd), width = 0.0005) +
  labs(x = "Tax Revenue Rate at Total Wealth", 
       y = "Mean (error bars: standard deviation)", 
       title = "Mean of Output Measures by Tax Revenue Rate at Total Wealth") 
ggsave("figs/taxshare_mean_sd.pdf", width = 10, height = 8)
# Mean + Std Error
g + aes(Taxshare_rounded, mean, color = `Tax Regime`) + geom_line() + geom_point() +
  geom_errorbar(aes(ymin = mean - stderr, ymax = mean + stderr), width = 0.0005) +
  labs(x = "Tax Revenue Rate at Total Wealth", 
       y = "Mean (error bars: standard error)", 
       title = "Mean of Output Measures by Tax Revenue Rate at Total Wealth") 
ggsave("figs/taxshare_mean_stderr.pdf", width = 10, height = 8)
