function Experiment_Instructions(ptb,get,design)

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

[xVertical, xHorizontal] = meshgrid(1:314);

%% ALPHA MASKS -- MONDREAN MASKS

alphaMask1 = zeros(size(xHorizontal));
alphaMask2 = alphaMask1;

% TODO (VP): make alpha mask values dynamic
halfColumns = round(size(alphaMask1, 2) / 2);

% Left half: vertical in the upper part, horizontal in the lower part
alphaMask1(:, 1:halfColumns) = 0;  % Entire left half
alphaMask1(1:round(size(alphaMask1, 1)/2), halfColumns+1:end) = 1;
alphaMask1(1:round(size(alphaMask1, 1)/2), 1:halfColumns) = 1;

% Right half: horizontal in the upper part, vertical in the lower part
alphaMask2(:, halfColumns+1:end) = 0;
alphaMask2(1:round(size(alphaMask2, 1)/2), 1:halfColumns) = 1; 
alphaMask2(round(size(alphaMask2, 1)/2)+1:end, halfColumns+1:end) = 1;

figure;

subplot(1, 2, 1);
imshow(alphaMask1);
title('Alpha Mask 1');

subplot(1, 2, 2);
imshow(alphaMask2);
title('Alpha Mask 2');

xHorizontal(:,:,2) = xHorizontal(:,:,1);
xHorizontal(:,:,3) = xHorizontal(:,:,1);
xHorizontal(:,:,4) = xHorizontal(:,:,1);

xVertical(:,:,2) = xVertical(:,:,1);
xVertical(:,:,3) = xVertical(:,:,1);
xVertical(:,:,4) = xVertical(:,:,1);

Screen('SelectStereoDrawBuffer', ptb.window, 0);
Screen('DrawLines', ptb.window, design.fixCrossCoords, ...
        ptb.lineWidthInPix, ptb.white, [ptb.xCenter ptb.yCenter]);

Screen('SelectStereoDrawBuffer', ptb.window, 1);
Screen('DrawLines', ptb.window, design.fixCrossCoords, ...
        ptb.lineWidthInPix, ptb.white, [ptb.xCenter ptb.yCenter]);
Screen('DrawingFinished', ptb.window);
Screen('Flip', ptb.window);

xHorizontal = xHorizontal + 1 * design.stepSize;
xVertical = xVertical - 1 * design.stepSize;

horizontalGrating = sin(xHorizontal*design.scalingFactor); 
ScaledHorizontalGrating = ((horizontalGrating+1)/2) * design.contrast;

verticalGrating1 = sin(xVertical*design.scalingFactor);
ScaledVerticalGrating = ((verticalGrating1+1)/2) * design.contrast;

turnoffIndicesVertical = 4;
turnoffIndicesHorizontal = 4;

ScaledHorizontalGrating(:,:,turnoffIndicesHorizontal) = 0;
ScaledVerticalGrating(:,:,turnoffIndicesVertical) = 0;

ScaledHorizontalGrating(:,:,4)  = alphaMask2;
ScaledVerticalGrating(:,:,4) = alphaMask1;


%% CREATION OF STIMULI AND CLOSING SCREENS
% Creation of experimental stimuli with different features (textures, colors…)

% Select left image buffer for true color image:
Screen('SelectStereoDrawBuffer', ptb.window, 0);
Screen('DrawTexture', ptb.window, backGroundTexture);

tex1 = Screen('MakeTexture', ptb.window, ScaledHorizontalGrating);  % create texture for stimulus
Screen('DrawTexture', ptb.window, tex1, [], design.destinationRect);

tex2 = Screen('MakeTexture', ptb.window, ScaledVerticalGrating);    % create texture for stimulus
Screen('DrawTexture', ptb.window, tex2, [], design.destinationRect);

Screen('DrawLines', ptb.window, design.fixCrossCoords, ...
    ptb.lineWidthInPix, ptb.white, [ptb.xCenter ptb.yCenter]);

Screen('DrawingFinished', ptb.window);
Screen('Flip', ptb.window);

screenshot = Screen('GetImage', ptb.window);
imwrite(screenshot, 'screenshot.png');
WaitSecs(5);

if mod(get.subjectNumber,2) == 0
    monocular = 'left';
    binocular = 'right';
else
    monocular = 'right';
    binocular = 'left';
end

instructionsArray_1 = {
    ['Thank you for choosing to participate in this study involving interocular grouping\n' ...
    'By pressing any key button, you will be re-directed to a series of instructions \n' ...
    'informing you about what you are required to do in this experiment'];
    
    ['You will first have a fusion test, in which you will be presented with \n' ...
    'two rectangular frames which you should\n' ...
    'fuse together using the left or right' ...
    'arrows. Once this is done, click space to continue'];
    
    ['Here are the possible perceptions:\n'];

    ['1. Only one grating with either horizontal or vertical orientation\n'];

    ['2. Two gratings with horizontal and vertical orientations next to each other:\n'];
    
    ['3. Mixed percept: Both gratings in a patchwork-like pattern\n'];
    
    ['Remember to keep on pressing monocular if you perceive monocular\n' ...
    'percepts, and binocular if you perceive interocular grouping\n' ...
    'And do not press anything in case you perceive a mixture\n'...
    'Press any key to continue']
};

instructionsArray_2 = [
    'Now you will be redirected to the actual experiment. \n' ...
    'If the images presented to both eyes merge together\n' ...
    'to form a coherent pattern,\n'...
    'press the ' binocular ' key. If the images remain monocularly perceived,\n' ...
    'press the ' monocular ' key.\n'
];

for inst1 = 1:length(instructionsArray_1)
    TextDisplay = instructionsArray_1{inst1};
    
    Screen('SelectStereoDrawBuffer', ptb.window, 0);
    
    DrawFormattedText(ptb.window, TextDisplay,'center', 'center');
    
    Screen('SelectStereoDrawBuffer', ptb.window, 1);
    
    DrawFormattedText(ptb.window, TextDisplay,'center', 'center');
    
    % Tell PTB drawing is finished for this frame:
    Screen('DrawingFinished', ptb.window);
    
    Screen('Flip', ptb.window);
    
    % Wait for any key press
    KbWait();
    WaitSecs();
end

TextDisplay = instructionsArray_2;

Screen('SelectStereoDrawBuffer', ptb.window, 0);

DrawFormattedText(ptb.window, TextDisplay,'center', 'center');

Screen('SelectStereoDrawBuffer', ptb.window, 1);

DrawFormattedText(ptb.window, TextDisplay,'center', 'center');

% Tell PTB drawing is finished for this frame:
Screen('DrawingFinished', ptb.window);

Screen('Flip', ptb.window);

% Wait for any key press
KbWait();
WaitSecs();

end