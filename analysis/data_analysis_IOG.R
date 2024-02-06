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
durations <- mergedData$durations
condition <- mergedData$condition
percepts <- mergedData$percepts
onsets <- mergedData$onsets
keyAdded <- mergedData$keyAdded



