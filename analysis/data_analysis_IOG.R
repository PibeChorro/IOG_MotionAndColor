# Load necessary libraries
library(readr)
library(dplyr)
library(tidyr)
library(multcomp)
library(knitr)
library(ggplot2)
library(broom)

# Specify the path to the rawdata folder
project_dir <- file.path('~','Documents','Interocular-grouping-and-motion')
rawdata_path <- file.path(project_dir, "rawdata")

subjects <- c('sub-01', 'sub-03')

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


# Convert 'percepts' column to a factor with levels 'interocular', 'mixed', 'monocular'
mergedData$percepts <- factor(mergedData$percepts, levels = c('interocular', 'mixed', 'monocular'))

mergedData$condition <- factor(mergedData$condition, levels = c('NoMotionNoColor', 'MotionNoColor', 'NoMotionColor', 'MotionColor'))

# Filter the data to include only 'interocular' percepts
interocularData <- subset(mergedData, percepts == 'interocular')

# Count the number of 'interocular' choices for each condition
interocularCount <- mergedData %>%
  filter(interocularData) %>%
  group_by(mergedData$condition) %>%
  summarize(InterocularCount = n())


# Perform one-way ANOVA
anova_result <- aov(InterocularCount ~ mergedData$condition, data = interocularData)

anova_tidy <- tidy(anova_result)

# Create a bar plot
ggplot(interocularData, aes(x = Condition, y = InterocularCount, fill = percepts)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Proportion of Interocular Choices Across Conditions",
       x = "Conditions",
       y = "Proportion of Interocular Choices") +
  scale_fill_manual(values = c('interocular' = 'blue', 'mixed' = 'gray', 'monocular' = 'red')) +
  geom_text(aes(label = paste("p-value =", round(anova_tidy$p.value[1], 3))),
            x = Inf, y = -Inf, hjust = 1, vjust = 0,
            size = 4, color = "black") +
  theme_minimal()

