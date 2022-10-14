#! /usr/bin/Rscript

# Clear environment
rm(list = ls())

# FIRST: Install libraries using requirements.R

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(qqplotr))
library(effsize)
library(bestNormalize)
library(showtext)

textTheme <- theme()
tryCatch({
    font.add("CMU", "/usr/share/fonts/cm-unicode/cmunrm.otf")
    showtext.auto()
    textTheme <- theme(text=element_text(family="CMU"))
})
unlink("plots/*", recursive = TRUE)
dir.create("plots", showWarnings = FALSE)

# Load raw dataset
df <- read.csv("experiment_results.csv")
# Prepare dataset
cols_factors <- c("subject", "path", "app_type", "repetition")
df[cols_factors] <- lapply(df[cols_factors], as.factor)
cols_numeric <- names(df %>% select_if(negate(is.factor)))
df[cols_numeric] <- lapply(df[cols_numeric], as.numeric)

nan_rows_count <- df %>% filter(any(is.na(.))) %>% nrow()
df <- df %>% filter_all(all_vars(!is.na(.)))
cat("Removed", sum(nan_rows_count), "rows with NAs\n")

# Dataset summary
summary(df)

# Dependent variable column name to plot axis title mapping
fmt_var = c(
  "energy_consumption" = "Energy consumption (J)",
  "network_traffic" = "Network traffic (B)",
  "mean_cpu_load" = "Mean CPU load (%)",
  "mean_mem_usage" = "Mean memory usage (kB)",
  "mean_frame_time" = "Mean frame time (ns)"
)

# Subject value to plot legend mapping
fmt_sub = c(
    "coupang" = "Coupang",
    "espn" = "ESPN",
    "linkedin" = "LinkedIn",
    "pinterest" = "Pinterest",
    "shopee" = "Shopee",
    "soundcloud" = "SoundCloud",
    "spotify" = "Spotify",
    "twitch" = "Twitch",
    "weather" = "The Weather Channel",
    "youtube" = "YouTube"
)
# For plotting
df$Subject <- as.factor(fmt_sub[as.character(df$subject)])
SubjectShapes <- 15 + c(0, 0, 0, 1, 1, 0, 1, 1, 0, 1) # By category for sorted Subject
# SubjectColors <- c(4, 2, 3, 3, 4, 5, 5, 2, 6, 6) # By category for sorted Subject
SubjectColors <- c(
    "#e6194B", "#3cb44b", "#4363d8", "#4363d8", 
    "#e6194B", "#f58231", "#f58231", "#3cb44b", 
    "#42d4f4", "#42d4f4") # By category for sorted Subject

alpha <- 0.05
cat("For all tests: alpha =", alpha, "\n\n")

plot_data <- function(df, var, var_title) {
    ggplot(df_var, aes(x = app_type, y = .data[[var]])) +
        # geom_violin(trim = T) +
        geom_jitter(aes(color = Subject, shape = Subject), width = 0.35, height = 0, size = 2) +
        geom_boxplot(alpha = 0) +
        labs(x = "APP TYPE", y = var_title) +
        scale_shape_manual(values = SubjectShapes) +
        scale_color_manual(values = SubjectColors) +
        theme(text = element_text(size = 21)) + textTheme +
        theme(legend.position = "none")
    suppressMessages(ggsave(filename=paste0("plots/boxplot_", var, ".pdf")))
}

plot_density <- function(df, var, var_title) {
    ggplot(df_var, aes(x = .data[[var]], fill = app_type)) +
        geom_density(alpha = 0.5) +
        labs(x = var_title, y = "Density", fill = "APP TYPE") + 
        theme(text = element_text(size = 21)) + textTheme +
        theme(legend.position = c(0.8, 0.85))
    suppressMessages(ggsave(filename=paste0("plots/density_", var, ".pdf")))
}

plot_qq <- function(df, var, filename) {
    ggplot(data = df, mapping = aes(sample = .data[[var]])) +
        stat_qq_band() +
        stat_qq_line() +
        stat_qq_point() +
        # theme(text = element_text(size = 24)) + textTheme +
        # labs(x = "Theoretical Quantiles", y = "Sample Quantiles")
        # No axis ticks
        theme(axis.ticks.x = element_blank(), axis.ticks.y = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank()) + 
        labs(x=element_blank(), y=element_blank())
    suppressMessages(ggsave(filename=filename))
}

test_parametric <- function(df_var_native, df_var_web, var) {
    # Perform paired t-test
    t_test <- t.test(df_var_native[[var]], df_var_web[[var]], paired = T)
    cat("Paired t-test: t = ", t_test$statistic, ", p-value = ", t_test$p.value, "\n")
    cat("Means are ", ifelse(t_test$p.value < alpha, "", "not "), "different\n", sep = "")
    # Use Cohen's d to interpret effect size
    d <- cohen.d(df_var_native[[var]], df_var_web[[var]], conf.level=1-alpha)$estimate
    # small (d = 0.2), medium (d = 0.5), and large (d = 0.8) according to https://doi.org/10.4324/9780203771587
    effect <- ifelse(d < 0.2, "negligible", ifelse(d < 0.5, "small", ifelse(d < 0.8, "medium", "large")))
    cat("Effect size using Cohen's d: estimate = ", d, " (", effect, ")\n", sep = "")
}

test_non_parametric <- function(df_var_native, df_var_web, var) {
    # Perform Wilcoxon signed-rank test
    wilcox_test <- wilcox.test(df_var_native[[var]], df_var_web[[var]], paired = T)
    cat("Wilcoxon signed-rank test: W = ", wilcox_test$statistic, ", p-value = ", wilcox_test$p.value, "\n")
    cat("Means are ", ifelse(wilcox_test$p.value < alpha, "", "not "), "different\n", sep = "")
    # Use Cliff's delta to interpret effect size
    d <- cliff.delta(df_var_native[[var]], df_var_web[[var]], conf.level=1-alpha)$estimate
    # small (d = 0.147), medium (d = 0.33), and large (d = 0.474) according to https://www.bibsonomy.org/bibtex/216a5c27e770147e5796719fc6b68547d/kweiand
    effect <- ifelse(abs(d) < 0.147, "negligible", ifelse(abs(d) < 0.33, "small", ifelse(abs(d) < 0.474, "medium", "large")))
    cat("Effect size using Cliff's delta: estimate = ", d, " (", effect, ")\n", sep = "")
}

# Data analysis per dependent variable
for (var in cols_numeric) {
    var_title <- fmt_var[var]
    cat("========== ", var, ": ", var_title, " ==========\n", sep = "")
    df_var <- df %>% select_if(negate(is.numeric))
    df_var[[var]] <- df[[var]]

    cat("1. Boxplot native vs. web\n")
    plot_data(df, var, fmt_var[var])
    df_var_native <- df_var %>% filter(app_type == "native")
    df_var_web <- df_var %>% filter(app_type == "web")

    cat("2. Density plot native vs. web\n")
    plot_density(df_var_native, var, var_title)

    cat("3. QQ plots for native and web\n")
    plot_qq(df_var_native, var, paste0("plots/qq_native_", var, ".pdf"))
    plot_qq(df_var_web, var, paste0("plots/qq_web_", var, ".pdf"))

    cat("4. Check for normality\n")
    norm_native <- shapiro.test(df_var_native[[var]])
    is_normal_native <- norm_native$p.value > alpha
    norm_web <- shapiro.test(df_var_web[[var]])
    is_normal_web <- norm_web$p.value > alpha
    
    cat(var, " web is ", ifelse(is_normal_web, "", "not "), "normal using Shapiro-Wilk (p-value: ", norm_web$p.value, ")\n", sep = "")
    if (!is_normal_web) {
        # cat("Web data is not normal, using bestNormalize() to normalize\n")
        # BN_obj <- bestNormalize(df_var_web[[var]])
        # print(BN_obj)
        # var_web_normalized <- predict(BN_obj)
    }

    cat("5. Compare means of native and web\n")

    # Drop value from longer (native or ) to make them equal length
    n_dropped <- abs(nrow(df_var_native) - nrow(df_var_web))
    if (nrow(df_var_native) > nrow(df_var_web)) {
        df_var_native <- df_var_native %>% slice(1:(nrow(df_var_native) - n_dropped))
    } else if (nrow(df_var_web) > nrow(df_var_native)) {
        df_var_web <- df_var_web %>% slice(1:(nrow(df_var_web) - n_dropped))
    }
    if (n_dropped > 0) {
        cat("Dropped ", n_dropped, " values from longer dataset to make them equal length\n", sep = "")
    }


    if (is_normal_native && is_normal_web) {
        test_parametric(df_var_native, df_var_web, var)
    }
    else {
        test_non_parametric(df_var_native, df_var_web, var)
    }
    cat("\n")
}
warnings()
