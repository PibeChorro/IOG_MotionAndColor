function runRandomization()

for subjectNum = 1:24

    runNumber = 8;

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

    Motion_NoColor = {'Upward', 'Black','Horizontal'
        'Leftward', 'Black', 'Vertical'
        'Downward', 'Black', 'Horizontal'
        'Rightward', 'Black', 'Vertical'}';

    Motion_NoColor = Motion_NoColor';

    M_NC_Condition = repmat(Motion_NoColor, 2, 1);

    Motion_Color = {'Upward', 'Green','Horizontal'
        'Leftward', 'Red', 'Vertical'
        'Downward', 'Red', 'Horizontal'
        'Rightward', 'Green','Vertical'
        'Upward', 'Red','Horizontal'
        'Leftward', 'Green','Vertical'
        'Downward', 'Green', 'Horizontal'
        'Rightward', 'Red', 'Vertical'};

    M_C_Condition = Motion_Color;

    allCombinations = cell(0, 3);
    
    % Generate a pseudorandom permutation of indices
    randIndices = randperm(length(NM_NC_Condition) + length(NM_C_Condition) + length(M_C_Condition) + length(M_NC_Condition));
    
    % Use the random indices to shuffle the order of conditions
    shuffledConditions = zeros(length(randIndices), 3);
    
    for idx = 1:length(randIndices)
        [i, j, k] = ind2sub([length(NM_NC_Condition), length(NM_C_Condition), length(M_NC_Condition), length(M_C_Condition)], randIndices(idx));
        shuffledConditions(idx, :) = [i, j, k];
    end
    
    % Iterate over the shuffled conditions
    for idx = 1:size(shuffledConditions, 1)
        i = shuffledConditions(idx, 1);
        j = shuffledConditions(idx, 2);
        k = shuffledConditions(idx, 3);
        h = shuffledConditions(idx, 4);
         
        % Create a combination and add it to the cell array
        combination = {NM_NC_Condition{i}, NM_C_Condition{j}, M_NC_Condition{k}, M_C_Condition{h}};
%       allCombinations = [allCombinations; combination];
    end
    
    % Display the generated combinations for the current subject
    disp(['All Possible Combinations for Subject ' num2str(subjectNum) ':']);
    disp(allCombinations);
    
    for runIdx = 1:8
        % Select five trials for each run
        selectedTrials = datasample(allCombinations, 5, 'Replace', false);
        
        % Create a table or writetable for each CSV file for each run
        tableForRun{runIdx} = cell2table(selectedTrials, 'VariableNames', {'Motion', 'Orientation', 'Color'});
        writetable(tableForRun{runIdx}, ['Subject_' num2str(subjectNum) '_Run_' num2str(runIdx) '.csv']);

    end

end
