#! /usr/bin/Rscript

# FIRST: Install libraries using requirements.R

# Set up clean, reproducible environment
rm(list = ls())
set.seed(123)

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(qqplotr))
library(effsize)
library(bestNormalize)
suppressPackageStartupMessages(library(showtext))

textTheme <- theme()
tryCatch({
    font_add("CMU", "/usr/share/fonts/cm-unicode/cmunrm.otf")
    showtext_auto()
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
suppressWarnings(df[cols_numeric] <- lapply(df[cols_numeric], as.numeric)) # Suppress warnings about NAs

remove_invalid <- function(df, cols_numeric) {
    cat("Total number of rows in dataset:", nrow(df), "\n")
    removed_rows_count = 0
    nonas_df <- data.frame()
    for (row in 1:nrow(df)) {
        row <- df[row, ]
        row_min <- min(row[cols_numeric]) # Values must be positive
        if (any(is.na(row)) || 0 >= row_min) {
            removed_rows_count = removed_rows_count + 1
        }
        else {
            nonas_df <- rbind(nonas_df, row)
        }
    }
    df <- nonas_df
    cat("Removed", removed_rows_count, "rows with NaNs, zeros or negative values (invalid)\n")

    # For each subject in df_var, get all rows for native and web apps
    cat("Ensuring same number of runs for each app type\n")
    n_rows_removed <- 0
    df_native <- data.frame()
    df_web <- data.frame()
    for (s in unique(df$subject)) {
        df_subject <- df %>% filter(subject == s)
        # Get rows for native apps and web apps (each in random order for unbiased selection)
        df_subject_native <- df_subject %>% filter(app_type == "native")
        df_subject_native <- df_subject_native[sample(nrow(df_subject_native)), ]
        df_subject_web <- df_subject %>% filter(app_type == "web")
        df_subject_web <- df_subject_web[sample(nrow(df_subject_web)), ]
        n_rows_removed_subject <- 0
        n_rows_native <- nrow(df_subject_native)
        n_rows_web <- nrow(df_subject_web)
        # Make same length by removing rows from the longer one and count towards n_rows_removed
        if (n_rows_native > n_rows_web) {
            df_subject_native <- df_subject_native[1:nrow(df_subject_web),]
            n_rows_removed_subject <- nrow(df_subject_native) - nrow(df_subject_web)
        } else if (n_rows_web > n_rows_native) {
            df_subject_web <- df_subject_web[1:nrow(df_subject_native),]
            n_rows_removed_subject <- nrow(df_subject_web) - nrow(df_subject_native)
        }
        # Edge case: empty dataframes
        if (nrow(df_subject_native) == 0 || nrow(df_subject_web) == 0) {
            df_subject_native <- data.frame()
            df_subject_web <- data.frame()
        }
        assertthat::assert_that(nrow(df_subject_native) == nrow(df_subject_web))
        df_native <- rbind(df_native, df_subject_native)
        df_web <- rbind(df_web, df_subject_web)
        n_rows_removed <- n_rows_removed + n_rows_removed_subject
        cat(" - Removed ", n_rows_removed_subject, " rows for subject ", s, sep = "")
        cat(" (", nrow(df_subject_native) + nrow(df_subject_web), " rows from ", n_rows_native, " native and ", n_rows_web, " web)\n", sep = "")
    }
    # Combine native and web apps into df
    df <- rbind(df_native, df_web)
    cat("Total removed ", n_rows_removed, " rows\n")
    cat("Remaining rows: ", nrow(df), "\n\n")
    return(df)
}

df <- remove_invalid(df, cols_numeric)

# Dataset summary
# summary(df)
cat("Summary for LaTeX report: (native and web in same row)\n")
df_native <- df %>% filter(app_type == "native") %>% select_if(is.numeric)
df_web <- df %>% filter(app_type == "web") %>% select_if(is.numeric)

print_latex_tab_row <- function(name, func) {
    cat("\\textbf{", name, "} & ", sep = "")
    values <- apply(df_native, 2, func)
    for (i in 1:length(values)) {
        cat(values[i], if (i == length(values)) "" else "& ")
    }
    cat("& ")
    values <- apply(df_web, 2, func)
    for (i in 1:length(values)) {
        cat(values[i], if (i == length(values)) "" else "& ")
    }
    cat("\\\\\n")
}
print_latex_tab_row("Mean", mean)
print_latex_tab_row("Standard deviation", sd)
print_latex_tab_row("Minimum", min)
print_latex_tab_row("25\\% quantile", function(x) quantile(x, 0.25))
print_latex_tab_row("Median", median)
print_latex_tab_row("75\\% quantile", function(x) quantile(x, 0.75))
print_latex_tab_row("Maximum", max)



# Dependent variable column name to plot axis title mapping
fmt_var = c(
  "energy_consumption" = "Energy consumption (J)",
  "network_traffic" = "Network traffic (B)",
  "mean_cpu_load" = "Mean CPU load (%)",
  "mean_mem_usage" = "Mean memory usage (kB)",
  "median_frame_time" = "Median frame time (ns)"
)

# Subject value to plot legend mapping
fmt_sub = c(
    "espn" = "ESPN",
    "weather" = "The Weather Channel",
    "linkedin" = "LinkedIn",
    "pinterest" = "Pinterest",
    "coupang" = "Coupang",
    "shopee" = "Shopee",
    "soundcloud" = "SoundCloud",
    "spotify" = "Spotify",
    "twitch" = "Twitch",
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
cat("\nFor all tests: alpha =", alpha, " (alpha/2 for two-sided tests)\n\n")

plot_data <- function(df, var, var_title) {
    ggplot(df_var, aes(x = app_type, y = .data[[var]])) +
        # geom_violin(trim = T) +
        geom_jitter(aes(color = Subject, shape = Subject), width = 0.35, height = 0, size = 2) +
        geom_boxplot(alpha = 0) +
        stat_summary(fun=mean, geom="point", shape=5, size=5, color="black") +
        labs(x = "APP TYPE", y = var_title) +
        scale_shape_manual(values = SubjectShapes) +
        scale_color_manual(values = SubjectColors) +
        theme(text = element_text(size = 21)) + textTheme +
        theme(legend.position = "none") +
        (if (var == "network_traffic") scale_y_log10() else scale_y_continuous())
    suppressMessages(ggsave(filename=paste0("plots/boxplot_", var, ".pdf")))
}

plot_density <- function(df, var, var_title) {
    ggplot(df_var, aes(x = .data[[var]], fill = app_type)) +
        geom_density(alpha = 0.5) +
        labs(x = var_title, y = "Density", fill = "APP TYPE") + 
        theme(text = element_text(size = 21)) + textTheme +
        theme(legend.position = c(0.8, 0.85)) +
        (if (var == "network_traffic") scale_x_log10() else scale_x_continuous())
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
    cat("Means are ", ifelse(t_test$p.value < alpha/2, "", "not "), "different\n", sep = "")
    # Use Cohen's d to interpret effect size
    d <- cohen.d(df_var_native[[var]], df_var_web[[var]], conf.level=1-alpha/2)$estimate
    # small (d = 0.2), medium (d = 0.5), and large (d = 0.8) according to https://doi.org/10.4324/9780203771587
    effect <- ifelse(d < 0.2, "negligible", ifelse(d < 0.5, "small", ifelse(d < 0.8, "medium", "large")))
    cat("Effect size using Cohen's d: estimate = ", d, " (", effect, ")\n", sep = "")
}

df_non_parametric_results <- data.frame()

test_non_parametric <- function(df_var_native, df_var_web, var) {
    # Perform Wilcoxon signed-rank test
    wilcox_test <- wilcox.test(df_var_native[[var]], df_var_web[[var]], paired = T)
    cat("Wilcoxon signed-rank test: W = ", wilcox_test$statistic, ", p-value = ", wilcox_test$p.value, "\n")
    cat("Locations are ", ifelse(wilcox_test$p.value < alpha/2, "", "not "), "different\n", sep = "")
    # Use Cliff's delta to interpret effect size
    d <- cliff.delta(df_var_native[[var]], df_var_web[[var]], conf.level=1-alpha/2)$estimate
    # small (d = 0.147), medium (d = 0.33), and large (d = 0.474) according to https://www.bibsonomy.org/bibtex/216a5c27e770147e5796719fc6b68547d/kweiand
    effect <- ifelse(abs(d) < 0.147, "negligible", ifelse(abs(d) < 0.33, "small", ifelse(abs(d) < 0.474, "medium", "large")))
    cat("Effect size using Cliff's delta: estimate = ", d, " (", effect, ")\n", sep = "")
    df_non_parametric_results <<- rbind(
        df_non_parametric_results,
        data.frame(var = var, W = wilcox_test$statistic, p_value = wilcox_test$p.value, effect_size=d, interpretation=effect))
}

df_normality_test_results <- data.frame()


# Data analysis per dependent variable
for (var in cols_numeric) {
    var_title <- fmt_var[var]
    cat("========== ", var, ": ", var_title, " ==========\n", sep = "")
    df_var <- df %>% select_if(negate(is.numeric))
    df_var[[var]] <- df[[var]]
    df_var_native <- df_var %>% filter(app_type == "native")
    df_var_native <- df_var_native[order(df_var_native$subject),]
    df_var_web <- df_var %>% filter(app_type == "web")
    df_var_web <- df_var_web[order(df_var_web$subject),]

    cat("1. Boxplot native vs. web\n")
    plot_data(df, var, fmt_var[var])

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
    df_normality_test_results <- rbind(
        df_normality_test_results,
        data.frame(var = var, app_type = "native", p_value = norm_native$p.value, is_normal = is_normal_native),
        data.frame(var = var, app_type = "web", p_value = norm_web$p.value, is_normal = is_normal_web))
    
    cat(var, " web is ", ifelse(is_normal_web, "", "not "), "normal using Shapiro-Wilk (p-value: ", norm_web$p.value, ")\n", sep = "")
    if (!is_normal_web) {
        # cat("Web data is not normal, using bestNormalize() to normalize\n")
        # BN_obj <- bestNormalize(df_var_web[[var]])
        # print(BN_obj)
        # var_web_normalized <- predict(BN_obj)
    }

    cat("5. Compare means/locations of native and web\n")
    if (is_normal_native && is_normal_web) {
        test_parametric(df_var_native, df_var_web, var)
    }
    else {
        test_non_parametric(df_var_native, df_var_web, var)
    }
    cat("\n")
}

fmt_float_sci_latex <- function(x, mantissa_digits = 3) {
    factor <- 10^floor(log10(abs(x)))
    exponent <- floor(log10(factor))
    mantissa <- x / factor
    mantissa <- round(mantissa, mantissa_digits)
    return (paste0("$", mantissa, "\\times 10^{", exponent, "}$"))
}

cat("\nNormality test results for LaTeX report:\n")
for (i in 1:nrow(df_normality_test_results)) {
    var <- df_normality_test_results[i, "var"]
    fmtd_var <- gsub("%", "\\\\%", fmt_var[var])
    fmtd_var <- strsplit(fmtd_var, "\\(")[[1]][1]
    if (i %% 2 == 1) {
        if (i > 1) {
            cat("\\hdashline\n")
        }
        cat("\\multirow{2}{*}{", fmtd_var, "}", sep = "")
    }
    fmtd_app_type <- df_normality_test_results[i, "app_type"]
    p_value <- fmt_float_sci_latex(df_normality_test_results[i, "p_value"]) 
    fmtd_is_normal <- ifelse(df_normality_test_results[i, "is_normal"], "yes", "no") 
    cat(" & ", fmtd_app_type, " & ", p_value, " & ", fmtd_is_normal, " \\\\\n", sep = "")
}
cat("\n")

cat("\nNon-parametric test results for LaTeX report:\n")
short_varnames = c("e", "n", "c", "m", "f")
for (i in 1:nrow(df_non_parametric_results)) {
    var <- short_varnames[i]
    if (i == 2) {
        if (i > 1) {
            cat("\\hdashline\n")
        }
    }
    W <- df_non_parametric_results[i, "W"]
    p_value <- df_non_parametric_results[i, "p_value"]
    p_value_fmtd <- fmt_float_sci_latex(p_value)
    effect_size <- df_non_parametric_results[i, "effect_size"] 
    effect_size_interpretation <- df_non_parametric_results[i, "interpretation"]
    rq <- ifelse(i == 1, "RQ1", "RQ2")
    if (p_value < alpha/2) {
        p_value_fmtd <- substr(p_value_fmtd, 2, nchar(p_value_fmtd) - 1)
        cat("$", var, "$ & $\\mathbf{", p_value_fmtd, "}$ & ", effect_size, " & ", effect_size_interpretation, " & ", rq, " \\\\\n", sep = "")
    }
    else {
        cat("$", var, "$ & ", p_value_fmtd, " & n/a & n/a & ", rq, " \\\\\n", sep = "")
    }
}
cat("\n")

cat("\nNumber of pairs of runs for LaTeX report:\n")

for (s in fmt_sub) {
    n_rows <- nrow(df %>% filter(Subject == s))
    cat(s, " & ", n_rows / 2, " \\\\\n", sep = "")
}
cat("\\hdashline\n\\textbf{Total} & \\textbf{", nrow(df) / 2, "} \\\\\n\n", sep = "")


# Compute Cohen's d for memory (native and web do not overlap)
df_mem_native <- as.numeric((df %>% filter(app_type == "native") %>% select(mean_mem_usage))$mean_mem_usage)
df_mem_web <- as.numeric((df %>% filter(app_type == "web") %>% select(mean_mem_usage))$mean_mem_usage)
d <- cohen.d(df_mem_native, df_mem_web, conf.level=1-alpha/2)$estimate
cat("Cohen's d (abs) for mean memory utilization (native and web do not overlap):", abs(d), "\n\n")

warnings()
