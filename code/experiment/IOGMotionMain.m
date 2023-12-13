%% GENERAL FUNCTION AND MONITOR SETUP:

% Function creation for the experimental code.
function IOGMotionMain(setUp)

% Setup input for the monitor being used.

if nargin < 1
    setUp = 'Sarah Laptop';
end

%% OPEN PSYCHTOOLBOX FUNCTION:

% Opening psychtoolbox function ptb.

try
    ptb = PTBSettingsIOGMotion(setUp);
catch PTBERROR
    sca;
    rethrow(PTBERROR);
end
%% DESIGN-RELATED:

% Different design-related information.

design = getInstructions();
% the scenario determines the type(s) of low level cues for interocular
% grouping:

% 1: only orientation - no motion, no color
% 2: orientation and color - no motion
% 3: orientation and motion - no color
% 4: orientation, color and motion

design.scenario = 4;

design.stimulusPresentationTime = 5 - ptb.ifi/2;
design.ITI                      = 3 - ptb.ifi/2;
design.stimSizeInDegrees        = 1.7;
design.fixCrossInDegrees        = 0.25;
design.mondreanInDegrees        = 5;
design.whiteBackgroundInDegrees = 2.5;

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
%% PARTICIPANT INFORMATION

% Collect participant information
participantInfo.age = input('Enter your age: ');
participantInfo.gender = input('Enter your gender: ', 's');

% Get subject number from user input
subjectNumber = input('Enter subject number: ');

% Generate filename based on subject number
filename = sprintf('Subject%d_ParticipantInfo.xlsx', subjectNumber);

%% INSTRUCTIONS:

% Experimental instructions with texts (using experimental function from another mat script).

try
    Experiment_Instructions(ptb);
catch instructionsError
    sca;
    rethrow(instructionsError);
end


%% FUSION TEST:

% Fusion test implementation before the experiment starts (Using the function of the other fusion script that was created).

try
    alignFusion(ptb, design);
catch alignFusionError
    sca;
    rethrow(alignFusionError);
end

%% DATA READING:

% Reading the different “Run” Excel files to be used later and being assigned to specific variable names.

try
    data = readtable('Run_1.xlsx');
catch readDataError
    sca;
    rethrow(readDataError);
end

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

% Introducing the different conditions of the experiment along with assigned variables.

% get a Flip for timing
vbl = Screen('Flip',ptb.window);

% Create 4D matrices for horizontal and vertical gratings
% figure out issue with the zeros and grating formation here.
fourxHorizontal = zeros(size(xHorizontal, 1), size(xHorizontal, 2), 4);
fourxVertical = zeros(size(xVertical, 1), size(xVertical, 2), 4, 1);
yHorizontal = sin(fourxHorizontal);
yHorizontal = ((yHorizontal+1)/2);
yVertical = sin(fourxVertical);
yVertical = ((yVertical+1)/2);

for trial = 1:length(data.Trial)
    % get color indices for gratings
    if strcmp(data.Color2, 'red') % tell VP about switching data.Color1 with data.Color2
        verticalIndices = 1;
        horizontalIndices = 2;
    elseif strcmp(data.Color2, 'green')
        verticalIndices = 2;
        horizontalIndices = 1;
    else
        verticalIndices = 1:3;
        horizontalIndices = 1:3;
    end


    % get timing of trial onset
    trialOnset = GetSecs;
    % updating the x arrays 
    while vbl - trialOnset < design.stimulusPresentationTime
        fourxHorizontal = fourxHorizontal + data.Motion1(trial);
        fourxVertical = fourxVertical + data.Motion2(trial);
    
        % TODO (VP): set factor for sinus wave as a variable 
        horizontalGrating = sin(fourxHorizontal*0.3); % creates a sine-wave grating of spatial frequency 0.3
        leftScaledHorizontalGrating = ((horizontalGrating+1)/2); % normalizes value range from 0 to 1 instead of -1 to 1
    
        verticalGrating = sin(fourxVertical*0.3);
        leftScaledVerticalGrating = ((verticalGrating+1)/2);

        leftScaledHorizontalGrating(:,:,horizontalIndices) = yHorizontal(:,:,horizontalIndices);
        leftScaledVerticalGrating(:,:,verticalIndices) = yVertical(:,:,verticalIndices);
        rightScaledVerticalGrating(:,:,verticalIndices) = leftScaledVerticalGrating(:,:,verticalIndices);
        rightScaledHorizontalGrating(:,:,horizontalIndices) = leftScaledHorizontalGrating(:,:,horizontalIndices);

    
        leftScaledHorizontalGrating(:,:,4)  = alphaMask1;
        leftScaledVerticalGrating(:,:,4) = alphaMask2;
        
        rightScaledHorizontalGrating = leftScaledHorizontalGrating;
        rightScaledHorizontalGrating(:,:,4) = alphaMask2;

        rightScaledVerticalGrating = leftScaledVerticalGrating;
        rightScaledVerticalGrating(:,:,4) = alphaMask1;



        %% CREATION OF STIMULI AND CLOSING SCREENS
        % Creation of experimental stimuli with different features (textures, colors…)
    
        % Select image buffer for true color image:
        Screen('SelectStereoDrawBuffer', ptb.window, 0);
        Screen('DrawTexture', ptb.window, backGroundTexture);
    
        tex1 = Screen('MakeTexture', ptb.window, leftScaledHorizontalGrating);     % create texture for stimulus
        Screen('DrawTexture', ptb.window, tex1, [], design.destinationRect);
    
        tex2 = Screen('MakeTexture', ptb.window, leftScaledVerticalGrating);     % create texture for stimulus
        Screen('DrawTexture', ptb.window, tex2, [], design.destinationRect);
    
        Screen('DrawLines', ptb.window, design.fixCrossCoords, ...
            ptb.lineWidthInPix, ptb.white, [ptb.xCenter ptb.yCenter]);
    
        % Select image buffer for true color image:
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
    Screen('SelectStereoDrawBuffer', ptb.window, 0);
    Screen('DrawLines', ptb.window, design.fixCrossCoords, ...
            ptb.lineWidthInPix, ptb.white, [ptb.xCenter ptb.yCenter]);

    Screen('SelectStereoDrawBuffer', ptb.window, 1);
    Screen('DrawLines', ptb.window, design.fixCrossCoords, ...
            ptb.lineWidthInPix, ptb.white, [ptb.xCenter ptb.yCenter]);
    Screen('DrawingFinished', ptb.window);
    vbl = Screen('Flip', ptb.window);
    WaitSecs(design.ITI)
end


%% SAVING PARTICIPANT FILES ACCORDING TO THE RUN NUMBER:

% Saving participant’s mat files

% if ~isfile(filename)
%     headers = {'SubjectNumber', 'Age', 'Gender'};
%     xlswrite(filename, headers, 'Sheet1', 'A1');
% end
% 
% % Append participant information to the Excel file
% xlswrite(filename, [subjectNumber, participantInfo.age, participantInfo.gender], 'Sheet1', 'A2');

end
