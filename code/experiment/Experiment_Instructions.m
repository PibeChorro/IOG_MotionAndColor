function Experiment_Instructions(ptb,get,design)

orientation1 = design.xHorizontal;
orientation2 = design.xVertical;

motion1 = 1;
motion2 = -1;
noMotion = 0;

design.scalingFactor = 0.1;
design.contrast = 0.33;
design.stimSizeInDegrees = 1.7;
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

horizontalGrating = sin(xHorizontal*design.scalingFactor);
leftScaledHorizontalGrating = ((horizontalGrating+1)/2) * design.contrast;
verticalGrating = sin(xVertical*design.scalingFactor);
leftScaledVerticalGrating = ((verticalGrating+1)/2) * design.contrast;

leftScaledHorizontalGrating(:,:,turnoffIndicesHorizontal) = 0;
leftScaledVerticalGrating(:,:,turnoffIndicesVertical) = 0;


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
    WaitSecs(0.5);
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
WaitSecs(0.5);

end