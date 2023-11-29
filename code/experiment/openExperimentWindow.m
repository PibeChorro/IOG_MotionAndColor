function openExperimentWindow(ptb)
    try
        
        getScreens = Screen('Screens');
        chosenScreen = max(getScreens);

        white = WhiteIndex(chosenScreen);
        grey = white / 2;
        rect = [0 0 1920 1200];

        % Open Window
        [ptb.window, scr_rect] = PsychImaging('OpenWindow', chosenScreen, grey, []);

        [centerX, centerY] = RectCenter(scr_rect);

        Screen('FillRect', ptb.window, [0.5 0.5 0.5], rect);
        Screen('TextSize', ptb.window, 40);
        Screen('TextFont', ptb.window, 'Times');
        Screen('TextStyle', ptb.window, 0);
        TextDisplay = 'Hello, Press space to continue to the Fusion test \n task before the actual experiment \n (this is not the actual text, just a trial)';

        % Text color
        Textcolor = [0 0 0];

        % Display text at the center of the screen
        DrawFormattedText(ptb.window, TextDisplay, centerX, centerY, Textcolor);

        % Tell PTB drawing is finished for this frame:
        Screen('DrawingFinished', ptb.window);

        % Flip the screen
        Screen('Flip', ptb.window);
    
        % Wait for the spacebar press
        [KeyIsDown, ~, keyCode, ~] = KbCheck;

        if KeyIsDown
         
            if find(keyCode) == ptb.Keys.accept
            disp('Pressed space')
            else
            disp(['Pressed' num2str(KbName(find(keyCode)))])
            end
        end 

    catch PsychError
        disp('Error in Psychtoolbox:');
        disp(PsychError.message);
        sca; % Close the Psychtoolbox window if an error occurs
        rethrow(PsychError);
    end
end