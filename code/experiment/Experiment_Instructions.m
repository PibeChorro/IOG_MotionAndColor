function Experiment_Instructions(ptb,get)

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
    ['You will now have a task with four different conditions: \n' ...
    'Condition 1: You will have two sine-wave gratings\n ' ...
    ' with different orientations\n (orthogonal to each other)' ...
    'Condition 2: You will have both orthogonal orientations\n' ...
    ' and different colors in each grating - green and red\n' ...
    'Condition 3: You will have orthogonal orientations of the gratings and motion\n' ...
    'Condition 4: You will have all three: Orientations, motion, and colors\n' ...
    'Press any key to continue to the Fusion test '];
};

instructionsArray_2 = [
    'Now you will be redirected to the actual experiment. \n' ...
    'If the images presented to both eyes merge together\n' ...
    ' to form a coherent pattern\n'...
    'press the ' binocular [' key. If the images remain monocularly perceived,\n' ...
    ' press the '] monocular ' key.'
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