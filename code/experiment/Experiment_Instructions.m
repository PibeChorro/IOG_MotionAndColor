function Experiment_Instructions(ptb,get,design)

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

    ['This experiment will consist of eight runs with four trials each\n' ...
    'You may take a short break in between the different runs\n' ...
    'Please remember NOT to move your head during the experiment\n' ...
    'Press any key to continue...'];

    ['You will first have a fusion test, in which you will be presented with \n' ...
    'two rectangular frames which you should\n' ...
    'fuse together using the left or right' ...
    'arrows. Once this is done, click the middle key to continue\n' ...
    'Press any key to continue...'];

    % then here fusion test, then following instructions
    
    ['In the following instructions, you will see all the possible\n' ...
    ' percepts you may encounter in the experiment.\n' ...
    ' Press any key to continue'];

    % the window screen of IOG and monocular percepts shown with text
    % inclusive
    
    % Then, window screen of mixed piecemeal percepts with included texts

    ['REMINDER: KEEP PRESSING ' monocular ' IF YOU SEE TWO DIFFERENT\n' ...
    'GRATINGS, AND ' binocular ' IF YOU SEE ONE, AND NOTHING IF YOU\n' ...
    'SEE MIXED PATTERNS AS SHOWN BEFORE.\n' ...
    '' ...
    'Press any key to continue.'];
    };

for inst1 = 1:3
    TextDisplay = instructionsArray_1{inst1};
    
    Screen('SelectStereoDrawBuffer', ptb.window, 0);
    
    DrawFormattedText(ptb.window, TextDisplay,'center', 'center');
    
        Screen('SelectStereoDrawBuffer', ptb.window, 1);
    
    DrawFormattedText(ptb.window, TextDisplay,'center', 'center');
    
    % Tell PTB drawing is finished for this frame:
    Screen('DrawingFinished', ptb.window);
    
    Screen('Flip', ptb.window);
    
    KbWait();
    WaitSecs(0.5);
end

WaitSecs(1);
    
TextDisplay = instructionsArray_1{4};

Screen('SelectStereoDrawBuffer', ptb.window, 0);

DrawFormattedText(ptb.window, TextDisplay,'center', 'center');

Screen('SelectStereoDrawBuffer', ptb.window, 1);

DrawFormattedText(ptb.window, TextDisplay,'center', 'center');

% Tell PTB drawing is finished for this frame:
Screen('DrawingFinished', ptb.window);

Screen('Flip', ptb.window);

KbWait();
WaitSecs();

[xVertical, xHorizontal] = meshgrid(1:314);

alphaMaskPieceMeal1 = zeros(size(xHorizontal));
halfColumns = round(size(alphaMaskPieceMeal1, 2) / 2);

% Right half: horizontal in the upper part, vertical in the lower part
alphaMaskPieceMeal1(1:round(size(alphaMaskPieceMeal1, 1)/2), 1:halfColumns) = 1; 
alphaMaskPieceMeal1(round(size(alphaMaskPieceMeal1, 1)/2)+1:end, halfColumns+1:end) = 1;

fullScreenX = ptb.screenXpixels;
fullScreenY = ptb.screenYpixels;

destinationRectHorizontal   = [...
    fullScreenX*5/16 fullScreenY*3/16 ...
    fullScreenX*7/16 fullScreenY*5/16];
destinationRectVertical     = [...
    fullScreenX*9/16 fullScreenY*3/16 ...
    fullScreenX*11/16 fullScreenY*5/16];
destinationRectLeftEye      = [...
    fullScreenX*5/16 fullScreenY*7/16 ...
    fullScreenX*7/16 fullScreenY*9/16];
destinationRectRightEye     = [...
    fullScreenX*9/16 fullScreenY*7/16 ...
    fullScreenX*11/16 fullScreenY*9/16];
destinationRectPieceMeal = [...
    fullScreenX*7/16 fullScreenY*7/16 ...
    fullScreenX*9/16 fullScreenY*9/16];

alphaMaskPieceMeal2 = ~alphaMaskPieceMeal1;

xHorizontal(:,:,2) = xHorizontal(:,:,1);
xHorizontal(:,:,3) = xHorizontal(:,:,1);

xVertical(:,:,2) = xVertical(:,:,1);
xVertical(:,:,3) = xVertical(:,:,1);

horizontalGrating = sin(xHorizontal*design.scalingFactor); 
ScaledHorizontalGrating = ((horizontalGrating+1)/2) * design.contrast;

verticalGrating1 = sin(xVertical*design.scalingFactor);
ScaledVerticalGrating = ((verticalGrating1+1)/2) * design.contrast;

%% CREATION OF STIMULI AND CLOSING SCREENS
% Creation of experimental stimuli with different features (textures, colors…)

% Select left image buffer for true color image:
Screen('SelectStereoDrawBuffer', ptb.window, 0);

% whole horizontal grating
tex1 = Screen('MakeTexture', ptb.window, ScaledHorizontalGrating);  % create texture for stimulus
Screen('DrawTexture', ptb.window, tex1, [], destinationRectHorizontal);


textHorizontal = ['1. Only one grating with either horizontal or vertical\n' ...
    'orientation. If you perceive the above stimuli,\n' ...
    '   Keep on pressing the ' monocular ' key'];

textColor = [0 0 0];

textHX = (destinationRectHorizontal(1) + destinationRectHorizontal(3)) / 2 - 90; % Adjust the offset as needed
textHY = (destinationRectHorizontal(2) + destinationRectHorizontal(4)) / 2 + 110; % Adjust the offset as needed

% Draw the text
DrawFormattedText(ptb.window, textHorizontal, textHX, textHY, textColor);

% whole vertical grating
tex2 = Screen('MakeTexture', ptb.window, ScaledVerticalGrating);    % create texture for stimulus
Screen('DrawTexture', ptb.window, tex2, [], destinationRectVertical);

% set alpha masks for horizontal and vertical grating
ScaledHorizontalGrating(:,:,4)  = design.alphaMask1;
ScaledVerticalGrating(:,:,4)    = design.alphaMask2;

% gratings shown on left - horizontal
tex1Other = Screen('MakeTexture', ptb.window, ScaledHorizontalGrating);  % create texture for stimulus
Screen('DrawTexture', ptb.window, tex1Other, [], destinationRectLeftEye);

% graing shown on left - vertical
tex2Other = Screen('MakeTexture', ptb.window, ScaledVerticalGrating);    % create texture for stimulus
Screen('DrawTexture', ptb.window, tex2Other, [], destinationRectLeftEye);

% swap alpha masks
ScaledHorizontalGrating(:,:,4)  = design.alphaMask2;
ScaledVerticalGrating(:,:,4)    = design.alphaMask1;

% grating shown right - horizontal
tex1Other = Screen('MakeTexture', ptb.window, ScaledHorizontalGrating);  % create texture for stimulus
Screen('DrawTexture', ptb.window, tex1Other, [], destinationRectRightEye);

% grating shown right - vertical
tex2Other = Screen('MakeTexture', ptb.window, ScaledVerticalGrating);    % create texture for stimulus
Screen('DrawTexture', ptb.window, tex2Other, [], destinationRectRightEye);

textMonocular = ['2. Two gratings with horizontal and vertical orientations\n' ...
    ' next to each other. If you perceive any of the above stimuli,\n ' ...
    'Keep on pressing the ' binocular ' key'];

% Calculate position for left eye text
textXLeftEye = destinationRectLeftEye(1) + 50;  % Adjust the offset to the left
textYLeftEye = destinationRectLeftEye(4) + 30; 

DrawFormattedText(ptb.window,textMonocular, textXLeftEye, textYLeftEye, textColor);
 
horizontalGrating = sin(xHorizontal*design.scalingFactor); 
ScaledHorizontalGrating = ((horizontalGrating+1)/2) * design.contrast;

verticalGrating1 = sin(xVertical*design.scalingFactor);
ScaledVerticalGrating = ((verticalGrating1+1)/2) * design.contrast;

% Select left image buffer for true color image:
Screen('SelectStereoDrawBuffer', ptb.window, 1);

tex1 = Screen('MakeTexture', ptb.window, ScaledHorizontalGrating);  % create texture for stimulus
Screen('DrawTexture', ptb.window, tex1, [], destinationRectHorizontal);

textHorizontal = ['2. Two gratings with horizontal and vertical orientations\n' ...
    ' next to each other:\n' ...
    'If you perceive any of the above stimuli,\n ' ...
    '       Keep on pressing the ' binocular ' key'];

textColor = [0 0 0];

textHX = (destinationRectHorizontal(1) + destinationRectHorizontal(3)) / 2;
textHY = (destinationRectHorizontal(2) + destinationRectHorizontal(4)) / 2 + 110;

DrawFormattedText(ptb.window, textHorizontal, textHX, textHY, textColor);

tex2 = Screen('MakeTexture', ptb.window, ScaledVerticalGrating);    % create texture for stimulus
Screen('DrawTexture', ptb.window, tex2, [], destinationRectVertical);

ScaledHorizontalGrating(:,:,4)  = design.alphaMask1;
ScaledVerticalGrating(:,:,4)    = design.alphaMask2;

tex1Other = Screen('MakeTexture', ptb.window, ScaledHorizontalGrating);  % create texture for stimulus
Screen('DrawTexture', ptb.window, tex1Other, [], destinationRectLeftEye);

tex2Other = Screen('MakeTexture', ptb.window, ScaledVerticalGrating);    % create texture for stimulus
Screen('DrawTexture', ptb.window, tex2Other, [], destinationRectLeftEye);

ScaledHorizontalGrating(:,:,4)  = design.alphaMask2;
ScaledVerticalGrating(:,:,4)    = design.alphaMask1;

tex1Other = Screen('MakeTexture', ptb.window, ScaledHorizontalGrating);  % create texture for stimulus
Screen('DrawTexture', ptb.window, tex1Other, [], destinationRectRightEye);

tex2Other = Screen('MakeTexture', ptb.window, ScaledVerticalGrating);    % create texture for stimulus
Screen('DrawTexture', ptb.window, tex2Other, [], destinationRectRightEye);

textMonocular = ['1. Only one grating with either horizontal or vertical\n' ...
    'orientation. If you perceive the above stimuli,\n' ...
    '   Keep on pressing the ' monocular ' key'];

% Calculate position for left eye text
textXLeftEye = destinationRectLeftEye(1) + 50;
textYLeftEye = destinationRectLeftEye(4) + 30; 

DrawFormattedText(ptb.window,textMonocular, textXLeftEye, textYLeftEye, textColor);
 
Screen('DrawingFinished', ptb.window);
Screen('Flip', ptb.window);
WaitSecs(0.5);
KbWait();

% Select left image buffer for true color image:
Screen('SelectStereoDrawBuffer', ptb.window, 1);

ScaledHorizontalGrating(:,:,4)  = alphaMaskPieceMeal1;
ScaledVerticalGrating(:,:,4)    = alphaMaskPieceMeal2;

tex11Other = Screen('MakeTexture', ptb.window, ScaledHorizontalGrating);
Screen('DrawTexture', ptb.window, tex11Other, [], destinationRectPieceMeal);

tex22Other = Screen('MakeTexture', ptb.window, ScaledVerticalGrating);
Screen('DrawTexture', ptb.window, tex22Other, [], destinationRectPieceMeal);

textPieceMeal = ['If you perceive this mixed\n' ...
    'structure, do not press\n' ...
    '          anything.'];

centerXPieceMeal = (destinationRectPieceMeal(1) + destinationRectPieceMeal(3)) / 2;
halfCenterXPieceMeal = centerXPieceMeal/2;

% Calculate position for left eye text
textXPieceMeal = halfCenterXPieceMeal;  % Adjust the offset to the left
textYPieceMeal = destinationRectPieceMeal(4) + 50; 

DrawFormattedText(ptb.window,textPieceMeal, textXPieceMeal, textYPieceMeal, textColor);

% Select left image buffer for true color image:
Screen('SelectStereoDrawBuffer', ptb.window, 0);

% swap alpha masks
ScaledHorizontalGrating(:,:,4)  = alphaMaskPieceMeal1;
ScaledVerticalGrating(:,:,4)    = alphaMaskPieceMeal2;

tex11Other = Screen('MakeTexture', ptb.window, ScaledHorizontalGrating);
Screen('DrawTexture', ptb.window, tex11Other, [], destinationRectPieceMeal);

tex22Other = Screen('MakeTexture', ptb.window, ScaledVerticalGrating);
Screen('DrawTexture', ptb.window, tex22Other, [], destinationRectPieceMeal);

textPieceMeal = ['If you perceive this mixed\n' ...
    'structure, do not press\n' ...
    '          anything.'];

% Calculate position for left eye text
textXPieceMeal = halfCenterXPieceMeal;
textYPieceMeal = destinationRectPieceMeal(4) + 50; 

DrawFormattedText(ptb.window,textPieceMeal, textXPieceMeal, textYPieceMeal, textColor);

Screen('DrawingFinished', ptb.window);
Screen('Flip', ptb.window);
WaitSecs(0.5);
KbWait();

TextDisplay = instructionsArray_1{5};

Screen('SelectStereoDrawBuffer', ptb.window, 0);

DrawFormattedText(ptb.window, TextDisplay,'center', 'center');

Screen('SelectStereoDrawBuffer', ptb.window, 1);

DrawFormattedText(ptb.window, TextDisplay,'center', 'center');

% Tell PTB drawing is finished for this frame:
Screen('DrawingFinished', ptb.window);

Screen('Flip', ptb.window);

KbWait();
WaitSecs();


instructionsArray_2 = {
    ['Now you will be re-directed to the actual experiment.\n' ...
    ' Press any key to continue'];
    };

TextDisplay = instructionsArray_2{1};

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