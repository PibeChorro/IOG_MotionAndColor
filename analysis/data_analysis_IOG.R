# Load packages and directories

# Load necessary libraries
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
library(ez)
library(car)

# Specify the path to the rawdata folder


project_dir <- file.path('~','Documents','Interocular-grouping-and-motion')
rawdata_path <- file.path(project_dir, "rawdata")


# Specify the subjects


subjects <- c('sub-01', 'sub-02', 'sub-03', 'sub-04', 'sub-05', 'sub-06', 'sub-07', 'sub-08', 'sub-09')


# Create an empty data frame


mergedData <- data.frame()


# Loop through all csv files for each subject and merge them into one data frame


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

mergedData <- aggregate(durations ~ condition + percepts + subject,
                        data = mergedData,
                        
                        FUN = sum)

mergedData$condition <- factor(mergedData$condition)
mergedData$subject <- factor(mergedData$subject)

mergedData_mixed <- mergedData %>%
  group_by(subject, condition) %>%
  summarise(proportion_mixed = (
    sum(durations[percepts == 'mixed']))/(sum(durations[percepts == 'interocular']+
                                                durations[percepts == 'monocular'] +
                                                durations[percepts == 'mixed'])),
    .groups = 'drop')

aov_mixed <- ezANOVA(data = mergedData_mixed,
                     dv = proportion_mixed,
                     within = condition,
                     wid = subject)
print(aov_mixed) # Ask Vincent why this is significant if there are no differences across conditions for mixed percepts



# Filtering data for proportion interocular without mixed percepts

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


# Bar plot for Proportion IOG without mixed
bar_plot_IOG <- ggplot(data = filteredData_IOG, aes(x = condition, y = proportion_IOG, fill = condition)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(x = "Conditions", y = "Proportion of 'Interocular' Percepts") +
  theme_minimal() +
  coord_cartesian(ylim = c(0, 1))

print(bar_plot_IOG)

# Linear regression test
filteredData_IOG$condition_numeric <- ifelse(filteredData_IOG$condition == "NoMotionNoColor", 0,
                                             ifelse(filteredData_IOG$condition %in% c('NoMotionColor', 'MotionNoColor'), 1, 2))

# Perform linear regression
lm_test_IOG <- lm(proportion_IOG ~ condition_numeric, data = filteredData_IOG)

residuals <- residuals(lm_test_IOG)

# Shapiro-Wilk test for normality
shapiro_test <- shapiro.test(residuals)

print(shapiro_test) # Shapiro test's p-value is .3324, meaning residuals of the data do not
# significantly deviate from normal and the model is a good fit for the data


summary(lm_test_IOG)


hist(residuals)

qq1 <- qqPlot(residuals)

filteredData_IOG$subject <- factor(filteredData_IOG$subject)

# ANOVA test
aov_IOG <- ezANOVA(data = filteredData_IOG,
                   dv = proportion_IOG,
                   within = condition,
                   wid = subject)
print(aov_IOG)


## Post-hoc t-tests
NMNC <- filteredData_IOG$proportion_IOG[filteredData_IOG$condition == 'NoMotionNoColor']
MNC <- filteredData_IOG$proportion_IOG[filteredData_IOG$condition == 'MotionNoColor']
NMC <- filteredData_IOG$proportion_IOG[filteredData_IOG$condition == 'NoMotionColor']
MC <- filteredData_IOG$proportion_IOG[filteredData_IOG$condition == 'MotionColor']

# main tests
motion_cue_res <- t.test(x = NMNC, y = MNC, alternative = 'less')  # expectation significant difference
print(motion_cue_res)
color_cue_res <- t.test(x = NMNC, y = NMC, alternative = 'less')   # expectation significant difference
print(color_cue_res)
motion_vs_color <- t.test(x = MNC, y = NMC, alternative = 'two.sided') # expectation NO significant difference
print(motion_vs_color)
motion_color_vs_motion <- t.test(x = MNC, y = MC, alternative = 'less')  # expectation significant difference
print(motion_color_vs_motion)
motion_color_vs_color <- t.test(x = NMC, y = MC, alternative = 'less')  # expectation significant difference
print(motion_color_vs_color)

# Bar plot of proportion IOG

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





