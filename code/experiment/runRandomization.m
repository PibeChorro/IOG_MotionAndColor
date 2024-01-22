function data = runRandomization()

% code for pseudorandomizing the different conditions of the interocular
% grouping experiment. there must be eight runs for each subject (ideally
% 24 subjects) and in each run there must be four unique trials (never the
% same motion or color combination in the same run file). this code
% generates eight csv files for the 24 subjects with four trials in each
% csv file.


% for loop that iterates over the different 24 subjects to be recruited
for subjectNum = 1:24

    subFolder = fullfile('..', '..','rawdata', sprintf('sub-%02d', subjectNum));
    if ~exist(subFolder,'dir')
        mkdir(subFolder)
    end

    % Number of runs
    runNumber = 8;

    % Number of trials per run
    trialsPerRun = 4;
    
    % array with the NoMotion_NoColor combinations
    % only written once here as opposed to the other conditions since there
    % are no other different combinations possible for this specific
    % condition.
    NoMotion_NoColor = {
        'No Motion', 'No Motion', 'Black', 'Black', 'Horizontal',   'Vertical' , 'NoMotionNoColor'     
        };

    NM_NC_Condition = NoMotion_NoColor; % doesn't need to be replicated like the others since we just use the only possible
                                        % combination for all runs.

    NoMotion_Color = {
        'No Motion', 'No Motion', 'Green',  'Red',      'Horizontal', 'Vertical', 'NoMotionColor' 
        'No Motion', 'No Motion', 'Red',    'Green',    'Horizontal', 'Vertical', 'NoMotionColor' 
        };

    NM_C_Condition = repmat(NoMotion_Color, 4, 1); % replicates the NoMotion_Color array

    Motion_NoColor = {
        'Upward',   'Leftward',     'Black', 'Black', 'Horizontal', 'Vertical', 'MotionNoColor' 
        'Downward', 'Leftward',     'Black', 'Black', 'Horizontal', 'Vertical', 'MotionNoColor' 
        'Upward',   'Rightward',    'Black', 'Black', 'Horizontal', 'Vertical', 'MotionNoColor' 
        'Downward', 'Rightward',    'Black', 'Black', 'Horizontal', 'Vertical', 'MotionNoColor' 
        };

    M_NC_Condition = repmat(Motion_NoColor, 2, 1);
    
    % eight different possibilities in this condition since it has all the
    % grouping cues: Motion, color, and orientation.

    Motion_Color = {
        'Upward',   'Leftward',     'Red', 'Green', 'Horizontal', 'Vertical', 'MotionColor' 
        'Downward', 'Leftward',     'Red', 'Green', 'Horizontal', 'Vertical', 'MotionColor' 
        'Upward',   'Rightward',    'Red', 'Green', 'Horizontal', 'Vertical', 'MotionColor' 
        'Downward', 'Rightward',    'Red', 'Green', 'Horizontal', 'Vertical', 'MotionColor' 
        'Upward',   'Leftward',     'Green', 'Red', 'Horizontal', 'Vertical', 'MotionColor' 
        'Downward', 'Leftward',     'Green', 'Red', 'Horizontal', 'Vertical', 'MotionColor' 
        'Upward',   'Rightward',    'Green', 'Red', 'Horizontal', 'Vertical', 'MotionColor' 
        'Downward', 'Rightward',    'Green', 'Red', 'Horizontal', 'Vertical', 'MotionColor' 
        };

    M_C_Condition = Shuffle(Motion_Color, 2);

    % for loop that iterates eight times and creates the csv runs for each subject
    for runIdx = 1:runNumber

        runTrials = cell(trialsPerRun, 7);

        runTrials(1, :) = NM_NC_Condition(1, :);
        runTrials(2, :) = M_C_Condition(1, :);

        usedMotions = M_C_Condition(1, 1:2);
        usedColors = M_C_Condition(1, 3:4);
        

        % for loop for motion pseudorandomization, makes sure that the
        % motion combinations of M_NC_Condition and Motion_Color are never
        % equal within one run file.

        for mInd = 1:length(M_NC_Condition)
            if ~isequal(usedMotions(1), M_NC_Condition(mInd, 1)) && ~isequal(usedMotions(2), M_NC_Condition(mInd, 2))
                break
            end
        end
        

        % for loop for color pseudorandomization, makes sure the color
        % combinations of NM_C_Condition and Motion_Color are never 
        % equal within one run file.

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


        runTrials = runTrials(randperm(size(runTrials, 1)), :); % shuffles the order of the trials in a random manner


        % Converts cell array to table
        data = cell2table(runTrials, 'VariableNames', {'Motion1', 'Motion2', 'Color1', 'Color2', 'Orientation1', 'Orientation2', 'Condition'});

        % Writes table to CSV file
        writetable(data, fullfile(subFolder,sprintf('sub-%02d_run-%02d_conditions.csv', subjectNum, runIdx)));
    end
end
end