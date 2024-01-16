function runRandomization()

for subjectNum = 1:24

    % Number of runs
    runNumber = 8;

    % Number of trials per run
    trialsPerRun = 4;

    % Define options
    NoMotion_NoColor = {'No Motion', 'Black', 'Horizontal'
        'No Motion', 'Black', 'Vertical'};

    NM_NC_Condition = repmat(NoMotion_NoColor, 4, 1);

    NoMotion_Color = {'No Motion', 'Green', 'Horizontal'
        'No Motion', 'Red', 'Vertical'
        'No Motion', 'Red', 'Horizontal'
        'No Motion', 'Green', 'Vertical'};

    NM_C_Condition = repmat(NoMotion_Color, 2, 1);

    Motion_NoColor = {'Upward', 'Black', 'Horizontal'
        'Leftward', 'Black', 'Vertical'
        'Downward', 'Black', 'Horizontal'
        'Rightward', 'Black', 'Vertical'}';

    Motion_NoColor = Motion_NoColor';

    M_NC_Condition = repmat(Motion_NoColor, 2, 1);

    Motion_Color = {'Upward', 'Green', 'Horizontal'
        'Leftward', 'Red', 'Vertical'
        'Downward', 'Red', 'Horizontal'
        'Rightward', 'Green', 'Vertical'
        'Upward', 'Red', 'Horizontal'
        'Leftward', 'Green', 'Vertical'
        'Downward', 'Green', 'Horizontal'
        'Rightward', 'Red', 'Vertical'};

    M_C_Condition = Motion_Color;

    % Combine all conditions into one cell array
    allConditions = {NM_NC_Condition, NM_C_Condition, M_NC_Condition, M_C_Condition};

    % Initialize a cell array to store the selected trials
    selectedTrialsCellArray = cell(runNumber, 1);

    for runIdx = 1:runNumber
        runTrials = cell(trialsPerRun, 6);
        usedMotionCombinations = {}; % Keep track of used motion combinations

        % Randomize the order of conditions
        randomizedConditions = allConditions(randperm(length(allConditions)));

        % Iterate over each condition and randomly select one combination
        % using datasample() function
        for conditionIdx = 1:length(randomizedConditions)
            currentCondition = randomizedConditions{conditionIdx};
            
            % Continue selecting until a unique motion combination is found
%             isUniqueCombination = false;
%             while ~isUniqueCombination
                selectedCombination = datasample(currentCondition, 1, 'Replace', false);
                motionCombination = selectedCombination{1, 1};

                
                % Check if the motion combination is unique in the current run
%                 if ~ismember(motionCombination, usedMotionCombinations)
%                     isUniqueCombination = true;
%                     usedMotionCombinations = [usedMotionCombinations; motionCombination];
%                 end
%             end
            
            runTrials{conditionIdx, 1} = selectedCombination{1, 1};
            runTrials{conditionIdx, 2} = selectedCombination{1, 2};
            runTrials{conditionIdx, 3} = selectedCombination{1, 3};
        end
            
            % Determine 'Motion2' based on 'Motion1'
            if strcmp(selectedCombination{1, 1}, 'No Motion')
                runTrials{conditionIdx, 4} = 'No Motion';
            elseif strcmp(selectedCombination{1, 1}, 'Leftward') || strcmp(selectedCombination{1, 1}, 'Rightward')
                runTrials{conditionIdx, 4} = datasample({'Upward', 'Downward'}, 1);
            elseif strcmp(selectedCombination{1, 1}, 'Upward') || strcmp(selectedCombination{1, 1}, 'Downward')
                runTrials{conditionIdx, 4} = datasample({'Leftward', 'Rightward'}, 1);
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
        end

        % Store the selected trials for this run
        selectedTrialsCellArray{runIdx} = runTrials;
        
        % Create a table and save it to a CSV file
        tableForRun = cell2table(runTrials, 'VariableNames', {'Motion1', 'Color1', 'Orientation1', 'Motion2', 'Color2', 'Orientation2'});
        writetable(tableForRun, ['Subject_' num2str(subjectNum) '_Run_' num2str(runIdx) '.csv']);
    end

    % Display the selected trials for each run for the current subject
    disp(['Selected Trials for Subject ' num2str(subjectNum) ':']);
    disp(selectedTrialsCellArray);

end