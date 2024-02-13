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

subjects <- c('sub-01', 'sub-02', 'sub-03', 'sub-04', 'sub-05', 'sub-06')

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
  coord_cartesian(ylim = c(0, 1))  # Adjust the y-axis range as needed

# Add asterisks and connecting lines for significant differences
#bar_plot_interocular <- bar_plot_interocular +
  #annotate("text", x = c(1, 2, 3, 4), y = 0.95, label = "*", size = 4, vjust = 0) +
  #geom_segment(aes(x = 1, xend = 2, y = 0.95, yend = 0.95), color = "black") +
  #geom_segment(aes(x = 3, xend = 4, y = 0.95, yend = 0.95), color = "black")

# Print the plot
print(bar_plot_interocular)

# Print ANOVA summary
summary(anova_interocular)
