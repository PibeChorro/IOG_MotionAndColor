function data = runRandomization()

for subjectNum = 1:24

    % Number of runs
    runNumber = 8;

    % Number of trials per run
    trialsPerRun = 4;

    NoMotion_NoColor = {
        'No Motion', 'No Motion', 'Black', 'Black', 'Horizontal',   'Vertical'
        };

    NM_NC_Condition = NoMotion_NoColor;

    NoMotion_Color = {
        'No Motion', 'No Motion', 'Green',  'Red',      'Horizontal', 'Vertical'
        'No Motion', 'No Motion', 'Red',    'Green',    'Horizontal', 'Vertical'
        };

    NM_C_Condition = repmat(NoMotion_Color, 4, 1);

    Motion_NoColor = {
        'Upward',   'Leftward',     'Black', 'Black', 'Horizontal', 'Vertical'
        'Downward', 'Leftward',     'Black', 'Black', 'Horizontal', 'Vertical'
        'Upward',   'Rightward',    'Black', 'Black', 'Horizontal', 'Vertical'
        'Downward', 'Rightward',    'Black', 'Black', 'Horizontal', 'Vertical'
        };

    % Replicate the modified Motion_NoColor array
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

    M_C_Condition = Shuffle(Motion_Color, 2);


    for runIdx = 1:runNumber

        runTrials = cell(trialsPerRun, 6);

        runTrials(1, :) = NM_NC_Condition(1, :);
        runTrials(2, :) = M_C_Condition(1, :);

        usedMotions = M_C_Condition(1, 1:2);
        usedColors = M_C_Condition(1, 3:4);

        for mInd = 1:length(M_NC_Condition)
            if ~isequal(usedMotions(1), M_NC_Condition(mInd, 1)) && ~isequal(usedMotions(2), M_NC_Condition(mInd, 2))
                break
            end
        end

        for cInd = 1:length(NM_C_Condition)
            if ~isequal(usedColors, NM_C_Condition(cInd,3:4))
                break
            end
        end

        runTrials(3,:) = M_NC_Condition(mInd,:);
        runTrials(4,:) = NM_C_Condition(cInd,:);

        M_C_Condition(1, :) = [];
        NM_C_Condition(cInd, :) = [];
        M_NC_Condition(mInd, :) = [];


        runTrials = runTrials(randperm(size(runTrials, 1)), :);


        % Convert cell array to table
        data = cell2table(runTrials, 'VariableNames', {'Motion1', 'Motion2', 'Color1', 'Color2', 'Orientation1', 'Orientation2'});

        % Write table to CSV file
        writetable(data, sprintf('sub-%02d_run-%02d_IOG.csv', subjectNum, runIdx));
    end
end
end