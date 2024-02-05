% Load your data or provide the appropriate variables (get and ptb)
% Example: load('your_data.mat');
% Make sure you have the get and ptb variables available in your workspace

% Call the function to format responses
[sortedResultsTable, success] = formatResponses(get, ptb);

if ~success
    error('Error in formatting responses. Check the code and data.');
end

% Extracts relevant data for analysis from the csv file
condition = sortedResultsTable.condition;
percepts = sortedResultsTable.percepts;
onsets = sortedResultsTable.onsets;
durations = sortedResultsTable.durations;

% Create a logical vector indicating interocular choices
interocularIndices = strcmp(percepts, 'interocular');

% Create a table with condition and interocular durations information
durationIOGTable = table(condition(interocularIndices), durations(interocularIndices));

% Group the data by condition and calculate the mean duration of interocular onsets
groupedDurationTable = varfun(@mean, durationIOGTable, 'GroupingVariables', 'condition', 'InputVariables', 'Var2');
groupedDurationTable.Properties.VariableNames{2} = 'MeanInterocularDuration';

% Define the order of conditions for analysis
conditionOrder = {'NoMotionNoColor', 'NoMotionColor', 'NoColorMotion', 'MotionColor'};

% Reorder the table according to the specified condition order
groupedDurationTable.condition = categorical(groupedDurationTable.condition, conditionOrder);
groupedDurationTable = sortrows(groupedDurationTable, 'condition');

% Display the results
disp('Mean Duration of Interocular Onsets for Each Condition:');
disp(groupedDurationTable);

% Perform statistical test (e.g., ANOVA) to assess differences between conditions
% Example: One-way ANOVA
anovaResultsDuration = anova1(durationIOGTable.Var2, durationIOGTable.condition, 'off');

% Display ANOVA results for durations
disp('ANOVA Results for Durations of Interocular Onsets:');
disp(anovaResultsDuration);

% Post hoc pairwise comparison (e.g., Tukey-Kramer test) if ANOVA is significant
if anovaResultsDuration < 0.05
    [cDuration,~,~,gnamesDuration] = multcompare(anovaResultsDuration, 'CType', 'tukey-kramer');
    
    % Display pairwise comparison results for durations
    disp('Post Hoc Pairwise Comparison Results for Durations of Interocular Onsets:');
    pairwiseComparisonTableDuration = array2table(cDuration, 'VariableNames', {'Group1', 'Group2', 'LowerCI', 'UpperCI', 'pValue'}, 'RowNames', gnamesDuration);
    disp(pairwiseComparisonTableDuration);
else
    disp('No significant differences detected in durations of interocular onsets between conditions.');
end

% Continue with the analysis of the mean proportion of interocular choices

% Create a table with condition and interocular choice information
analysisTable = table(condition, interocularIndices);

% Group the data by condition and calculate the mean proportion of interocular choices
groupedTable = varfun(@mean, analysisTable, 'GroupingVariables', 'condition', 'InputVariables', 'interocularIndices');
groupedTable.Properties.VariableNames{2} = 'MeanInterocularChoices';

% Reorder the table according to the specified condition order
groupedTable.condition = categorical(groupedTable.condition, conditionOrder);
groupedTable = sortrows(groupedTable, 'condition');

% Display the results
disp('Mean Proportion of Interocular Choices for Each Condition:');
disp(groupedTable);

% Perform statistical test (e.g., ANOVA) to assess differences between conditions
% Example: One-way ANOVA
anovaResults = anova1(groupedTable.MeanInterocularChoices, groupedTable.condition, 'off');

% Display ANOVA results
disp('ANOVA Results:');
disp(anovaResults);

% Post hoc pairwise comparison (e.g., Tukey-Kramer test) if ANOVA is significant
if anovaResults < 0.05
    [c,~,~,gnames] = multcompare(anovaResults, 'CType', 'tukey-kramer');
    
    % Display pairwise comparison results
    disp('Post Hoc Pairwise Comparison Results:');
    pairwiseComparisonTable = array2table(c, 'VariableNames', {'Group1', 'Group2', 'LowerCI', 'UpperCI', 'pValue'}, 'RowNames', gnames);
    disp(pairwiseComparisonTable);
else
    disp('No significant differences detected between conditions.');
end