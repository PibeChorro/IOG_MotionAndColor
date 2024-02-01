% Load your data or provide the appropriate variables (get and ptb)
% Example: load('your_data.mat');
% Make sure you have the get and ptb variables available in your workspace

% Call the function to format responses
[sortedResultsTable, success] = formatResponses(get, ptb);

if ~success
    error('Error in formatting responses. Check the code and data.');
end

% Extract relevant data for analysis
condition = sortedResultsTable.condition;
percepts = sortedResultsTable.percepts;

% Create a logical vector indicating interocular choices
interocularChoices = strcmp(percepts, 'interocular');

% Create a table with condition and interocular choice information
analysisTable = table(condition, interocularChoices);

% Group the data by condition and calculate the mean proportion of interocular choices
groupedTable = varfun(@mean, analysisTable, 'GroupingVariables', 'condition', 'InputVariables', 'interocularChoices');
groupedTable.Properties.VariableNames{2} = 'MeanInterocularChoices';

% Define the order of conditions for analysis
conditionOrder = {'No_Motion_NoColor', 'No_Motion_Color', 'No_Color_Motion', 'Motion_Color'};

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