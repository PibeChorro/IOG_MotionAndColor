# Load necessary libraries
library(readr)
library(dplyr)
library(tidyr)
library(multcomp)
library(knitr)
library(ggplot2)
library(broom)
library(rcompanion)
library(ggpubr)
library(plotrix)
library(gridExtra)
library(dotwhisker)

# Specify the path to the rawdata folder
project_dir <- file.path('~','Documents','Interocular-grouping-and-motion')
rawdata_path <- file.path(project_dir, "rawdata")

subjects <- c('sub-01', 'sub-02', 'sub-03', 'sub-04', 'sub-05', 'sub-06', 'sub-07', 'sub-08', 'sub-09')

# Initialize an empty data frame to store the merged data
mergedData <- data.frame()

# Loop through each subject
for (subject in subjects) {
  # Create the path to the subject folder
  subjectFolderPath <- file.path(rawdata_path, subject)
  
  # List CSV files in the subject folder
  files <- list.files(subjectFolderPath, pattern = "*.csv", full.names = TRUE)
  # get list of files for experiment 1
  files <- files[grepl("task-IOG_run", files)]
  # excluded files containing 'conditions' in name
  files <- files[!grepl("conditions", files)]
  
  # Read and merge CSV files
  run <- 1
  for (file in files) {
    data <- read.csv(file)
    data$subject = subject
    data$run = run
    run <- run+1
    mergedData <- rbind(mergedData, data)
  }
}

## FOR INTEROCULAR PROPORTION INCLUDING MIXED PERCEPTS IN THE DATA

durations <- mergedData$durations

mergedData$condition <- factor(mergedData$condition, levels = c('NoMotionNoColor', 'MotionNoColor', 'NoMotionColor', 'MotionColor'))

condition <- mergedData$condition

percepts <- factor(mergedData$percepts, levels = c('interocular', 'monocular', 'mixed'))

mergedData <- aggregate(durations ~ condition + percepts + subject,
                        data = mergedData,
                        FUN = sum)

mergedData_IOG <- mergedData %>%
  group_by(subject, condition) %>%
  summarise(proportion_IOG = (
    sum(durations[percepts == 'interocular']))/(sum(durations[percepts == 'interocular']+
                                                      durations[percepts == 'monocular'] +
                                                      durations[percepts == 'mixed'])),
    .groups = 'drop')

anova_interocular_WM <- aov(proportion_IOG ~ condition, data = mergedData_IOG)
print(anova_interocular_WM)

posthoc_IOG_WM <- TukeyHSD(anova_interocular_WM)
print(posthoc_IOG_WM)

bar_plot_IOG_WM <- ggplot(data = mergedData_IOG, aes(x = condition, y = proportion_IOG, fill = condition)) +
  geom_bar(stat = "identity", position = "dodge") +
 labs(x = "Conditions", y = "Proportion of 'Interocular' Percepts") +
  theme_minimal() +
  coord_cartesian(ylim = c(0, 1))

print(bar_plot_IOG_WM)

## LINEAR REGRESSION TEST FOR PROPORTION OF INTEROCULAR GROUPING -- WITH MIXED

mergedData_IOG$condition_numeric <- ifelse(mergedData_IOG$condition == "NoMotionNoColor", 0,
                                       ifelse(mergedData_IOG$condition %in% c('NoMotionColor', 'MotionNoColor'), 1, 2))

# Perform linear regression
lm_test_IOG_WM <- lm(proportion_IOG ~ condition_numeric, data = mergedData_IOG)

summary(lm_test_IOG_WM)

plot(lm_test_IOG_WM)

abline(lm_test_IOG_WM)

# Create a data frame for predictions
pred_data <- data.frame(
  condition = factor(c('NoMotionNoColor', 'MotionNoColor', 'NoMotionColor', 'MotionColor'))
)

# Predict values using the linear regression model
pred_data$predicted_proportion <- predict(lm_test_IOG, newdata = pred_data)

# Extract coefficients and their confidence intervals
coef_data <- broom::tidy(lm_test_IOG)

# Plotting coefficients with 95% confidence intervals
coef_plot <- ggplot(coef_data, aes(x = term, y = estimate)) +
  geom_point() +
  geom_errorbar(aes(ymin = estimate - 1.96 * std.error, ymax = estimate + 1.96 * std.error), width = 0.2) +
  labs(title = "Coefficients with 95% Confidence Intervals",
       x = "Condition",
       y = "Estimate")

print(coef_plot)

# Plotting the actual vs. predicted values with adjusted title position
actual_vs_predicted_plot <- ggplot(mergedData_IOG, aes(x = condition, y = proportion_IOG)) +
  geom_point() +
  geom_line(data = pred_data, aes(y = predicted_proportion), color = "blue") +
  labs(title = "Actual vs. Predicted Values",
       x = "Condition",
       y = "Proportion of 'Interocular' Grouping") +
  theme(plot.title = element_text(hjust = 0.45))  # Adjust the title position

print(actual_vs_predicted_plot)

# Plotting residuals
residual_plot <- ggplot(data.frame(lm_test_IOG$residuals), aes(x = seq_along(lm_test_IOG$residuals), y = lm_test_IOG$residuals)) +
  geom_point() +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  labs(title = "Residuals Plot",
       x = "Observation",
       y = "Residual")

grid.arrange(coef_plot, actual_vs_predicted_plot, residual_plot, ncol = 1)

## FOR PROPORTION MIXED WITHIN DIFFERENT CONDITIONS

mergedData_mixed <- mergedData %>%
  group_by(subject, condition) %>%
  summarise(proportion_mixed = (
    sum(durations[percepts == 'mixed']))/(sum(durations[percepts == 'interocular']+
                                                      durations[percepts == 'monocular'] +
                                                      durations[percepts == 'mixed'])),
    .groups = 'drop')

anova_mixed <- aov(proportion_mixed ~ condition, data = mergedData_mixed)
print(anova_mixed)

posthoc_mixed <- TukeyHSD(anova_mixed)
print(posthoc_mixed)

## FOR PROPORTION MONOCULAR WITHIN DIFFERENT CONDITIONS (WITH MIXED)

mergedData_MON <- mergedData %>%
  group_by(subject, condition) %>%
  summarise(proportion_monocular = (
    sum(durations[percepts == 'monocular']))/(sum(durations[percepts == 'interocular'] +
                                                    durations[percepts == 'monocular'] +
                                                    durations[percepts == 'mixed'])),
    .groups = 'drop')


anova_monocular <- aov(proportion_monocular ~ condition, data = mergedData_MON)
print(anova_monocular)

posthoc_monocular <- TukeyHSD(anova_monocular)
print(posthoc_monocular)

bar_plot_monocular <- ggplot(data = mergedData_MON, aes(x = condition, y = proportion_monocular, fill = condition)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(x = "Conditions", y = "Proportion of 'Monocular' Percepts") +
  theme_minimal() +
  coord_cartesian(ylim = c(0, 0.7))

print(bar_plot_monocular)


## FOR PROPORTION INTEROCULAR WITHOUT MIXED PERCEPTS


# Filter the data to exclude rows with 'mixed' percepts
filteredData <- mergedData[mergedData$percepts != 'mixed', ]

# Convert 'percepts' column to a factor with levels 'interocular', 'monocular'
filteredData$percepts <- factor(filteredData$percepts, levels = c('interocular', 'monocular'))

durations <- filteredData$durations

filteredData$condition <- factor(filteredData$condition, levels = c('NoMotionNoColor', 'MotionNoColor', 'NoMotionColor', 'MotionColor'))

percepts <- unique(filteredData$percepts)

# Aggregate dominance durations by subject, typical color and percept using sum
# instead of median

filteredData <- aggregate(durations ~ condition + percepts + subject,
                         data = filteredData,

                       FUN = sum)
filteredData_IOG <- filteredData %>%
group_by(subject, condition) %>%
summarise(proportion_IOG = (
sum(durations[percepts == 'interocular']))/(sum(durations[percepts == 'interocular']+
                                                durations[percepts == 'monocular'])),
.groups = 'drop')

# ANOVA test
anova_interocular <- aov(proportion_IOG ~ condition, data = filteredData_IOG)
print(anova_interocular)

# Post-hoc test for pairwise comparisons
posthoc_int <- TukeyHSD(anova_interocular)
print(posthoc_int)

filteredData_IOG$condition_numeric <- ifelse(filteredData_IOG$condition == "NoMotionNoColor", 0,
                                           ifelse(filteredData_IOG$condition %in% c('NoMotionColor', 'MotionNoColor'), 1, 2))

lm_test_IOG <- lm(proportion_IOG ~ condition_numeric, data = filteredData_IOG)

summary_lm <- summary(lm_test_IOG)

plot(lm_test_IOG)

abline(lm_test_IOG) # looks mainly like it's normally distributed

# Create bar plot of mean proportions of 'Interocular' percepts
bar_plot_interocular <- ggplot(data = filteredData_IOG, aes(x = condition, y = proportion_IOG, fill = condition)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(x = "Conditions", y = "Proportion of 'Interocular' Percepts") +
  theme_minimal() +
  coord_cartesian(ylim = c(0, 1.1)) +
  geom_segment(aes(x = 1.0, xend = 3.0, y = 1.0, yend = 1.0), size = 0.5) +
  geom_segment(aes(x = 1.0, xend = 1.0, y = 0.99, yend = 1.0), size = 0.5) +
  geom_segment(aes(x = 3.0, xend = 3.0, y = 0.99, yend = 1.0), size = 0.5) +
  geom_segment(aes(x = 2.3, xend = 2.9, y = 0.92, yend = 0.92), size = 0.5) +
  geom_segment(aes(x = 2.3, xend = 2.3, y = 0.91, yend = 0.92), size = 0.5) +
  geom_segment(aes(x = 2.9, xend = 2.9, y = 0.91, yend = 0.92), size = 0.5) +
  geom_segment(aes(x = 3.3, xend = 3.9, y = 0.92, yend = 0.92), size = 0.5) +
  geom_segment(aes(x = 3.3, xend = 3.3, y = 0.91, yend = 0.92), size = 0.5) +
  geom_segment(aes(x = 3.9, xend = 3.9, y = 0.91, yend = 0.92), size = 0.5) +
  geom_text(aes(x = 2.0, y = 1.0, label = "*"), size = 4, vjust = -1) +
  geom_text(aes(x = 2.50, y = 0.9, label = "*"), size = 4, vjust = -1) +
  geom_text(aes(x = 2.60, y = 0.9, label = "*"), size = 4, vjust = -1) +
  geom_text(aes(x = 2.70, y = 0.9, label = "*"), size = 4, vjust = -1) +
  geom_text(aes(x = 3.55, y = 0.9, label = "*"), size = 4, vjust = -1) +
  geom_text(aes(x = 3.65, y = 0.9, label = "*"), size = 4, vjust = -1)

# Print the plot
print(bar_plot_interocular)

# Print ANOVA summary
summary(anova_interocular)
