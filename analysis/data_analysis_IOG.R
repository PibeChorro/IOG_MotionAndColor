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
  coord_cartesian(ylim = c(0, 1)) +
  geom_segment(aes(x = 1.3, xend = 1.9, y = 0.92, yend = 0.92), size = 0.5) +
  geom_segment(aes(x = 1.3, xend = 1.3, y = 0.91, yend = 0.92), size = 0.5) +
  geom_segment(aes(x = 1.9, xend = 1.9, y = 0.91, yend = 0.92), size = 0.5) +
  geom_segment(aes(x = 2.3, xend = 2.9, y = 0.92, yend = 0.92), size = 0.5) +
  geom_text
print(bar_plot_IOG_WM)


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
  coord_cartesian(ylim = c(0, 1))

print(bar_plot_monocular)


## FOR PROPORTION INTEROCULAR WITHOUT MIXED PERCEPTS


# Filter the data to exclude rows with 'mixed' percepts
filteredData <- mergedData[mergedData$percepts != 'mixed', ]

# Convert 'percepts' column to a factor with levels 'interocular', 'monocular'
filteredData$percepts <- factor(filteredData$percepts, levels = c('interocular', 'monocular'))

durations <- filteredData$durations

condition <- unique(filteredData$condition)

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

# Create bar plot of mean proportions of 'Interocular' percepts
bar_plot_interocular <- ggplot(data = filteredData_IOG, aes(x = condition, y = proportion_IOG, fill = condition)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(x = "Conditions", y = "Proportion of 'Interocular' Percepts") +
  theme_minimal() +
  coord_cartesian(ylim = c(0, 1)) +
  geom_segment(aes(x = 1.3, xend = 1.9, y = 0.92, yend = 0.92), size = 0.5) +
  geom_segment(aes(x = 1.3, xend = 1.3, y = 0.91, yend = 0.92), size = 0.5) +
  geom_segment(aes(x = 1.9, xend = 1.9, y = 0.91, yend = 0.92), size = 0.5) +
  geom_segment(aes(x = 2.3, xend = 2.9, y = 0.92, yend = 0.92), size = 0.5) +
  geom_segment(aes(x = 2.3, xend = 2.3, y = 0.91, yend = 0.92), size = 0.5) +
  geom_segment(aes(x = 2.9, xend = 2.9, y = 0.91, yend = 0.92), size = 0.5) +
  geom_segment(aes(x = 3.3, xend = 3.9, y = 0.92, yend = 0.92), size = 0.5) +
  geom_segment(aes(x = 3.3, xend = 3.3, y = 0.91, yend = 0.92), size = 0.5) +
  geom_segment(aes(x = 3.9, xend = 3.9, y = 0.91, yend = 0.92), size = 0.5) +
  geom_text(aes(x = 2.50, y = 0.9, label = "*"), size = 4, vjust = -1) +
  geom_text(aes(x = 2.60, y = 0.9, label = "*"), size = 4, vjust = -1) +
  geom_text(aes(x = 2.70, y = 0.9, label = "*"), size = 4, vjust = -1) +
  geom_text(aes(x = 1.55, y = 0.9, label = "*"), size = 4, vjust = -1) +
  geom_text(aes(x = 1.65, y = 0.9, label = "*"), size = 4, vjust = -1) +
  geom_text(aes(x = 3.55, y = 0.9, label = "*"), size = 4, vjust = -1) +
  geom_text(aes(x = 3.65, y = 0.9, label = "*"), size = 4, vjust = -1)

# Print the plot
print(bar_plot_interocular)

# Print ANOVA summary
summary(anova_interocular)
