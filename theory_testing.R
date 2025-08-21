basetax = 0.01
x <- rlnorm(1000)
x |> log() |> sd()
# tax revenue
(x*basetax) |> sum()
(ifelse(x > 1, (x - 1)*(basetax), 0)) |> sum()
(ifelse(x > 1, (x - 1)*(basetax*7.5), 0)) |> sum()
# effective wealth growth rates
(x*(1 - basetax)) |> log() |> sd()
(ifelse(x > 1, 1 + (x-1)*(1 - basetax), x)) |> log() |> sd()
(ifelse(x > 1, 1 + (x-1)*(1 - basetax*7.5), x)) |> sd()

