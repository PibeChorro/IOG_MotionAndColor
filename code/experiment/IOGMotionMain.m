function IOGMotionMain(setUp)

if nargin < 1
    setUp = 'CIN-Mac-Setup' ;

end

try
    ptb = PTBSettingsIOGMotion(setUp);
catch PTBERROR
    sca;
     rethrow(PTBERROR);
end

%% design related
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

try
    openExperimentWindow(ptb);
catch OEWERROR
    sca;
    rethrow(OEWERROR);
end

try
    alignFusion(ptb, design);
catch alignERROR
    sca
    rethrow(alignERROR);
end

try
data = readtable('CounterBalancing_Motion.xlsx');
orientations = data(data.Orientation == "Horizontal" | data.Orientation == "Vertical", :);
uniqueRuns = unique(orientations.Run); % Extracts unique values from the Run column in table and stores them in the array uniqueRuns

% Initializes motionDirectionsPerRun as a cell array
motionDirectionsPerRun = cell(1, length(uniqueRuns)); % Creates a cell array named motionDirectionsPerRun with one row and a number of columns equal to the length of uniqueRuns

for runIdx = 1:length(uniqueRuns) % Starts a loop that iterates over the unique runs
    run = uniqueRuns(runIdx);

    if any(ismember(orientations.Run, run)) % Checks if any rows in the orientations table have the current run value
        motionDirections = orientations.MotionDirection(orientations.Run == run); % Extracts motion directions for the current run from the MotionDirection column in the orientations table
        motionDirectionsPerRun{runIdx} = motionDirections(randperm(length(motionDirections))); % Shuffles the extracted motion directions using randperm and assigns them to the corresponding cell in motionDirectionsPerRun
    else
        motionDirectionsPerRun{runIdx} = {};
    end
end
catch runError
    sca;
    rethrow(runError);
end

x = repmat(1:314, 314,1);

alphaMask1  = zeros(size(x));
alphaMask2 = alphaMask1;
alphaMask1(:,1:157) = 1;
alphaMask2(:,158:end) = 1;

scenarios = 1:4;
shuffledScenarios = scenarios(randperm(length(scenarios)));

group1Order = shuffledScenarios;
group2Order = fliplr(shuffledScenarios);

for i = 1:length(shuffledScenarios)
    currentScenario = shuffledScenarios(i);
    design.scenario = currentScenario;
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
                    rightGratingFreq1 = sin(x*0.3);
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

                    currentRun = 1;
                    if ~isempty(motionDirectionsPerRun(currentRun))
                       motionDirection = motionDirectionsPerRun(currentRun);
                    end

                case 4 % 4: orientation, color and motion
                    rightGratingFreq1 = sin(x*0.3);
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
                    currentRun = 1;
                    if ~isempty(motionDirectionsPerRun(currentRun)) % Checks if the cell corresponding to the currentRun in the motionDirectionsPerRun cell array is not empty
                        motionDirection = motionDirectionsPerRun(currentRun); % If the cell is not empty, assigns the content of that cell to the variable motionDirection. This content is expected to be a shuffled list of motion directions associated with the current run
                    end                  

                    WaitSecs(0.01);

                otherwise
                    error('You selected an undefined scenario!');
            end


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


        save('participant_scenario_order.mat', "shuffledScenarios");
        save('group1_participant_scenario_order.mat', 'group1Order');
        save('group2_participant_scenario_order.mat', 'group2Order');
        end
end
end