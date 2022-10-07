library("tidyverse")

df <- read.csv("experiment_results.csv")

summary(df)

cols_factors <- c("subject", "path", "app_type", "repetition")
df[cols_factors] <- lapply(df[cols_factors], as.factor)
cols_numeric <- names(df %>% select_if(negate(is.factor)))
df[cols_numeric] <- lapply(df[cols_numeric], as.numeric)

summary(df)
