# Analysis

library(Epi)
library(lmtest)
library(ggplot2)
library(tidyverse)

## The effect on the number of people under 10 minutes away from the target hospital

model_glm = glm(golden ~ method,
                family=quasipoisson(),
                data=time_by_method)

summary(model_glm)
round(ci.lin(model_glm, Exp=TRUE),2)

### The effect of the method used on the average time to arrival

best_fit = lm(time ~ method * poly(distance, 2),
                  data=time_by_method)


summary(best_fit)

# Each distance level a kilometer
model = lm(time ~ method,
           data = filter(time_by_method, distance>3))

model = lm(time ~ method,
           data = filter(time_by_method, time>600))

model = lm(time ~ method * group)

summary(model)

kplot(model_lineal)
plot(resid(model_lineal))

time_by_method$predict = predict(best_fit)

ggplot(time_by_method) +
#  geom_point(aes(distance, time, color=method), alpha=1, size=0.01) +
  geom_smooth(aes(distance, time, color=method), method='loess', se = FALSE) +
  geom_line(aes(distance, predict, group=method))
  

ggplot(time_by_method) +
  geom_histogram(aes(x=time, fill=method), alpha=0.5, position='identity') +
  geom_vline(aes(xintercept=mean(time)))

ggplot(time_by_method) +
  geom_boxplot(aes(x=method, y=time, color=method))
