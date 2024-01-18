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

    % Initialize a cell array to store the selected trials
    selectedTrialsCellArray = cell(runNumber, 1);

    for runIdx = 1:runNumber
        runTrials = cell(trialsPerRun, 6);

        % Combine all conditions into one cell array
        allConditions = {NM_NC_Condition, NM_C_Condition, M_NC_Condition, M_C_Condition};

        % Randomize the order of conditions
        randomizedConditions = allConditions(randperm(length(allConditions)));

        for conditionIdx = 1:length(randomizedConditions)
        
            currentCondition = randomizedConditions{conditionIdx};
        
            if conditionIdx == 1 && strcmp(currentCondition{1, 1}, 'No Motion') && strcmp(currentCondition{1, 3}, 'Black')
                selectedCombination = currentCondition(1, :);
                currentCondition(1, :) = []; % Remove the selected option
            elseif conditionIdx == 2 && ~strcmp(currentCondition{1, 1}, 'No Motion')
                selectedCombination = currentCondition(1, :);
                currentCondition(1, :) = []; % Remove the selected option
            else
                randomIndex = randperm(size(currentCondition, 1), 1);
                selectedCombination = currentCondition(randomIndex, :);
                currentCondition(randomIndex, :) = []; % Remove the selected option
            end
        
            runTrials{conditionIdx, 1} = selectedCombination{1, 1};
            runTrials{conditionIdx, 2} = selectedCombination{1, 2};
            runTrials{conditionIdx, 3} = selectedCombination{1, 3};
        
            if conditionIdx == 3
                for i = 1:size(NM_C_Condition, 1)
                    if ~strcmp(NM_C_Condition{i, 3}, runTrials{2, 3})
                        selectedCombination = NM_C_Condition(i, :);
                        NM_C_Condition(i, :) = [];
                        break;
                    end
                end
        
            elseif conditionIdx == 4
                for i = 1:size(M_NC_Condition, 1)
                    if ~strcmp(M_NC_Condition{i, 1}, runTrials{2, 1}) && ~strcmp(M_NC_Condition{i, 2}, runTrials{2, 2})
                        selectedCombination = M_NC_Condition(i, :);
                        M_NC_Condition(i, :) = [];
                        break;
                    end
                end
            else
                randomIndex = randperm(size(currentCondition, 1), 1);
                selectedCombination = currentCondition(randomIndex, :);
                currentCondition(randomIndex, :) = []; % Remove the selected option
            end
        end

            if conditionIdx > 2
                selectedCombination = currentCondition(1, :);
                currentCondition(1, :) = [];
            end

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
    end
end
        
        % Convert cell array to table
        T = cell2table(runTrials, 'VariableNames', {'Motion1', 'Motion2', 'Color1', 'Color2', 'Orientation1', 'Orientation2'});
        
        % Write table to CSV file
        writetable(T, sprintf('run%d.csv', runIdx));
end