function runRandomization()

for subjectNum = 1:24

    % Number of runs
    runNumber = 8;

    % Number of trials per run
    trialsPerRun = 4;

    % Define options
    NoMotion_NoColor = {
        'No Motion', 'No Motion', 'Black', 'Black', 'Horizontal',   'Vertical'
        };

    NM_NC_Condition = NoMotion_NoColor;

    NoMotion_Color = {
        'No Motion', 'No Motion', 'Green', 'Red', 'Horizontal', 'Vertical'
        'No Motion', 'No Motion', 'Green', 'Red', 'Vertical',   'Horizontal'
        };

    NM_C_Condition = repmat(NoMotion_Color, 4, 1);

    Motion_NoColor = {
        'Upward',   'Leftward',     'Black', 'Black', 'Horizontal', 'Vertical'
        'Downward', 'Leftward',     'Black', 'Black', 'Horizontal', 'Vertical'
        'Upward',   'Rightward',    'Black', 'Black', 'Horizontal', 'Vertical'
        'Downward', 'Rightward',    'Black', 'Black', 'Horizontal', 'Vertical'
        };

    M_NC_Condition = repmat(Motion_NoColor, 2, 1);

    Motion_Color = {
        'Upward',   'Leftward',     'Red', 'Green', 'Horizontal', 'Vertical'
        'Downward', 'Leftward',     'Red', 'Green', 'Horizontal', 'Vertical'
        'Upward',   'Rightward',    'Red', 'Green', 'Horizontal', 'Vertical'
        'Downward', 'Rightward',    'Red', 'Green', 'Horizontal', 'Vertical'
        'Upward',   'Leftward',     'Green', 'Red', 'Horizontal', 'Vertical'
        'Downward', 'Leftward',     'Green', 'Red', 'Horizontal', 'Vertical'
        'Upward',   'Rightward',    'Green', 'Red', 'Horizontal', 'Vertical'
        'Downward', 'Rightward',    'Green', 'Red', 'Horizontal', 'Vertical'
        };

    M_C_Condition = Motion_Color;

    % Combine all conditions into one cell array
    allConditions = {NM_NC_Condition, NM_C_Condition, M_NC_Condition, M_C_Condition};

    % Initialize a cell array to store the selected trials
    selectedTrialsCellArray = cell(runNumber, 1);

    for runIdx = 1:runNumber
        runTrials = cell(trialsPerRun, 6);

        % Randomize the order of conditions
        randomizedConditions = allConditions(randperm(length(allConditions)));

        % Iterate over each condition and randomly select one combination
        % using datasample() function without replacement

        for conditionIdx = 1:length(randomizedConditions)
            currentCondition = randomizedConditions{conditionIdx};
            selectedCombination = datasample(currentCondition, 1, 'Replace', false);
        
            runTrials{conditionIdx, 1} = selectedCombination{1, 1};
            runTrials{conditionIdx, 2} = selectedCombination{1, 2};
            runTrials{conditionIdx, 3} = selectedCombination{1, 3};


            selectedNoMotion_NoColor = NoMotion_NoColor(1,:);
            selectedMotion_Color = Motion_Color(1,:);

            % take first option from no_motion_Color that doesnt have the
            % same color combination of Motion_Color.

            % take first option from motion_no_color that doesnt have the
            % same motion combination of Motion_Color. and shuffle them.
            % do this in a iteration loop that everytime it takes one
            % condition and saves it to a file, it deletes that option for
            % that run file and takes the second one.

        
            % Determine 'Color2' directly based on 'Color1'
            if strcmp(selectedCombination{1, 2}, 'Black')
                runTrials{conditionIdx, 5} = 'Black';
            elseif strcmp(selectedCombination{1, 2}, 'Green')
                runTrials{conditionIdx, 5} = 'Red';
            else
                runTrials{conditionIdx, 5} = 'Green';
            end
        
            % Determine 'Orientation2' based on 'Orientation1'
            if strcmp(selectedCombination{1, 3}, 'Horizontal')
                runTrials{conditionIdx, 6} = 'Vertical';
            else
                runTrials{conditionIdx, 6} = 'Horizontal';
            end
        % Store the selected trials for this run
        selectedTrialsCellArray{runIdx} = runTrials;
        
        % Create a table and save it to a CSV file
        tableForRun = cell2table(runTrials, 'VariableNames', {'Motion1', 'Color1', 'Orientation1', 'Motion2', 'Color2', 'Orientation2'});
        writetable(tableForRun, ['Subject_' num2str(subjectNum) '_Run_' num2str(runIdx) '.csv']);
        end
    end
end
end