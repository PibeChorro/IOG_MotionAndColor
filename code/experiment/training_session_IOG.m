function training_session_IOG(ptb, get, design)

get.trainingData = false;

design.stimulusPresentationTime = 30 - ptb.ifi/2;
design.contrast                 = 0.33;                                % decreasing the contrast between rivaling stimuli prolonges the dominance time
design.stepSize                 = 0.875;                               % Original: 0.25, but to make in visual degrees we go up to 0.875. Step size for motion trials to reduce/increase velocity. (PixPerDeg/FramesPerSecond)*PixPerFrame
design.scalingFactor            = 0.1;
design.stimSizeInDegrees        = 1.7;
design.fixCrossInDegrees        = 0.25;
design.useET = false;

design.stimSizeInPixelsX        = round(ptb.PixPerDegWidth*design.stimSizeInDegrees);
design.stimSizeInPixelsY        = round(ptb.PixPerDegHeight*design.stimSizeInDegrees);

design.fixCrossInPixelsX        = round(ptb.PixPerDegWidth*design.fixCrossInDegrees);
design.fixCrossInPixelsY        = round(ptb.PixPerDegHeight*design.fixCrossInDegrees);

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


        Motion1 = 1;
        Motion2 = -1;
    
        % get color indices for gratings

        turnoffIndicesVertical = 2:4;
        turnoffIndicesHorizontal = [1 3 4];

        vbl = Screen('Flip', ptb.window);
    
        % fixation cross drawing
        Screen('SelectStereoDrawBuffer', ptb.window, 0);
        Screen('DrawLines', ptb.window,design.fixCrossCoords, ...
            ptb.lineWidthInPix, ptb.white, [ptb.xCenter ptb.yCenter]);
    
        Screen('SelectStereoDrawBuffer', ptb.window, 1);
        Screen('DrawLines', ptb.window, design.fixCrossCoords, ...
            ptb.lineWidthInPix, ptb.white, [ptb.xCenter ptb.yCenter]);
        Screen('DrawingFinished', ptb.window);
        Screen('Flip', ptb.window);

        WaitSecs(design.ITI);

        % get timing of trial onset
        get.data.trialOnset = GetSecs;
        % updating the x arrays 
        while vbl - get.data.trialOnset < design.stimulusPresentationTime
            
            design.xHorizontal = design.xHorizontal + Motion1 * design.stepSize;
            design.xVertical = design.xVertical + Motion2 * design.stepSize;
        
            % TODO (VP): set factor for sinus wave as a variable 
            horizontalGrating = sin(design.xHorizontal*design.scalingFactor); % creates a sine-wave grating of spatial frequency 0.1
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
        
            tex1 = Screen('MakeTexture', ptb.window, leftScaledHorizontalGrating);  % create texture for stimulus
            Screen('DrawTexture', ptb.window, tex1, [], design.destinationRect);
        
            tex2 = Screen('MakeTexture', ptb.window, leftScaledVerticalGrating);    % create texture for stimulus
            Screen('DrawTexture', ptb.window, tex2, [], design.destinationRect);
            Screen('DrawLines', ptb.window, design.fixCrossCoords, ...
                ptb.lineWidthInPix, ptb.white, [ptb.xCenter ptb.yCenter]);
        
            % Select right image buffer for true color image:
            Screen('SelectStereoDrawBuffer', ptb.window, 1);
        
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

    %% Saving Data
    get.end = 'Success';
    get.trainingData = true;
    savedata(get,ptb,design)
    Screen('CloseAll');

end