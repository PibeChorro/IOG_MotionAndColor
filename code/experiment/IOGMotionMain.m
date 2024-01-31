
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

design.stimulusPresentationTime = 120 - ptb.ifi/2;
design.ITI                      = 25 - ptb.ifi/2;
design.contrast                 = 0.33;                                % decreasing the contrast between rivaling stimuli prolonges the dominance time
design.stepSize                 = 0.875;                                % Original: 0.25, but to make in visual degrees we go up to 0.875. Step size for motion trials to reduce/increase velocity. (PixPerDeg/FramesPerSecond)*PixPerFrame
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

design.RectCoord = [...
    ptb.screenXpixels/2-design.stimSizeInPixelsX/2 - 20 ...
    ptb.screenYpixels/2-design.stimSizeInPixelsY/2 - 20 ...
    ptb.screenXpixels/2+design.stimSizeInPixelsX/2 + 20 ...
    ptb.screenYpixels/2+design.stimSizeInPixelsY/2 + 20];

% fixation cross
design.fixCrossCoords = [
    -design.fixCrossInPixelsX/2 design.fixCrossInPixelsX/2 0 0; ...
    0 0 -design.fixCrossInPixelsY/2 design.fixCrossInPixelsY/2
    ];

%% REPETITION MATRIX FOR MOTION SIMULATION
% TODO (VP): change limit of array from arbitrary 314 to a well thought
% through value

[design.xVertical, design.xHorizontal] = meshgrid(1:314);

design.alphaMask1 = zeros(size(design.xHorizontal));
design.alphaMask2 = design.alphaMask1;

design.xHorizontal(:,:,2) = design.xHorizontal(:,:,1);
design.xHorizontal(:,:,3) = design.xHorizontal(:,:,1);
design.xHorizontal(:,:,4) = design.alphaMask1;

design.xVertical(:,:,2) = design.xVertical(:,:,1);
design.xVertical(:,:,3) = design.xVertical(:,:,1);
design.xVertical(:,:,4) = design.alphaMask2;

%% ALPHA MASKS
% TODO (VP): make alpha mask values dynamic
design.alphaMask1(:,1:157) = 1;
design.alphaMask2(:,158:end) = 1;

%% DEFINE PTB KEYS STRUCT FOR KEYBOARD RESPONSE DATA

ptb.Keys.monocular = ptb.Keys.left;
ptb.Keys.interocular = ptb.Keys.right;

%% PARTICIPANT INFORMATION
get = struct;

while true
    get.subjectNumber = input('Enter subject number: ', 's');  % Read input as a string
    [subNr, valid] = str2num(get.subjectNumber);
    % Check if the input is a valid numeric value
    if valid
        get.subjectNumber = subNr; 
        break;
    else % Convert the valid input to a number
        disp('Invalid input. Please enter a valid numeric value for the subject number.');
    end
end

get.folderName = fullfile('../../rawdata/', sprintf('sub-%02d', get.subjectNumber));
% Check if the folder exists, create it if it doesn't
if ~exist(get.folderName, 'dir')
    mkdir(get.folderName);
end
if ~exist(fullfile(get.folderName, 'participantInfo.mat'),'file')
    % Initialize participantInfo structure
    participantInfo = struct('age', [], 'gender', [], 'ExperimentStatus', 'Not Completed');
    
    while true
        % Collect participant information
        participantInfo.age = input('Enter your age: ','s');
        [age, valid] = str2num(participantInfo.age);
        % Check if the input is a valid numeric value
        if valid
            % check subject age and if accidentally a complex
            % number was given
            if (age >= 18) && (isreal(age))
                participantInfo.age = age; 
                break;
            end
        else % Convert the valid input to a number
            disp('Invalid input. Please enter a valid numeric value for the subject number.');
        end
    end
    
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
                break;  % Exit the loop if a valid number is entered
            elseif str2double(gender) == 2
                participantInfo.gender = 'female';
                break;  % Exit the loop if a valid number is entered
            else
                participantInfo.gender = 'other';
                break;  % Exit the loop if a valid number is entered
            end
        end
    end
    % save participants info
    save(fullfile(get.folderName, 'participantInfo.mat'),'participantInfo');
end

while true
    get.runNumber = input('Enter run number [1-8]: ', 's');  % Read input as a string
    % Check if the input is a valid numeric value
    [runNr, valid] = str2num(get.runNumber);
    if valid && runNr <=8 && runNr > 0
        get.runNumber = runNr;  % Convert the valid input to a number
        break;  % Exit the loop if a valid number is entered
    else
        disp('Invalid input. Please enter a valid numeric value for the subject number.');
    end
end

if mod(get.subjectNumber, 2) == 0 % if subjectNumber is divisible by 2 with 0 remainder (aka number is even)
    ptb.Keys.left = ptb.Keys.monocular;
    ptb.Keys.right = ptb.Keys.interocular;
else % if subjectNumber is not divisible without 0 remainders (aka number is odd)
    ptb.Keys.right = ptb.Keys.monocular; 
    ptb.Keys.left = ptb.Keys.interocular;
end

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
    Experiment_Instructions(ptb,get,design);
catch instructionsError
    sca;
    close all;
    rethrow(instructionsError);
end

WaitSecs(0.5);

%% DATA READING:
try
    % Generate the file path based on subject number and run number
    dataFilePath = fullfile('../../rawdata/', sprintf('sub-%02d/sub-%02d_run-%02d_conditions.csv', get.subjectNumber, get.subjectNumber, get.runNumber));
    
    % Check if the file exists before attempting to read it
    if exist(dataFilePath, 'file')
        data = readtable(dataFilePath);
        data = table2struct(data, 'toScalar', true);
        get.data = data;
        disp('Data loaded successfully...');
    else
        disp('Error: Data file not found. Please make sure the file path is correct.');
    end

catch readingError
    sca;
    close all;
    rethrow(readingError);
end

%% DELETION OF PREVIOUS KEYBOARD PRESSES AND INITIATION OF NEW KEYBOARD PRESSES MEMORY
    % Stop and remove events in queue for Keyboard2
    KbQueueStop(ptb.Keyboard2);
    KbEventFlush(ptb.Keyboard2);
    KbQueueCreate(ptb.Keyboard2);

    % Start the queue for Keyboard2
    KbQueueStart(ptb.Keyboard2);


%%  INTRODUCTION OF THE CASES/CONDITIONS:
% Introducing the different conditions of the experiment along with assigned variables
% Create 4D matrices for horizontal and vertical gratings
try
    for trial = 1:4
        if any(strcmp(data.Motion1(trial), 'Upward'))
            Motion1 = 1;
    
            if any(strcmp(data.Motion2(trial), 'Rightward'))
                Motion2 = -1;
            elseif any(strcmp(data.Motion2(trial), 'Leftward'))
                Motion2 = 1;
            end
    
        elseif any(strcmp(data.Motion1(trial), 'Downward'))
            Motion1 = -1;
    
            if any(strcmp(data.Motion2(trial), 'Rightward'))
                Motion2 = -1;
            elseif any(strcmp(data.Motion2(trial), 'Leftward'))
                Motion2 = 1;
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
            error('Impossible color');
        end
  
  
    vbl = Screen('Flip', ptb.window);


    Screen('SelectStereoDrawBuffer', ptb.window, 0);
    Screen('DrawLines', ptb.window, design.fixCrossCoords, ...
            ptb.lineWidthInPix, ptb.black, [ptb.xCenter ptb.yCenter]);

    Screen('SelectStereoDrawBuffer', ptb.window, 1);
    Screen('DrawLines', ptb.window, design.fixCrossCoords, ...
            ptb.lineWidthInPix, ptb.black, [ptb.xCenter ptb.yCenter]);
    Screen('DrawingFinished', ptb.window);
    Screen('Flip', ptb.window);

    if trial == 1
        WaitSecs(5);
    else
        WaitSecs(design.ITI);
    end

    Screen('SelectStereoDrawBuffer', ptb.window, 0);
    Screen('DrawLines', ptb.window,design.fixCrossCoords, ...
        ptb.lineWidthInPix, ptb.white, [ptb.xCenter ptb.yCenter]);

    Screen('SelectStereoDrawBuffer', ptb.window, 1);
    Screen('DrawLines', ptb.window, design.fixCrossCoords, ...
        ptb.lineWidthInPix, ptb.white, [ptb.xCenter ptb.yCenter]);
    Screen('DrawingFinished', ptb.window);
    Screen('Flip', ptb.window);
    WaitSecs(2);

        % get timing of trial onset
        get.data.trialOnset(trial) = GetSecs;
        % updating the x arrays 
        while vbl - get.data.trialOnset(trial) < design.stimulusPresentationTime
    
            design.xHorizontal = design.xHorizontal + Motion1 * design.stepSize;
            design.xVertical = design.xVertical + Motion2 * design.stepSize;
        
            % TODO (VP): set factor for sinus wave as a variable 
            horizontalGrating = sin(design.xHorizontal*design.scalingFactor); % creates a sine-wave grating of spatial frequency 0.1 (CPM oder CPD?)
            leftScaledHorizontalGrating = ((horizontalGrating+1)/2) * design.contrast; % normalizes value range from 0 to 1 instead of -1 to 1
        
            verticalGrating = sin(design.xVertical*design.scalingFactor);
            leftScaledVerticalGrating = ((verticalGrating+1)/2) * design.contrast;
    
            leftScaledHorizontalGrating(:,:,turnoffIndicesHorizontal) = 0;
            leftScaledVerticalGrating(:,:,turnoffIndicesVertical) = 0;
    
            rightScaledHorizontalGrating = leftScaledHorizontalGrating;
            rightScaledVerticalGrating = leftScaledVerticalGrating;
        
            leftScaledHorizontalGrating(:,:,4)  = design.alphaMask1;
            leftScaledVerticalGrating(:,:,4) = design.alphaMask2;
           
            rightScaledHorizontalGrating(:,:,4) = design.alphaMask2;
            rightScaledVerticalGrating(:,:,4) = design.alphaMask1;
    
            %% CREATION OF STIMULI AND CLOSING SCREENS
            % Creation of experimental stimuli with different features (textures, colors…)
           
            % Select left image buffer for true color image:
            Screen('SelectStereoDrawBuffer', ptb.window, 0);
            Screen('DrawTexture', ptb.window, backGroundTexture);
            Screen('FillRect', ptb.window, ptb.BackgroundColor, design.RectCoord);
        
            tex1 = Screen('MakeTexture', ptb.window, leftScaledHorizontalGrating);  % create texture for stimulus
            Screen('DrawTexture', ptb.window, tex1, [], design.destinationRect);
        
            tex2 = Screen('MakeTexture', ptb.window, leftScaledVerticalGrating);    % create texture for stimulus
            Screen('DrawTexture', ptb.window, tex2, [], design.destinationRect);
        
            Screen('DrawLines', ptb.window, design.fixCrossCoords, ...
                ptb.lineWidthInPix, ptb.white, [ptb.xCenter ptb.yCenter]);
        
            % Select right image buffer for true color image:
            Screen('SelectStereoDrawBuffer', ptb.window, 1);
            
            Screen('DrawTexture', ptb.window, backGroundTexture);
            Screen('FillRect', ptb.window, ptb.BackgroundColor, design.RectCoord);
        
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
    
catch stimuliGenerationError
    sca;
    close all;
    rethrow(stimuliGenerationError);
end

%% Saving Data
get.end = 'Success';
% get.participantsInfo = participantInfo;
savedata(get,ptb,design)
Screen('CloseAll');
end