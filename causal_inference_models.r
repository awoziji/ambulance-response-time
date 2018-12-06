# Analysis: Hospitals service areas vs google's fastest route

library(Epi)
library(lmtest)
library(ggplot2)
library(tidyverse)

# The effect of the method chosen on ambulance time to arrival

model_one = glm(time ~ strategy + distance,
                family = gaussian(),
                data = time_by_strategy)

summary(model_one)
round(ci.lin(model_one),4)

# Interpretation:
# Overall, after adjusting for the distance, using google's fastest route 
# takes out 17 seconds on the average trip duration

# ---------------------------------------------------------------------------------

# Analysis stratified by distance between each place to the hospital of its service
# area

for (i in 0:11) {
  model_i = glm(time ~ strategy,
                subset = time_by_method$group == i,
                family=gaussian(),
                data=time_by_strategy)
  print(round(ci.lin(model_i),2))
}

#   Strata               Estimate  p-val  lowerCI  upperCI Samples
# group 0:  methodfastest   00.00      1    -8.64     8.64     562
# group 1:  methodfastest  -00.85    0.8    -7.35     5.66    2094
# group 2:  methodfastest  -15.80      0   -22.72    -8.88    2446
# group 3:  methodfastest  -81.21      0   -93.64   -68.77    1258
# group 4:  methodfastest  -98.39      0  -122.27   -74.51     502
# group 5:  methodfastest -100.26      0  -155.90   -44.63     106
# group 6:  methodfastest  -72.00   0.34  -219.94    75.94      22
# group 7:  methodfastest   -51.3   0.28  -145.07    42.47      40
# group 8:  methodfastest  -62.64   0.02  -117.23    -8.05      22
# group 9:  methodfastest -130.86      0  -168.47   -93.24      42
# group 10: methodfastest -132.33      0  -178.19   -86.48       6
# group 11: methodfastest  -770.0      0  -779.70  -760.30       4

# Interpretetion
# For each strata of data according to the distance to the referenc hospital, the
# effect of the method is significant and grater in those farthest.

# ---------------------------------------------------------------------------------

# Change in the number of people that are under 10 minutes away from a hospital

model_two = glm(under ~ strategy + distance,
                family = quasipoisson(),
                data = time_by_strategy)

summary(model_two)
round(ci.lin(model_two, Exp=T),4)

# Interpretation
# Using gmaps strategy, people that are under 10 minutes away from a hospital grow
# by 7% (202.211 persons)

# ---------------------------------------------------------------------------------

# Time save for those city blocks that changed their target hospital

model_thr = glm(time ~ strategy + distance,
                family=gaussian(),
                data=filter(time_by_strategy, change == 1))

summary(model_thr)
round(ci.lin(model_thr, Exp=F),4)

# Interpretation
# For those places where google maps routing service found a faster hospital other
# than the hospitla from the referral area, the time saved was 109 seconds (CI95: 
# -119 - -99 seconds).

# ---------------------------------------------------------------------------------

# Model with the best fit

best_fit = lm(time ~ strategy * poly(distance, 2),
              data=time_by_strategy)

# Adjusted Rsqr = 0.845
summary(best_fit)
time_by_method$predict = predict(best_fit)

# ---------------------------------------------------------------------------------

# Visualizations

# time by distance with results from predictions drawn with best_fit model
ggplot(time_by_strategy) +
  geom_point(aes(distance, time, color=strategy), alpha=1, size=0.01) +
  geom_line(aes(distance, predict, group=strategy))
