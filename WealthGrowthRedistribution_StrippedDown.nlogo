globals [tax_revenue
         log_changes
         old_mean_wealth
         median_taxbase
  ; The following variables are used to optimize for speed by limiting computation to certain time points
  mean_wealth_past_tick_1
  mean_wealth_past_tick_2
  mean_wealth_past_tick_3
  mean_wealth_stop_tick
  median_wealth_stop_tick
  share_top10_stop_tick
  share_top1_stop_tick
  share_top01_stop_tick
  gini_stop_tick
  tailexp_top10_stop_tick
  tailexp_top5_stop_tick
  tailexp_top1_stop_tick
  volatility_past_tick_1 volatility_past_tick_2 volatility_past_tick_3
  stillinbottom50_past_tick_1 stillinbottom50_past_tick_2 stillinbottom50_past_tick_3
  stillin50to90_past_tick_1 stillin50to90_past_tick_2 stillin50to90_past_tick_3
  stillintop10_past_tick_1 stillintop10_past_tick_2 stillintop10_past_tick_3
  stillintop1_past_tick_1 stillintop1_past_tick_2 stillintop1_past_tick_3
  growth_rate_all growth_rate_past_tick_1 growth_rate_past_tick_2  growth_rate_past_tick_3
  taxshare_stop_tick
  fraction_paying_tax_stop_tick
]
turtles-own [wealth
             wealth_return
             taxbase
             tax
             wealth_on_acquisition
  ; The following variables are used to optimize for speed by limiting computation to certain time points
  inbottom50_past_tick_1 inbottom50_past_tick_2 inbottom50_past_tick_3 inbottom50_stop_tick
  in50to90_past_tick_1 in50to90_past_tick_2 in50to90_past_tick_3 in50to90_stop_tick
  intop10_past_tick_1 intop10_past_tick_2 intop10_past_tick_3 intop10_stop_tick
  intop1_past_tick_1 intop1_past_tick_2 intop1_past_tick_3 intop1_stop_tick
]

to setup
  clear-all
  create-turtles N [
    initialize
  ]
  set taxrate base_taxrate_wealth * (ifelse-value (tax_regime = "wealth gains") [5] (tax_regime = "realized wealth gains") [10] [1])
  set old_mean_wealth 1
  set log_changes (list)
  reset-ticks
end

to initialize
  ; setxy random-xcor random-ycor
  ; set shape "face happy"
  set wealth 1
  set wealth_on_acquisition wealth
end

to go
  turtles_wealth_returns
  turtles_tax
  turtles_new_wealth
  ; intermediate measures
  let mean_wealth mean [wealth] of turtles
  if (ticks >= stop_tick - past_tick_1) [
      set log_changes fput (ln mean_wealth - ln old_mean_wealth) log_changes
  ]
  set old_mean_wealth mean_wealth
  ; COMPUTING MEASURES
  ; The following is code optimized for speed by limiting computations only to certain time point
  ; past 1 tick measures
  if (ticks = stop_tick - past_tick_1) [
    set mean_wealth_past_tick_1 mean_wealth
    let sorted-wealth reverse sort [wealth] of turtles
    let quantile_top50 item round (0.5 * count turtles) sorted-wealth
    let quantile_top10 item round (0.1 * count turtles) sorted-wealth
    let quantile_top5 item round (0.05 * count turtles) sorted-wealth
    let quantile_top1 item round (0.01 * count turtles) sorted-wealth
    let quantile_top01 item round (0.001 * count turtles) sorted-wealth
    ask turtles [
      set inbottom50_past_tick_1 wealth <= quantile_top50
      set in50to90_past_tick_1 wealth > quantile_top50 and wealth <= quantile_top10
      set intop10_past_tick_1 wealth > quantile_top10
      set intop1_past_tick_1 wealth > quantile_top1
    ]
  ]
  ; past 2 tick measures
  if (ticks = stop_tick - past_tick_2) [
    set mean_wealth_past_tick_2 mean_wealth
    let sorted-wealth reverse sort [wealth] of turtles
    let quantile_top50 item round (0.5 * count turtles) sorted-wealth
    let quantile_top10 item round (0.1 * count turtles) sorted-wealth
    let quantile_top5 item round (0.05 * count turtles) sorted-wealth
    let quantile_top1 item round (0.01 * count turtles) sorted-wealth
    let quantile_top01 item round (0.001 * count turtles) sorted-wealth
    ask turtles [
      set inbottom50_past_tick_2 wealth <= quantile_top50
      set in50to90_past_tick_2 wealth > quantile_top50 and wealth <= quantile_top10
      set intop10_past_tick_2 wealth > quantile_top10
      set intop1_past_tick_2 wealth > quantile_top1
    ]
  ]
  ; past 3 tick measures
  if (ticks = stop_tick - past_tick_3) [
    set mean_wealth_past_tick_3 mean_wealth
    let sorted-wealth reverse sort [wealth] of turtles
    let quantile_top50 item round (0.5 * count turtles) sorted-wealth
    let quantile_top10 item round (0.1 * count turtles) sorted-wealth
    let quantile_top5 item round (0.05 * count turtles) sorted-wealth
    let quantile_top1 item round (0.01 * count turtles) sorted-wealth
    let quantile_top01 item round (0.001 * count turtles) sorted-wealth
    ask turtles [
      set inbottom50_past_tick_3 wealth <= quantile_top50
      set in50to90_past_tick_3 wealth > quantile_top50 and wealth <= quantile_top10
      set intop10_past_tick_3 wealth > quantile_top10
      set intop1_past_tick_3 wealth > quantile_top1
    ]
  ]
  tick
  if (ticks = stop_tick) [
    ; stop tick measures
    set mean_wealth_stop_tick mean_wealth
    set median_wealth_stop_tick median [wealth] of turtles
    set taxshare_stop_tick tax_revenue / sum [wealth] of turtles
    set fraction_paying_tax_stop_tick count turtles with [tax > 0] / count turtles
    let sorted-wealth reverse sort [wealth] of turtles
    let quantile_top50 item round (0.5 * count turtles) sorted-wealth
    let quantile_top10 item round (0.1 * count turtles) sorted-wealth
    let quantile_top5 item round (0.05 * count turtles) sorted-wealth
    let quantile_top1 item round (0.01 * count turtles) sorted-wealth
    let quantile_top01 item round (0.001 * count turtles) sorted-wealth
    ask turtles [
      set inbottom50_stop_tick wealth <= quantile_top50
      set in50to90_stop_tick wealth > quantile_top50 and wealth <= quantile_top10
      set intop10_stop_tick wealth > quantile_top10
      set intop1_stop_tick wealth > quantile_top1
    ]
    set share_top10_stop_tick (sum [wealth] of turtles with [wealth > quantile_top10]) / (mean_wealth_stop_tick * count turtles)
    set share_top1_stop_tick (sum [wealth] of turtles with [wealth > quantile_top1]) / (mean_wealth_stop_tick * count turtles)
    if (any? turtles with [wealth > quantile_top01]) [ set share_top01_stop_tick (sum [wealth] of turtles with [wealth > quantile_top01]) / (mean_wealth_stop_tick * count turtles)]
    set gini_stop_tick gini [wealth] of turtles
    set tailexp_top10_stop_tick tail-exponent-fit ([wealth] of turtles with [wealth > quantile_top10]) quantile_top10
    set tailexp_top5_stop_tick  tail-exponent-fit ([wealth] of turtles with [wealth > quantile_top5])  quantile_top5
    set tailexp_top1_stop_tick  tail-exponent-fit ([wealth] of turtles with [wealth > quantile_top1])  quantile_top1
    ; more final measures
    set volatility_past_tick_1 standard-deviation log_changes
    set volatility_past_tick_2 standard-deviation sublist log_changes 0 past_tick_2
    set volatility_past_tick_3 standard-deviation sublist log_changes 0 past_tick_3
    set stillinbottom50_past_tick_1 count turtles with [inbottom50_past_tick_1 and inbottom50_stop_tick] / count turtles with [inbottom50_stop_tick]
    set stillin50to90_past_tick_1 count turtles with [in50to90_past_tick_1 and in50to90_stop_tick] / count turtles with [in50to90_stop_tick]
    set stillintop10_past_tick_1 count turtles with [intop10_past_tick_1 and intop10_stop_tick] / count turtles with [intop10_stop_tick]
    set stillintop1_past_tick_1 count turtles with [intop1_past_tick_1 and intop1_stop_tick] / count turtles with [intop1_stop_tick]
    set stillinbottom50_past_tick_2 count turtles with [inbottom50_past_tick_2 and inbottom50_stop_tick] / count turtles with [inbottom50_stop_tick]
    set stillin50to90_past_tick_2 count turtles with [in50to90_past_tick_2 and in50to90_stop_tick] / count turtles with [in50to90_stop_tick]
    set stillintop10_past_tick_2 count turtles with [intop10_past_tick_2 and intop10_stop_tick] / count turtles with [intop10_stop_tick]
    set stillintop1_past_tick_2 count turtles with [intop1_past_tick_2 and intop1_stop_tick] / count turtles with [intop1_stop_tick]
    set stillinbottom50_past_tick_3 count turtles with [inbottom50_past_tick_3 and inbottom50_stop_tick] / count turtles with [inbottom50_stop_tick]
    set stillin50to90_past_tick_3 count turtles with [in50to90_past_tick_3 and in50to90_stop_tick] / count turtles with [in50to90_stop_tick]
    set stillintop10_past_tick_3 count turtles with [intop10_past_tick_3 and intop10_stop_tick] / count turtles with [intop10_stop_tick]
    set stillintop1_past_tick_3 count turtles with [intop1_past_tick_3 and intop1_stop_tick] / count turtles with [intop1_stop_tick]
    set growth_rate_all exp ((ln mean_wealth_stop_tick) / ticks)
    set growth_rate_past_tick_1 exp ((ln mean_wealth_stop_tick - ln mean_wealth_past_tick_1) / past_tick_1)
    set growth_rate_past_tick_2 exp ((ln mean_wealth_stop_tick - ln mean_wealth_past_tick_2) / past_tick_2)
    set growth_rate_past_tick_3 exp ((ln mean_wealth_stop_tick - ln mean_wealth_past_tick_3) / past_tick_3)
    stop
  ]
end

to turtles_wealth_returns
  ask turtles [
    set wealth_return wealth * ((random-growth-factor mu sigma) - 1)
  ]
end

to turtles_tax
  ; set taxbase for the purpose of computing a dynamic allowance threshold
  ; based on its median and allowance_fraction_median
  ask turtles[ set taxbase (ifelse-value
    (tax_regime = "wealth")
      [ wealth + wealth_return ]
    (tax_regime = "wealth gains")
      [ max list (wealth_return) 0 ]
    (tax_regime = "realized wealth gains" and wealth + wealth_return >= realization_scale * wealth_on_acquisition)
      [wealth + wealth_return - wealth_on_acquisition]
      [0]
    )
  ]
  ; set tax of individuals
  ifelse allowance_fraction_median > 0 [
    let turtles_to_tax turtles with [taxbase > 0]
    ifelse count turtles_to_tax > 0 [
      set median_taxbase median [taxbase] of turtles with [taxbase > 0]
      ; important: the median taxbase is only taken for those whose taxbase is not zero!
      ask turtles [ set tax taxrate * max list 0 (taxbase - median_taxbase * allowance_fraction_median) ]
    ] [
      ask turtles [set tax 0]
    ]
  ][
    ask turtles [ set tax taxrate * taxbase ]
  ]
end

to turtles_new_wealth
  set tax_revenue sum [tax] of turtles
  ask turtles [
    set wealth (wealth + wealth_return - tax + tax_revenue / count turtles)
  ]
  ask turtles [
    if (tax_regime = "realized wealth gains" and tax > 0) [
      set wealth_on_acquisition wealth
    ]
  ]
end

;;; Model reporters

to-report random-growth-factor [mu_ sigma_]
  report exp (mu_ - sigma_ ^ 2 / 2 + sigma_ * random-shock)
end

to-report random-shock
  report random-normal 0 1
end

;;; Output reporters

to-report gini [w]
  let num length w
  report (2 * sum (map [ [x y] -> x * y ]
                 n-values num [ x -> x + 1 ]
                 sort w) )
                 / (num * (sum w)) - (num + 1) / num
end

to-report tail-exponent-fit [w threshold]
  ; let threshold (mean w) * mean_factor_fit ;fit-threshold w ;
  ; set w filter [x -> x > threshold] w
  report 1 + length w / sum map [x -> ln (x / threshold)] w
end




;to-report transtion_prob_decile [move_from move_to]
;  report count turtles with [first decile_group = move_to and last decile_group = move_from] / count turtles with [last decile_group = move_from]
;end

to-report wealth-fraction-top [w topshare]
  report sum (sublist (reverse sort w) 0 round (topshare * count turtles)) / sum w
end
@#$#@#$#@
GRAPHICS-WINDOW
380
8
601
230
-1
-1
6.455
1
10
1
1
1
0
0
0
1
-16
16
-16
16
1
1
1
ticks
30.0

SLIDER
8
357
228
390
taxrate
taxrate
0
0.5
0.19
0.005
1
NIL
HORIZONTAL

SLIDER
90
36
267
69
N
N
0
100000
1000.0
10
1
NIL
HORIZONTAL

BUTTON
10
35
84
68
NIL
Setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
10
210
72
243
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
10
10
303
31
Input parameters
18
0.0
1

TEXTBOX
11
186
201
207
Taxation and redistribution
12
0.0
1

SLIDER
10
100
183
133
mu
mu
-0.5
0.5
0.02
0.005
1
NIL
HORIZONTAL

SLIDER
10
136
183
169
sigma
sigma
0
1
0.3
0.01
1
NIL
HORIZONTAL

MONITOR
189
126
341
171
time average growth rate
mu - sigma ^ 2 / 2
5
1
11

TEXTBOX
190
105
313
124
ensemble growth rate
10
0.0
1

CHOOSER
78
210
270
255
tax_regime
tax_regime
"wealth" "wealth gains" "realized wealth gains"
2

TEXTBOX
13
79
288
108
Wealth: Random mutliplicative growth
12
0.0
1

INPUTBOX
618
8
708
69
stop_tick
200.0
1
0
Number

INPUTBOX
618
73
708
133
past_tick_1
50.0
1
0
Number

INPUTBOX
618
203
708
263
past_tick_3
10.0
1
0
Number

INPUTBOX
618
137
708
199
past_tick_2
25.0
1
0
Number

SLIDER
10
319
237
352
allowance_fraction_median
allowance_fraction_median
0
10
10.0
0.1
1
NIL
HORIZONTAL

SLIDER
97
258
270
291
realization_scale
realization_scale
1
5
1.5
0.1
1
NIL
HORIZONTAL

SLIDER
10
416
193
449
base_taxrate_wealth
base_taxrate_wealth
0
0.1
0.019
0.001
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment tax N 1000" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>taxrate</metric>
    <metric>mean_wealth_stop_tick</metric>
    <metric>share_top10_stop_tick</metric>
    <metric>share_top1_stop_tick</metric>
    <metric>share_top01_stop_tick</metric>
    <metric>gini_stop_tick</metric>
    <metric>tailexp_top10_stop_tick</metric>
    <metric>tailexp_top5_stop_tick</metric>
    <metric>tailexp_top1_stop_tick</metric>
    <metric>volatility_past_tick_1</metric>
    <metric>volatility_past_tick_2</metric>
    <metric>volatility_past_tick_3</metric>
    <metric>stillinbottom50_past_tick_1</metric>
    <metric>stillinbottom50_past_tick_2</metric>
    <metric>stillinbottom50_past_tick_3</metric>
    <metric>stillin50to90_past_tick_1</metric>
    <metric>stillin50to90_past_tick_2</metric>
    <metric>stillin50to90_past_tick_3</metric>
    <metric>stillintop10_past_tick_1</metric>
    <metric>stillintop10_past_tick_2</metric>
    <metric>stillintop10_past_tick_3</metric>
    <metric>stillintop1_past_tick_1</metric>
    <metric>stillintop1_past_tick_2</metric>
    <metric>stillintop1_past_tick_3</metric>
    <metric>growth_rate_all</metric>
    <metric>growth_rate_past_tick_1</metric>
    <metric>growth_rate_past_tick_2</metric>
    <metric>growth_rate_past_tick_3</metric>
    <metric>taxshare_stop_tick</metric>
    <metric>fraction_paying_tax_stop_tick</metric>
    <enumeratedValueSet variable="stop_tick">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="past_tick_1">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="past_tick_2">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="past_tick_3">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mu">
      <value value="0.02"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tax_regime">
      <value value="&quot;wealth&quot;"/>
      <value value="&quot;wealth gains&quot;"/>
      <value value="&quot;realized wealth gains&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="base_taxrate_wealth" first="0" step="0.001" last="0.05"/>
    <enumeratedValueSet variable="realization_scale">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="allowance_fraction_median">
      <value value="0"/>
      <value value="1"/>
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment tax N 2000 5000 10000" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>taxrate</metric>
    <metric>mean_wealth_stop_tick</metric>
    <metric>share_top10_stop_tick</metric>
    <metric>share_top1_stop_tick</metric>
    <metric>share_top01_stop_tick</metric>
    <metric>gini_stop_tick</metric>
    <metric>tailexp_top10_stop_tick</metric>
    <metric>tailexp_top5_stop_tick</metric>
    <metric>tailexp_top1_stop_tick</metric>
    <metric>volatility_past_tick_1</metric>
    <metric>volatility_past_tick_2</metric>
    <metric>volatility_past_tick_3</metric>
    <metric>stillinbottom50_past_tick_1</metric>
    <metric>stillinbottom50_past_tick_2</metric>
    <metric>stillinbottom50_past_tick_3</metric>
    <metric>stillin50to90_past_tick_1</metric>
    <metric>stillin50to90_past_tick_2</metric>
    <metric>stillin50to90_past_tick_3</metric>
    <metric>stillintop10_past_tick_1</metric>
    <metric>stillintop10_past_tick_2</metric>
    <metric>stillintop10_past_tick_3</metric>
    <metric>stillintop1_past_tick_1</metric>
    <metric>stillintop1_past_tick_2</metric>
    <metric>stillintop1_past_tick_3</metric>
    <metric>growth_rate_all</metric>
    <metric>growth_rate_past_tick_1</metric>
    <metric>growth_rate_past_tick_2</metric>
    <metric>growth_rate_past_tick_3</metric>
    <metric>taxshare_stop_tick</metric>
    <metric>fraction_paying_tax_stop_tick</metric>
    <enumeratedValueSet variable="stop_tick">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="past_tick_1">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="past_tick_2">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="past_tick_3">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="2000"/>
      <value value="5000"/>
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mu">
      <value value="0.02"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tax_regime">
      <value value="&quot;wealth&quot;"/>
      <value value="&quot;wealth gains&quot;"/>
      <value value="&quot;realized wealth gains&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="base_taxrate_wealth" first="0" step="0.001" last="0.05"/>
    <enumeratedValueSet variable="realization_scale">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="allowance_fraction_median">
      <value value="0"/>
      <value value="1"/>
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment tax N 100K" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>taxrate</metric>
    <metric>mean_wealth_stop_tick</metric>
    <metric>mean_wealth_past_tick_1</metric>
    <metric>mean_wealth_past_tick_2</metric>
    <metric>mean_wealth_past_tick_3</metric>
    <metric>share_top10_stop_tick</metric>
    <metric>share_top10_past_tick_1</metric>
    <metric>share_top10_past_tick_2</metric>
    <metric>share_top10_past_tick_3</metric>
    <metric>share_top1_stop_tick</metric>
    <metric>share_top1_past_tick_1</metric>
    <metric>share_top1_past_tick_2</metric>
    <metric>share_top1_past_tick_3</metric>
    <metric>share_top01_stop_tick</metric>
    <metric>share_top01_past_tick_1</metric>
    <metric>share_top01_past_tick_2</metric>
    <metric>share_top01_past_tick_3</metric>
    <metric>gini_stop_tick</metric>
    <metric>gini_past_tick_1</metric>
    <metric>gini_past_tick_2</metric>
    <metric>gini_past_tick_3</metric>
    <metric>tailexp_top10_stop_tick</metric>
    <metric>tailexp_top10_past_tick_1</metric>
    <metric>tailexp_top10_past_tick_2</metric>
    <metric>tailexp_top10_past_tick_3</metric>
    <metric>tailexp_top5_stop_tick</metric>
    <metric>tailexp_top5_past_tick_1</metric>
    <metric>tailexp_top5_past_tick_2</metric>
    <metric>tailexp_top5_past_tick_3</metric>
    <metric>tailexp_top1_stop_tick</metric>
    <metric>tailexp_top1_past_tick_1</metric>
    <metric>tailexp_top1_past_tick_2</metric>
    <metric>tailexp_top1_past_tick_3</metric>
    <metric>volatility_past_tick_1</metric>
    <metric>volatility_past_tick_2</metric>
    <metric>volatility_past_tick_3</metric>
    <metric>stillinbottom50_past_tick_1</metric>
    <metric>stillinbottom50_past_tick_2</metric>
    <metric>stillinbottom50_past_tick_3</metric>
    <metric>stillin50to90_past_tick_1</metric>
    <metric>stillin50to90_past_tick_2</metric>
    <metric>stillin50to90_past_tick_3</metric>
    <metric>stillintop10_past_tick_1</metric>
    <metric>stillintop10_past_tick_2</metric>
    <metric>stillintop10_past_tick_3</metric>
    <metric>stillintop1_past_tick_1</metric>
    <metric>stillintop1_past_tick_2</metric>
    <metric>stillintop1_past_tick_3</metric>
    <metric>growth_rate_all</metric>
    <metric>growth_rate_past_tick_1</metric>
    <metric>growth_rate_past_tick_2</metric>
    <metric>growth_rate_past_tick_3</metric>
    <metric>taxshare_stop_tick</metric>
    <metric>taxshare_past_tick_1</metric>
    <metric>taxshare_past_tick_2</metric>
    <metric>taxshare_past_tick_3</metric>
    <metric>fraction_paying_tax_stop_tick</metric>
    <metric>fraction_paying_tax_past_tick_1</metric>
    <metric>fraction_paying_tax_past_tick_2</metric>
    <metric>fraction_paying_tax_past_tick_3</metric>
    <enumeratedValueSet variable="stop_tick">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="past_tick_1">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="past_tick_2">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="past_tick_3">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="100000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mu">
      <value value="0.02"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tax_regime">
      <value value="&quot;wealth&quot;"/>
      <value value="&quot;wealth gains&quot;"/>
      <value value="&quot;realized wealth gains&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="base_taxrate_wealth" first="0" step="0.001" last="0.05"/>
    <enumeratedValueSet variable="realization_scale">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="allowance_fraction_median">
      <value value="0"/>
      <value value="1"/>
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment tax N 1000 long" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>taxrate</metric>
    <metric>mean_wealth_stop_tick</metric>
    <metric>share_top10_stop_tick</metric>
    <metric>share_top1_stop_tick</metric>
    <metric>share_top01_stop_tick</metric>
    <metric>gini_stop_tick</metric>
    <metric>tailexp_top10_stop_tick</metric>
    <metric>tailexp_top5_stop_tick</metric>
    <metric>tailexp_top1_stop_tick</metric>
    <metric>volatility_past_tick_1</metric>
    <metric>volatility_past_tick_2</metric>
    <metric>volatility_past_tick_3</metric>
    <metric>stillinbottom50_past_tick_1</metric>
    <metric>stillinbottom50_past_tick_2</metric>
    <metric>stillinbottom50_past_tick_3</metric>
    <metric>stillin50to90_past_tick_1</metric>
    <metric>stillin50to90_past_tick_2</metric>
    <metric>stillin50to90_past_tick_3</metric>
    <metric>stillintop10_past_tick_1</metric>
    <metric>stillintop10_past_tick_2</metric>
    <metric>stillintop10_past_tick_3</metric>
    <metric>stillintop1_past_tick_1</metric>
    <metric>stillintop1_past_tick_2</metric>
    <metric>stillintop1_past_tick_3</metric>
    <metric>growth_rate_all</metric>
    <metric>growth_rate_past_tick_1</metric>
    <metric>growth_rate_past_tick_2</metric>
    <metric>growth_rate_past_tick_3</metric>
    <metric>taxshare_stop_tick</metric>
    <metric>fraction_paying_tax_stop_tick</metric>
    <enumeratedValueSet variable="stop_tick">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="past_tick_1">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="past_tick_2">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="past_tick_3">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mu">
      <value value="0.02"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tax_regime">
      <value value="&quot;wealth&quot;"/>
      <value value="&quot;wealth gains&quot;"/>
      <value value="&quot;realized wealth gains&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="base_taxrate_wealth" first="0" step="0.001" last="0.05"/>
    <enumeratedValueSet variable="realization_scale">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="allowance_fraction_median">
      <value value="0"/>
      <value value="1"/>
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment tax more" repetitions="900" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>taxrate</metric>
    <metric>mean_wealth_stop_tick</metric>
    <metric>mean_wealth_past_tick_1</metric>
    <metric>mean_wealth_past_tick_2</metric>
    <metric>mean_wealth_past_tick_3</metric>
    <metric>share_top10_stop_tick</metric>
    <metric>share_top10_past_tick_1</metric>
    <metric>share_top10_past_tick_2</metric>
    <metric>share_top10_past_tick_3</metric>
    <metric>share_top1_stop_tick</metric>
    <metric>share_top1_past_tick_1</metric>
    <metric>share_top1_past_tick_2</metric>
    <metric>share_top1_past_tick_3</metric>
    <metric>share_top01_stop_tick</metric>
    <metric>share_top01_past_tick_1</metric>
    <metric>share_top01_past_tick_2</metric>
    <metric>share_top01_past_tick_3</metric>
    <metric>gini_stop_tick</metric>
    <metric>gini_past_tick_1</metric>
    <metric>gini_past_tick_2</metric>
    <metric>gini_past_tick_3</metric>
    <metric>tailexp_top10_stop_tick</metric>
    <metric>tailexp_top10_past_tick_1</metric>
    <metric>tailexp_top10_past_tick_2</metric>
    <metric>tailexp_top10_past_tick_3</metric>
    <metric>tailexp_top5_stop_tick</metric>
    <metric>tailexp_top5_past_tick_1</metric>
    <metric>tailexp_top5_past_tick_2</metric>
    <metric>tailexp_top5_past_tick_3</metric>
    <metric>tailexp_top1_stop_tick</metric>
    <metric>tailexp_top1_past_tick_1</metric>
    <metric>tailexp_top1_past_tick_2</metric>
    <metric>tailexp_top1_past_tick_3</metric>
    <metric>volatility_past_tick_1</metric>
    <metric>volatility_past_tick_2</metric>
    <metric>volatility_past_tick_3</metric>
    <metric>stillinbottom50_past_tick_1</metric>
    <metric>stillinbottom50_past_tick_2</metric>
    <metric>stillinbottom50_past_tick_3</metric>
    <metric>stillin50to90_past_tick_1</metric>
    <metric>stillin50to90_past_tick_2</metric>
    <metric>stillin50to90_past_tick_3</metric>
    <metric>stillintop10_past_tick_1</metric>
    <metric>stillintop10_past_tick_2</metric>
    <metric>stillintop10_past_tick_3</metric>
    <metric>stillintop1_past_tick_1</metric>
    <metric>stillintop1_past_tick_2</metric>
    <metric>stillintop1_past_tick_3</metric>
    <metric>growth_rate_all</metric>
    <metric>growth_rate_past_tick_1</metric>
    <metric>growth_rate_past_tick_2</metric>
    <metric>growth_rate_past_tick_3</metric>
    <metric>taxshare_stop_tick</metric>
    <metric>taxshare_past_tick_1</metric>
    <metric>taxshare_past_tick_2</metric>
    <metric>taxshare_past_tick_3</metric>
    <metric>fraction_paying_tax_stop_tick</metric>
    <metric>fraction_paying_tax_past_tick_1</metric>
    <metric>fraction_paying_tax_past_tick_2</metric>
    <metric>fraction_paying_tax_past_tick_3</metric>
    <enumeratedValueSet variable="stop_tick">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="past_tick_1">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="past_tick_2">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="past_tick_3">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="1000"/>
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mu">
      <value value="0.02"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tax_regime">
      <value value="&quot;wealth&quot;"/>
      <value value="&quot;wealth gains&quot;"/>
      <value value="&quot;realized wealth gains&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="base_taxrate_wealth" first="0" step="0.001" last="0.05"/>
    <enumeratedValueSet variable="realization_scale">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="allowance_fraction_median">
      <value value="0"/>
      <value value="1"/>
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment tax N 10000" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>taxrate</metric>
    <metric>mean_wealth_stop_tick</metric>
    <metric>share_top10_stop_tick</metric>
    <metric>share_top1_stop_tick</metric>
    <metric>share_top01_stop_tick</metric>
    <metric>gini_stop_tick</metric>
    <metric>tailexp_top10_stop_tick</metric>
    <metric>tailexp_top5_stop_tick</metric>
    <metric>tailexp_top1_stop_tick</metric>
    <metric>volatility_past_tick_1</metric>
    <metric>volatility_past_tick_2</metric>
    <metric>volatility_past_tick_3</metric>
    <metric>stillinbottom50_past_tick_1</metric>
    <metric>stillinbottom50_past_tick_2</metric>
    <metric>stillinbottom50_past_tick_3</metric>
    <metric>stillin50to90_past_tick_1</metric>
    <metric>stillin50to90_past_tick_2</metric>
    <metric>stillin50to90_past_tick_3</metric>
    <metric>stillintop10_past_tick_1</metric>
    <metric>stillintop10_past_tick_2</metric>
    <metric>stillintop10_past_tick_3</metric>
    <metric>stillintop1_past_tick_1</metric>
    <metric>stillintop1_past_tick_2</metric>
    <metric>stillintop1_past_tick_3</metric>
    <metric>growth_rate_all</metric>
    <metric>growth_rate_past_tick_1</metric>
    <metric>growth_rate_past_tick_2</metric>
    <metric>growth_rate_past_tick_3</metric>
    <metric>taxshare_stop_tick</metric>
    <metric>fraction_paying_tax_stop_tick</metric>
    <enumeratedValueSet variable="stop_tick">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="past_tick_1">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="past_tick_2">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="past_tick_3">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mu">
      <value value="0.02"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tax_regime">
      <value value="&quot;wealth&quot;"/>
      <value value="&quot;wealth gains&quot;"/>
      <value value="&quot;realized wealth gains&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="base_taxrate_wealth" first="0" step="0.001" last="0.05"/>
    <enumeratedValueSet variable="realization_scale">
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="allowance_fraction_median">
      <value value="0"/>
      <value value="1"/>
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
