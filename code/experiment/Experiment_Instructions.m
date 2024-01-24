function Experiment_Instructions(ptb,get,design)
[xVertical, xHorizontal] = meshgrid(1:314);

alphaMaskPieceMeal1 = zeros(size(xHorizontal));
halfColumns = round(size(alphaMaskPieceMeal1, 2) / 2);

% Right half: horizontal in the upper part, vertical in the lower part
alphaMaskPieceMeal1(1:round(size(alphaMaskPieceMeal1, 1)/2), 1:halfColumns) = 1; 
alphaMaskPieceMeal1(round(size(alphaMaskPieceMeal1, 1)/2)+1:end, halfColumns+1:end) = 1;

alphaMaskPieceMeal2 = ~alphaMaskPieceMeal1;

xHorizontal(:,:,2) = xHorizontal(:,:,1);
xHorizontal(:,:,3) = xHorizontal(:,:,1);
xHorizontal(:,:,4) = xHorizontal(:,:,1);

xVertical(:,:,2) = xVertical(:,:,1);
xVertical(:,:,3) = xVertical(:,:,1);
xVertical(:,:,4) = xVertical(:,:,1);

horizontalGrating = sin(xHorizontal*design.scalingFactor); 
ScaledHorizontalGrating = ((horizontalGrating+1)/2) * design.contrast;

verticalGrating1 = sin(xVertical*design.scalingFactor);
ScaledVerticalGrating = ((verticalGrating1+1)/2) * design.contrast;

turnoffIndicesVertical = 4;
turnoffIndicesHorizontal = 4;

ScaledHorizontalGrating(:,:,turnoffIndicesHorizontal) = 0;
ScaledVerticalGrating(:,:,turnoffIndicesVertical) = 0;


%% CREATION OF STIMULI AND CLOSING SCREENS
% Creation of experimental stimuli with different features (textures, colors…)

% Select left image buffer for true color image:
Screen('SelectStereoDrawBuffer', ptb.window, 0);

tex1 = Screen('MakeTexture', ptb.window, ScaledHorizontalGrating);  % create texture for stimulus
Screen('DrawTexture', ptb.window, tex1, [], [10 10 40 40]);

tex2 = Screen('MakeTexture', ptb.window, ScaledVerticalGrating);    % create texture for stimulus
Screen('DrawTexture', ptb.window, tex2, [], [50 10 50 40]);

ScaledHorizontalGrating(:,:,4)  = design.alphaMask1;
ScaledVerticalGrating(:,:,4)    = design.alphaMask2;

tex1 = Screen('MakeTexture', ptb.window, ScaledHorizontalGrating);  % create texture for stimulus
Screen('DrawTexture', ptb.window, tex1, [], [10 50 40 90]);

tex2 = Screen('MakeTexture', ptb.window, ScaledVerticalGrating);    % create texture for stimulus
Screen('DrawTexture', ptb.window, tex2, [], [50 50 50 90]);

ScaledHorizontalGrating(:,:,4)  = alphaMaskPieceMeal1;
ScaledVerticalGrating(:,:,4)    = alphaMaskPieceMeal2;

tex1 = Screen('MakeTexture', ptb.window, ScaledHorizontalGrating);  % create texture for stimulus
Screen('DrawTexture', ptb.window, tex1, [], [100 60 140 100]);

tex2 = Screen('MakeTexture', ptb.window, ScaledVerticalGrating);    % create texture for stimulus
Screen('DrawTexture', ptb.window, tex2, [], [100 60 140 100]);

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