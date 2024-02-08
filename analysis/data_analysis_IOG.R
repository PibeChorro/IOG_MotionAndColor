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

subjects <- c('sub-01', 'sub-02', 'sub-03', 'sub-05', 'sub-06')

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
    # Switch 'interocular' and 'monocular' percepts for odd subject numbers
    if (as.numeric(gsub("sub-", "", subject)) %% 2 == 1) {
      data$percepts <- factor(ifelse(data$percepts == 'interocular', 'monocular', 'interocular'),
                              levels = c('interocular', 'monocular'))
    }
    
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

# ANOVA for comparing duration of interocular percepts across conditions
anova_interocular <- aov(filteredData$durations ~ filteredData$condition, data = subset(filteredData, percepts == 'interocular'))
print(anova_interocular)

anova_monocular <- aov(filteredData$duration ~ filteredData$condition, data = subset(filteredData, percepts == 'monocular'))
print(anova_monocular)

# Post-hoc test for pairwise comparisons
posthoc_int <- TukeyHSD(anova_interocular)
print(posthoc_int)

# Create a bar plot
bar_plot_interocular <- ggplot(data = subset(filteredData, percepts == 'interocular'), aes(x = condition, y = durations, fill = condition)) +
  geom_bar(stat = "summary", fun = "mean", position = "dodge") +
  labs(x = "Conditions", y = "Proportion of 'Interocular' Percepts") +
  theme_minimal() +
  coord_cartesian(ylim = c(0, 3))  # Adjust the y-axis range as needed

bar_plot_interocular <- bar_plot_interocular +
  annotate("text", x = c(1, 2, 3, 4), y = 2.4, label = "*", size = 4, vjust = 0) +
  geom_segment(aes(x = 1, xend = 2, y = 2.3, yend = 2.3), color = "black") +
  geom_segment(aes(x = 3, xend = 4, y = 2.3, yend = 2.3), color = "black")

print(bar_plot_interocular)

bar_plot_monocular <- ggplot(data = subset(filteredData, percepts == 'monocular'), aes(x = condition, y = durations, fill = condition)) +
  geom_bar(stat = "summary", fun = "mean", position = "dodge") +
  labs(x = "Conditions", y = "Proportion of 'Monocular' Percepts") +
  theme_minimal() +
  coord_cartesian(ylim = c(0, 5))

# Add significance annotations directly using geom_text
bar_plot_monocular <- bar_plot_monocular +
  annotate("text", x = c(1, 2, 3, 4), y = 4.1, label = "*", size = 4, vjust = 0) +
  geom_segment(aes(x = 1, xend = 2, y = 4.0, yend = 4.0), color = "black") +
  geom_segment(aes(x = 3, xend = 4, y = 4.0, yend = 4.0), color = "black")

# Print the plot
print(bar_plot_monocular)
