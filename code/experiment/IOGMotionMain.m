
%% GENERAL FUNCTION AND MONITOR SETUP:

% Function creation for the experimental code.
function IOGMotionMain(setUp)

% Setup input for the monitor being used.

if nargin < 1
    setUp = 'CIN-experimentroom';
end

%% OPEN PSYCHTOOLBOX FUNCTION:

% Opening psychtoolbox function ptb.
 ptb = PTBSettingsIOGMotion(setUp);


%% DESIGN-RELATED:

% Different design-related information.

design = getInstructions();
% the scenario determines the type(s) of low level cues for interocular
% grouping:

% 1: only orientation - no motion, no color
% 2: orientation and color - no motion
% 3: orientation and motion - no color
% 4: orientation, color and motion

design.stimulusPresentationTime = 6 - ptb.ifi/2;
design.ITI                      = 3 - ptb.ifi/2;
design.contrast                 = 0.33;                                      % decreasing the contrast between rivaling stimuli prolonges the dominance time
design.stepSize                 = 0.25;                                     % step size for motion trials to reduce/increase velocity
design.scalingFactor            = 0.1;
design.stimSizeInDegrees        = 1.7;
design.fixCrossInDegrees        = 0.25;
design.mondreanInDegrees        = 5;
design.whiteBackgroundInDegrees = 2.5;
design.useET = false;

design.stimSizeInPixelsX        = round(ptb.PixPerDegWidth*design.stimSizeInDegrees);
design.stimSizeInPixelsY        = round(ptb.PixPerDegHeight*design.stimSizeInDegrees);

design.fixCrossInPixelsX        = round(ptb.PixPerDegWidth*design.fixCrossInDegrees);
design.fixCrossInPixelsY        = round(ptb.PixPerDegHeight*design.fixCrossInDegrees);

design.mondreanInPixelsX        = int16(round(ptb.PixPerDegWidth*design.mondreanInDegrees));
design.mondreanInPixelsY        = int16(round(ptb.PixPerDegHeight*design.mondreanInDegrees));
mondreanMasks = make_mondrian_masks(double(design.mondreanInPixelsX), ...
    double(design.mondreanInPixelsY),1,1,1);
design.thisMask = rgb2gray(mondreanMasks{1});
backGroundTexture = Screen('MakeTexture', ptb.window, design.thisMask);

% resize stimuli
% define a rectangle where the stimulus is drawn
design.destinationRect = [...
    ptb.screenXpixels/2-design.stimSizeInPixelsX/2 ...
    ptb.screenYpixels/2-design.stimSizeInPixelsY/2 ...
    ptb.screenXpixels/2+design.stimSizeInPixelsX/2 ...
    ptb.screenYpixels/2+design.stimSizeInPixelsY/2];

% fixation cross
design.fixCrossCoords = [
    -design.fixCrossInPixelsX/2 design.fixCrossInPixelsX/2 0 0; ...
    0 0 -design.fixCrossInPixelsY/2 design.fixCrossInPixelsY/2
    ];

%% DEFINE PTB KEYS STRUCT FOR KEYBOARD RESPONSE DATA

ptb.Keys.monocular = ptb.Keys.left;
ptb.Keys.interocular = ptb.Keys.right;

%% PARTICIPANT INFORMATION
get = struct;
% Initialize participantInfo structure
participantInfo = struct('age', [], 'gender', [], 'ExperimentStatus', 'Not Completed');

% Collect participant information
participantInfo.age = input('Enter your age: ');

% Get gender from user input (1 for male, 2 for female)

while true
    gender = input('Enter your gender (1 for male, 2 for female, 3 for other): ', 's');
    
    % Check if the input is a valid numeric value
    if isempty(str2double(gender)) || ~ismember(str2double(gender), [1, 2, 3])
        disp('Invalid input. Please enter 1 for male, 2 for female or 3 for other');
    else
        % Convert gender to a string representation
        if str2double(gender) == 1
            participantInfo.gender = 'male';
        elseif str2double(gender) == 2
            participantInfo.gender = 'female';
        else
            participantInfo.gender = 'other';
        end
        break;  % Exit the loop if a valid number is entered
    end
end

while true
    get.subjectNumber = input('Enter subject number: ', 's');  % Read input as a string
    
    % Check if the input is a valid numeric value
    if isempty(str2double(get.subjectNumber)) % checks if the entered string cannot be converted to a numeric value.
        disp('Invalid input. Please enter a valid numeric value for the subject number.');
    else
        get.subjectNumber = str2double(get.subjectNumber);  % Convert the valid input to a number
        break;  % Exit the loop if a valid number is entered
    end
end

while true
    get.runNumber = input('Enter run number: ', 's');  % Read input as a string
    
    % Check if the input is a valid numeric value
    if isempty(str2double(get.runNumber)) % checks if the entered string cannot be converted to a numeric value.
        disp('Invalid input. Please enter a valid numeric value for the subject number.');
    else
        get.runNumber = str2double(get.runNumber);  % Convert the valid input to a number
        break;  % Exit the loop if a valid number is entered
    end
end

if mod(get.subjectNumber, 2) == 0 % if subjectNumber is divisible by 2 with 0 remainder (aka number is even)
    ptb.Keys.left = ptb.Keys.monocular;
    ptb.Keys.right = ptb.Keys.interocular;
else % if subjectNumber is not divisible without 0 remainders (aka number is odd)
    ptb.Keys.right = ptb.Keys.monocular; 
    ptb.Keys.left = ptb.Keys.interocular;
end

% Specify the number of runs for your experiment
% numRuns = 8;  % Adjust this based on your experiment

% Create CSV files for each run inside the subject folder
get.folderName = fullfile('../../rawdata/', sprintf('sub-%02d', get.subjectNumber));

% Check if the folder exists, create it if it doesn't
if ~exist(get.folderName, 'dir')
    mkdir(get.folderName);
end

% for runNumber = 1:numRuns
%     runFileName = fullfile(get.folderName, sprintf('sub-%02d-run-%02d-subjectInfo.csv', get.subjectNumber, runNumber));
%     
%     % Check if CSV file already exists
%     if exist(runFileName, 'file')
%         userResponse = input(['Warning: CSV file for this subject and run already exists. ' ...
%             'Do you want to proceed and overwrite the existing file? (yes/no): '], 's');
%         if strcmpi(userResponse, 'no')
%             sca;
%             close all;
%             error('User chose not to proceed. Exiting.');
%         end
%     end
%     
%     % Write combined data to the CSV file
%     writetable(struct2table(participantInfo), runFileName);
% end

%% FUSION TEST:

% Fusion test implementation before the experiment starts (Using the function of the other fusion script that was created).

try
    alignFusion(ptb, design);
catch alignFusionError
    sca;
    rethrow(alignFusionError);
end

WaitSecs(0.5);
%% INSTRUCTIONS:

% Experimental instructions with texts (using experimental function from another mat script).
try
    Experiment_Instructions(ptb,get);
catch instructionsError
    sca;
    close all;
    rethrow(instructionsError);
end

%% DATA READING:

try   
    data = readtable('../../rawdata/sub-01/sub-01_run-01_conditions.csv');

catch readingError
    sca;
    rethrow(readingError);
end

    data = table2struct(data, 'toScalar', true);
    get.data = data;

%% DELETION OF PREVIOUS KEYBOARD PRESSES AND INITIATION OF NEW KEYBOARD PRESSES MEMORY

%% Stop and remove events in queue
%     KbQueueStop(ptb.Keyboard2);
%     KbEventFlush(ptb.Keyboard2);

    % Stop and remove events in queue for Keyboard2
    KbQueueStop(ptb.Keyboard2);
    KbEventFlush(ptb.Keyboard2);
    KbQueueCreate(ptb.Keyboard2);

    % Start the queue for Keyboard2
    KbQueueStart(ptb.Keyboard2);

%% REPETITION MATRIX FOR MOTION SIMULATION

% TODO (VP): change limit of array from arbitrary 314 to a well thought
% through value

[xHorizontal, xVertical] = meshgrid(1:314);

%% ALPHA MASKS -- MONDREAN MASKS

alphaMask1  = zeros(size(xHorizontal));
alphaMask2 = alphaMask1;

% TODO (VP): make alpha mask values dynamic
alphaMask1(:,1:157) = 1;
alphaMask2(:,158:end) = 1;

%%  INTRODUCTION OF THE CASES/CONDITIONS:

% Introducing the different conditions of the experiment along with assigned variables
% Create 4D matrices for horizontal and vertical gratings
% figure out issue with the zeros and grating formation here

xHorizontal(:,:,2) = xHorizontal(:,:,1);
xHorizontal(:,:,3) = xHorizontal(:,:,1);
xHorizontal(:,:,4) = xHorizontal(:,:,1);

xVertical(:,:,2) = xVertical(:,:,1);
xVertical(:,:,3) = xVertical(:,:,1);
xVertical(:,:,4) = xVertical(:,:,1);

for trial = 1:4
    if any(strcmp(data.Motion1(trial), 'Upward'))
        Motion1 = 1;

        if any(strcmp(data.Motion2(trial), 'Rightward'))
            Motion2 = 1;
        elseif any(strcmp(data.Motion2(trial), 'Leftward'))
            Motion2 = -1;
        end

    elseif any(strcmp(data.Motion1(trial), 'Downward'))
        Motion1 = -1;

        if any(strcmp(data.Motion2(trial), 'Rightward'))
            Motion2 = 1;
        elseif any(strcmp(data.Motion2(trial), 'Leftward'))
            Motion2 = -1;
        end
        
    elseif any(strcmp(data.Motion1(trial), 'No Motion'))
        Motion1 = 0;
        Motion2 = 0;
    else
        error('Impossible motion');
    end

    % get color indices for gratings
    if strcmp(data.Color2(trial), 'Red')
        turnoffIndicesVertical = 2:4;
        turnoffIndicesHorizontal = [1 3 4];
    elseif strcmp(data.Color2(trial), 'Green')
        turnoffIndicesVertical = [1 3 4];
        turnoffIndicesHorizontal = 2:4;
    elseif strcmp(data.Color1(trial),'Black')
        turnoffIndicesVertical = 4;
        turnoffIndicesHorizontal = 4;
    else
        error('Impossible color')
    end

    Screen('SelectStereoDrawBuffer', ptb.window, 0);
    Screen('DrawLines', ptb.window, design.fixCrossCoords, ...
            ptb.lineWidthInPix, ptb.white, [ptb.xCenter ptb.yCenter]);

    Screen('SelectStereoDrawBuffer', ptb.window, 1);
    Screen('DrawLines', ptb.window, design.fixCrossCoords, ...
            ptb.lineWidthInPix, ptb.white, [ptb.xCenter ptb.yCenter]);
    Screen('DrawingFinished', ptb.window);
    vbl = Screen('Flip', ptb.window);
    WaitSecs(design.ITI);

    % get timing of trial onset
    get.data.trialOnset(trial) = GetSecs;
    % updating the x arrays 
    while vbl - get.data.trialOnset(trial) < design.stimulusPresentationTime

        xHorizontal = xHorizontal + Motion1 * design.stepSize;
        xVertical = xVertical + Motion2 * design.stepSize;
    
        % TODO (VP): set factor for sinus wave as a variable 
        horizontalGrating = sin(xHorizontal*design.scalingFactor); % creates a sine-wave grating of spatial frequency 0.3
        leftScaledHorizontalGrating = ((horizontalGrating+1)/2) * design.contrast; % normalizes value range from 0 to 1 instead of -1 to 1
    
        verticalGrating = sin(xVertical*design.scalingFactor);
        leftScaledVerticalGrating = ((verticalGrating+1)/2) * design.contrast;

        leftScaledHorizontalGrating(:,:,turnoffIndicesHorizontal) = 0;
        leftScaledVerticalGrating(:,:,turnoffIndicesVertical) = 0;

        rightScaledHorizontalGrating = leftScaledHorizontalGrating;
        rightScaledVerticalGrating = leftScaledVerticalGrating;
    
        leftScaledHorizontalGrating(:,:,4)  = alphaMask1;
        leftScaledVerticalGrating(:,:,4) = alphaMask2;
       
        rightScaledHorizontalGrating(:,:,4) = alphaMask2;
        rightScaledVerticalGrating(:,:,4) = alphaMask1;


        %% CREATION OF STIMULI AND CLOSING SCREENS
        % Creation of experimental stimuli with different features (textures, colors…)
       
        % Select left image buffer for true color image:
        Screen('SelectStereoDrawBuffer', ptb.window, 0);
        Screen('DrawTexture', ptb.window, backGroundTexture);
    
        tex1 = Screen('MakeTexture', ptb.window, leftScaledHorizontalGrating);  % create texture for stimulus
        Screen('DrawTexture', ptb.window, tex1, [], design.destinationRect);
    
        tex2 = Screen('MakeTexture', ptb.window, leftScaledVerticalGrating);    % create texture for stimulus
        Screen('DrawTexture', ptb.window, tex2, [], design.destinationRect);
    
        Screen('DrawLines', ptb.window, design.fixCrossCoords, ...
            ptb.lineWidthInPix, ptb.white, [ptb.xCenter ptb.yCenter]);
    
        % Select right image buffer for true color image:
        Screen('SelectStereoDrawBuffer', ptb.window, 1);
        Screen('DrawTexture', ptb.window, backGroundTexture);
    
        tex1Other = Screen('MakeTexture', ptb.window, rightScaledHorizontalGrating);     % create texture for stimulus
        Screen('DrawTexture', ptb.window, tex1Other, [], design.destinationRect);
    
        tex2Other = Screen('MakeTexture', ptb.window, rightScaledVerticalGrating);     % create texture for stimulus
        Screen('DrawTexture', ptb.window, tex2Other, [], design.destinationRect);
    
        Screen('DrawLines', ptb.window, design.fixCrossCoords, ptb.lineWidthInPix, ptb.white, [ptb.xCenter ptb.yCenter]);
    
        Screen('DrawingFinished', ptb.window);
        vbl = Screen('Flip', ptb.window);
    
        Screen('Close', tex1);
        Screen('Close', tex2);
        Screen('Close', tex1Other);
        Screen('Close', tex2Other);
    end
    get.data.trialOffset(trial) = GetSecs;
end

%% saving data
get.end = 'Success';
get.participantsInfo = participantInfo;
savedata(get,ptb,design)
Screen('CloseAll');
end