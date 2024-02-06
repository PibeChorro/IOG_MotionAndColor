# Load necessary libraries
library(readr)
library(dplyr)
library(tidyr)
library(multcomp)
library(knitr)

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

# Extract relevant data for analysis
condition <- sortedResultsTable$condition
percepts <- sortedResultsTable$percepts
onsets <- sortedResultsTable$onsets
durations <- sortedResultsTable$durations

# Create a logical vector indicating interocular choices
interocularIndices <- percepts == 'interocular'

# Create a data frame with condition and interocular durations information
durationIOGTable <- data.frame(
  condition = condition[interocularIndices],
  durations = durations[interocularIndices]
)

# Group the data by condition and calculate the mean duration of interocular onsets
groupedDurationTable <- durationIOGTable %>%
  group_by(condition) %>%
  summarise(MeanInterocularDuration = mean(durations))

# Define the order of conditions for analysis
conditionOrder <- c('NoMotionNoColor', 'NoMotionColor', 'NoColorMotion', 'MotionColor')

# Reorder the table according to the specified condition order
groupedDurationTable$condition <- factor(groupedDurationTable$condition, levels = conditionOrder)
groupedDurationTable <- groupedDurationTable[order(groupedDurationTable$condition), ]

# Display the results using kable
cat('Mean Duration of Interocular Onsets for Each Condition:\n')
print(kable(groupedDurationTable, format = "markdown"))

# Perform statistical test (e.g., ANOVA) to assess differences between conditions
# Example: One-way ANOVA
anovaResultsDuration <- aov(durations ~ condition, data = durationIOGTable)

# Display ANOVA results for durations
cat('ANOVA Results for Durations of Interocular Onsets:\n')
print(kable(summary(anovaResultsDuration), format = "markdown"))

# Post hoc pairwise comparison (e.g., Tukey-Kramer test) if ANOVA is significant
if (summary(anovaResultsDuration)[[1]][1, 5] < 0.05) {
  cDuration <- TukeyHSD(anovaResultsDuration)
  
  # Display pairwise comparison results for durations
  cat('Post Hoc Pairwise Comparison Results for Durations of Interocular Onsets:\n')
  print(kable(cDuration, format = "markdown"))
} else {
  cat('No significant differences detected in durations of interocular onsets between conditions.\n')
}

# Continue with the analysis of the mean proportion of interocular choices

# Create a data frame with condition and interocular choice information
analysisTable <- data.frame(
  condition = condition,
  interocularIndices = interocularIndices
)

# Group the data by condition and calculate the mean proportion of interocular choices
groupedTable <- analysisTable %>%
  group_by(condition) %>%
  summarise(MeanInterocularChoices = mean(interocularIndices))

# Reorder the table according to the specified condition order
groupedTable$condition <- factor(groupedTable$condition, levels = conditionOrder)
groupedTable <- groupedTable[order(groupedTable$condition), ]

# Display the results using kable
cat('Mean Proportion of Interocular Choices for Each Condition:\n')
print(kable(groupedTable, format = "markdown"))

# Perform statistical test (e.g., ANOVA) to assess differences between conditions
# Example: One-way ANOVA
anovaResults <- aov(MeanInterocularChoices ~ condition, data = groupedTable)

# Display ANOVA results
cat('ANOVA Results:\n')
print(kable(summary(anovaResults), format = "markdown"))

# Post hoc pairwise comparison (e.g., Tukey-Kramer test) if ANOVA is significant
if (summary(anovaResults)[[1]][1, 5] < 0.05) {
  c <- TukeyHSD(anovaResults)
  
  # Display pairwise comparison results
  cat('Post Hoc Pairwise Comparison Results:\n')
  print(kable(c, format = "markdown"))
} else {
  cat('No significant differences detected between conditions.\n')
}
}