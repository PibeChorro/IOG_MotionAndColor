function Experiment_Instructions(ptb,get,design,participantInfo)
if mod(get.subjectNumber,2) == 0
    monocular = 'left';
    interocular = 'right';
else
    monocular = 'right';
    interocular = 'left';
end

instructionsArray_1 = {
    ['To make sure color luminance is equal throughout\n ' ...
    'the experiment, you will now conduct a Flicker Test.\n ' ...
    'You will see one rectangle, and what you need to do is\n' ...
    'press the right or left key consistently\n' ...
    ' until the square does not flicker anymore\n' ...
    'Press the middle key when you are done.'];

    ['Thank you for choosing to participate in this study\n '...
    'involving interocular grouping.\n' ...
    'By pressing any key button, you will be \n '...
    're-directed to a series of instructions \n' ...
    'informing you about what you are required \n '...
    'to do in this experiment'];

    ['This experiment will consist of eight \n '...
    'runs with four trials each\n' ...
    'You may take a short break in \n '...
    'between the different runs\n' ...
    'Please remember NOT to move your \n '...
    'head during the experiment\n' ...
    'and keep your eyes fixated on \n '...
    'the cross in the middle of the stimulus.\n' ...
    'Press any key to continue...'];

    ['In the following instructions, \n '...
    'you will see all the possible\n' ...
    ' percepts you may encounter in the experiment.\n' ...
    ' Press any key to continue']
    };

 if get.runNumber == 1
    TextDisplay = instructionsArray_1{1};
    Screen('SelectStereoDrawBuffer', ptb.window, 0);
    DrawFormattedText(ptb.window, TextDisplay, 'center', 'center');
    Screen('SelectStereoDrawBuffer', ptb.window, 1);
    DrawFormattedText(ptb.window, TextDisplay, 'center', 'center');
    Screen('DrawingFinished', ptb.window);
    Screen('Flip', ptb.window);
    KbWait();
    WaitSecs(0.5);

    % FLICKER TEST:
    % Flicker test to make sure luminance for red and green are equal during
    % the experiment
    
    try
        participantInfo = Flicker_Test_IOG(ptb,design,participantInfo);
    catch flickerTestError
        sca;
        close all;
        rethrow(flickerTestError);
    end
    
    WaitSecs(0.5);
    % save participants info
    save(fullfile(get.folderName, 'participantInfo.mat'),'participantInfo');
 end

for inst1 = 2:length(instructionsArray_1)
    if get.runNumber == 1
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
end

if get.runNumber == 1
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

    textIOG = [
        '1. Only one grating with either \n' ...
        'horizontal or vertical\n' ...
        'orientation. If you perceive the above stimuli,\n' ...
        'Keep on pressing the ' interocular ' key'];

    textColor = [0 0 0];

    textYIOG = destinationRectHorizontal(4) + fullScreenX/20; % Adjust the offset as needed

    % Draw the text
    DrawFormattedText(ptb.window, textIOG, 'center', textYIOG, textColor);

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

    textMonocular = ['2. Two gratings with horizontal\n' ...
        ' and vertical orientations\n' ...
        ' next to each other. \n' ...
        'If you perceive any of the above\n' ...
        ' stimuli, keep on pressing the\n' ...
        ' ' monocular ' key'];

    % Calculate position for left eye text
    textYMonocular = destinationRectLeftEye(4) + fullScreenY/16;

    DrawFormattedText(ptb.window,textMonocular, 'center', textYMonocular, textColor);

    horizontalGrating = sin(xHorizontal*design.scalingFactor);
    ScaledHorizontalGrating = ((horizontalGrating+1)/2) * design.contrast;

    verticalGrating1 = sin(xVertical*design.scalingFactor);
    ScaledVerticalGrating = ((verticalGrating1+1)/2) * design.contrast;

    % Select left image buffer for true color image:
    Screen('SelectStereoDrawBuffer', ptb.window, 1);

    tex1 = Screen('MakeTexture', ptb.window, ScaledHorizontalGrating);  % create texture for stimulus
    Screen('DrawTexture', ptb.window, tex1, [], destinationRectHorizontal);

    DrawFormattedText(ptb.window, textMonocular, 'center', textYMonocular, textColor);

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

    DrawFormattedText(ptb.window, textIOG, 'center', textYIOG, textColor);

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

    textPieceMeal = [
        'If you perceive a stimulus that is mixed \n' ...
        '(take the stimulus above as\n' ...
        ' a possible example),\n' ...
        'do not press anything.\n' ...
        'Press any key to continue...'];

    % Calculate position for left eye text
    textYPieceMeal = destinationRectPieceMeal(4) + 50;

    DrawFormattedText(ptb.window,textPieceMeal, 'center', textYPieceMeal, textColor);

    % Select left image buffer for true color image:
    Screen('SelectStereoDrawBuffer', ptb.window, 0);

    % swap alpha masks
    ScaledHorizontalGrating(:,:,4)  = alphaMaskPieceMeal1;
    ScaledVerticalGrating(:,:,4)    = alphaMaskPieceMeal2;

    tex11Other = Screen('MakeTexture', ptb.window, ScaledHorizontalGrating);
    Screen('DrawTexture', ptb.window, tex11Other, [], destinationRectPieceMeal);

    tex22Other = Screen('MakeTexture', ptb.window, ScaledVerticalGrating);
    Screen('DrawTexture', ptb.window, tex22Other, [], destinationRectPieceMeal);

    DrawFormattedText(ptb.window,textPieceMeal, 'center', textYPieceMeal, textColor);

    Screen('DrawingFinished', ptb.window);
    Screen('Flip', ptb.window);
    WaitSecs(0.5);
    KbWait();

end

instructionsArray_2 = {
    ['In the experiment the stimuli can also be colored\n' ...
    'In red and green, and the gratings may also be moving.'];

    ['Now you will conduct a small training session\n' ...
    'so that you become familiar with the task.'];

    ['REMINDER: Keep pressing ' upper(monocular) '\n' ...
    ' if you see two different\n' ...
    'gratings, and ' upper(interocular) ' if you\n' ...
    ' see one, and nothing if you see\n' ...
    ' any mixed patterns\n' ...
    ' as shown before. Also, please keep your eyes\n' ...
    ' fixated on the cross in the middle\n' ...
    ' of the stimulus. Press any key to continue...'];
    ['Get ready...'];
    
    ['Now you will be re-directed to the actual experiment.\n' ...
    'Get ready...' ...
    ' Press any key to continue'];
    };

if get.runNumber > 1
    TextDisplay = instructionsArray_2{3:4};
    Screen('SelectStereoDrawBuffer', ptb.window, 0);

    DrawFormattedText(ptb.window, TextDisplay,'center', 'center');

    Screen('SelectStereoDrawBuffer', ptb.window, 1);

    DrawFormattedText(ptb.window, TextDisplay,'center', 'center');

    % Tell PTB drawing is finished for this frame:
    Screen('DrawingFinished', ptb.window);

    Screen('Flip', ptb.window);

    % Wait for any key press
    WaitSecs(0.5);
    KbWait();
elseif get.runNumber == 1
    for i = 1:3
        TextDisplay = instructionsArray_2{i};

        Screen('SelectStereoDrawBuffer', ptb.window, 0);

        DrawFormattedText(ptb.window, TextDisplay,'center', 'center');

        Screen('SelectStereoDrawBuffer', ptb.window, 1);

        DrawFormattedText(ptb.window, TextDisplay,'center', 'center');

        % Tell PTB drawing is finished for this frame:
        Screen('DrawingFinished', ptb.window);

        Screen('Flip', ptb.window);

        % Wait for any key press
        WaitSecs(0.5);
        KbWait();
    end

    try
        training_session_IOG(ptb,get,design)
    catch trainingERROR
        sca;
        close all;
        rethrow(trainingERROR);
    end
    WaitSecs(0.5);

    TextDisplay = instructionsArray_2{5};
    Screen('SelectStereoDrawBuffer', ptb.window, 0);

    DrawFormattedText(ptb.window, TextDisplay,'center', 'center');

    Screen('SelectStereoDrawBuffer', ptb.window, 1);

    DrawFormattedText(ptb.window, TextDisplay,'center', 'center');

    % Tell PTB drawing is finished for this frame:
    Screen('DrawingFinished', ptb.window);

    Screen('Flip', ptb.window);

    % Wait for any key press
    WaitSecs(0.5);
    KbWait();
end
end