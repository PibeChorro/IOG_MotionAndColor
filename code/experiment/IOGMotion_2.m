%% GENERAL FUNCTION AND MONITOR SETUP:
 
% Function creation for the experimental code.
function IOGMotionMain_2(setUp)

% Setup input for the monitor being used.

if nargin < 1
    setUp = 'CIN-Mac-Setup' ;

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

design.stimulusPresentationTime = 90 - ptb.ifi/2;
design.ITI                      = 10 - ptb.ifi/2;
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

% Variable creation that saves subjects’ information such as age, sex, file number/s…

participantInfo.age = input('My Age is  ');
participantInfo.gender = input('My Gender is    ');
filename = sprintf('Participant_.mat');


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
    motionColumns = data.Motion1 & data.Motion2;
    colorColumns = data.Color1 & data.Color2;

    if motionColumns == 0
       isMotion = 'no motion';
    elseif motionColumns == 1
        isMotion = 'motion';
     end
        
     if strcmp(data.Color1,'green')
         isColor = 'green';
     elseif strcmp(data.Color1, 'red')
         isColor = 'red';
     elseif strcmp(data.Color2, 'green')
         isColor = 'green';
     elseif strcmp(data.Color2, 'red')
         isColor = 'red';
     end

     if colorColumns == 0
        isColor = 'no color';
     elseif colorColumns == 'green'
         isColor = 'color';
     elseif colorColumns == 'red'
         isColor = 'color';
     end

     trialString = ['We are in a ' isMotion isColor ' trial'];
     fprintf(trialString);

catch readDataError
    sca;
    rethrow(readDataError);
end

%% REPETITION MATRIX FOR MOTION SIMULATION

x = repmat(1:314,314,1);

%% ALPHA MASKS -- MONDREAN MASKS

alphaMask1  = zeros(size(x));
alphaMask2 = alphaMask1;
alphaMask1(:,1:157) = 1;
alphaMask2(:,158:end) = 1;

%%  INTRODUCTION OF THE CASES/CONDITIONS:
 
% Introducing the different conditions of the experiment along with assigned variables.
 
        while true
            switch design.scenario
                case 1 % 1: only orientation - no motion, no color
                    rightGratingFreq1 = sin(x*0.3); % creates a sine-wave grating of spatial frequency 0.3
                    scaledOrientationGrating = ((rightGratingFreq1+1)/2); % normalizes value range from 0 to 1 instead of -1 to 1

                    rightgratingfreq2 = zeros(size(scaledOrientationGrating));
                    rightgratingfreq2(:,:,1) = scaledOrientationGrating(:,:,1)';

                    leftgratingfreq1 = scaledOrientationGrating;
                    leftgratingfreq2(:,:,1) = scaledOrientationGrating(:,:,1)';

                    scaledOrientationGrating(:,:,2)  = alphaMask1;
                    rightgratingfreq2(:,:,2) = alphaMask2;

                    leftgratingfreq1(:,:,2) = alphaMask2;
                    leftgratingfreq2(:,:,2) = alphaMask1;

                case 2 % 2: orientation and color - no motion
                    rightGratingFreq1 = sin(x*0.2);
                    scaledOrientationGrating = ((rightGratingFreq1+1)/2);

                    scaledOrientationGrating(:,:,2) = zeros(size(x));
                    scaledOrientationGrating(:,:,3) = zeros(size(x));
                    rightgratingfreq2 = zeros(size(scaledOrientationGrating));
                    rightgratingfreq2(:,:,2) = scaledOrientationGrating(:,:,1)';

                    leftgratingfreq1 = scaledOrientationGrating;
                    leftgratingfreq2 = rightgratingfreq2;
                    scaledOrientationGrating(:,:,4) = alphaMask1;
                    rightgratingfreq2(:,:,4) = alphaMask2;

                    leftgratingfreq1(:,:,4) = alphaMask2;
                    leftgratingfreq2(:,:,4) = alphaMask1;
                case 3 % 3: orientation and motion - no color
                    x = x + randi([-1 1]);
                    rightGratingFreq1 = sin(x*0.3);
                    scaledOrientationGrating = ((rightGratingFreq1+1)/2);

                    rightgratingfreq2 = zeros(size(scaledOrientationGrating));
                    rightgratingfreq2(:,:,1) = scaledOrientationGrating(:,:,1)';

                    leftgratingfreq1 = scaledOrientationGrating;
                    leftgratingfreq2 = rightgratingfreq2;

                    scaledOrientationGrating(:,:,2) = alphaMask1;
                    rightgratingfreq2(:,:,2) = alphaMask2;

                    leftgratingfreq1(:,:,2) = alphaMask2;
                    leftgratingfreq2(:,:,2) = alphaMask1;

%                     currentRun = 1;
%                     if ~isempty(motionDirectionsPerRun(currentRun))
%                        motionDirection = motionDirectionsPerRun(currentRun);
%                     end

                case 4 % 4: orientation, color and motion
                    x = x + randi([-1 1]);
                    rightGratingFreq1 = sin(x*0.2);
                    scaledOrientationGrating = ((rightGratingFreq1+1)/2);

                    scaledOrientationGrating(:,:,2) = zeros(size(x));
                    scaledOrientationGrating(:,:,3) = zeros(size(x));
                    rightgratingfreq2 = zeros(size(scaledOrientationGrating));
                    rightgratingfreq2(:,:,2) = scaledOrientationGrating(:,:,1)';

                    leftgratingfreq1 = scaledOrientationGrating;
                    leftgratingfreq2 = rightgratingfreq2;
                    scaledOrientationGrating(:,:,4) = alphaMask1;
                    rightgratingfreq2(:,:,4) = alphaMask2;

                    leftgratingfreq1(:,:,4) = alphaMask2;
                    leftgratingfreq2(:,:,4) = alphaMask1;
%                     currentRun = 1;
%                     if ~isempty(motionDirectionsPerRun(currentRun)) % Checks if the cell corresponding to the currentRun in the motionDirectionsPerRun cell array is not empty
%                         motionDirection = motionDirectionsPerRun(currentRun); % If the cell is not empty, assigns the content of that cell to the variable motionDirection. This content is expected to be a shuffled list of motion directions associated with the current run
%                     end                  

                    WaitSecs(0.01);

                otherwise
                    error('You selected an undefined scenario!');
            end


% Counterbalancing and randomizing different cues based on the conditions.








%% CREATION OF STIMULI AND CLOSING SCREENS
% Creation of experimental stimuli with different features (textures, colors…)

        % Select image buffer for true color image:
        Screen('SelectStereoDrawBuffer', ptb.window, 0);
        Screen('DrawTexture', ptb.window, backGroundTexture);

        tex1 = Screen('MakeTexture', ptb.window, scaledOrientationGrating);     % create texture for stimulus
        Screen('DrawTexture', ptb.window, tex1, [], design.destinationRect);

        tex2 = Screen('MakeTexture', ptb.window, rightgratingfreq2);     % create texture for stimulus
        Screen('DrawTexture', ptb.window, tex2, [], design.destinationRect);

        Screen('DrawLines', ptb.window, design.fixCrossCoords, ...
        ptb.lineWidthInPix, ptb.white, [ptb.xCenter ptb.yCenter]);

        % Select image buffer for true color image:
        Screen('SelectStereoDrawBuffer', ptb.window, 1);
        Screen('DrawTexture', ptb.window, backGroundTexture);

        tex1Other = Screen('MakeTexture', ptb.window, leftgratingfreq1);     % create texture for stimulus
        Screen('DrawTexture', ptb.window, tex1Other, [], design.destinationRect);

        tex2Other = Screen('MakeTexture', ptb.window, leftgratingfreq2);     % create texture for stimulus
        Screen('DrawTexture', ptb.window, tex2Other, [], design.destinationRect);

        Screen('DrawLines', ptb.window, design.fixCrossCoords, ptb.lineWidthInPix, ptb.white, [ptb.xCenter ptb.yCenter]);

        Screen('DrawingFinished', ptb.window);
        Screen('Flip', ptb.window);

        Screen('Close', tex1);
        Screen('Close', tex2);
        Screen('Close', tex1Other);
        Screen('Close', tex2Other);



%% SAVING PARTICIPANT FILES ACCORDING TO THE RUN NUMBER:

% Saving participant’s mat files along with information about the randomization of the conditions…
   
 save('participant_' + filename);
