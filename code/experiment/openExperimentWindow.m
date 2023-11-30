function openExperimentWindow(ptb)
    try
<<<<<<< HEAD
=======
        
>>>>>>> 4ece66935a3c404e16dbc39fdba5faf4f9f4c306
        getScreens = Screen('Screens');
        chosenScreen = max(getScreens);

        white = WhiteIndex(chosenScreen);
        grey = white / 2;
<<<<<<< HEAD
        Screen('Preference', 'SkipSyncTests', 1); % Skip synchronization tests if needed

        % Open Window
       [ptb.window,rect] = Screen('OpenWindow', chosenScreen, grey, []);

       centerX = (rect(3)-rect(1))/2;
       centerY = (rect(4)-rect(2))/2;
=======
        rect = [0 0 1920 1200];

        % Open Window
        [ptb.window, scr_rect] = PsychImaging('OpenWindow', chosenScreen, grey, []);

        [centerX, centerY] = RectCenter(scr_rect);
>>>>>>> 4ece66935a3c404e16dbc39fdba5faf4f9f4c306

        Screen('FillRect', ptb.window, [0.5 0.5 0.5], rect);
        Screen('TextSize', ptb.window, 40);
        Screen('TextFont', ptb.window, 'Times');
        Screen('TextStyle', ptb.window, 0);
        TextDisplay = 'Hello, Press space to continue to the Fusion test \n task before the actual experiment \n (this is not the actual text, just a trial)';

        % Text color
        Textcolor = [0 0 0];

        % Display text at the center of the screen
<<<<<<< HEAD
        DrawFormattedText(ptb.window, TextDisplay, centerX - 70, centerY, Textcolor);
=======
        DrawFormattedText(ptb.window, TextDisplay, centerX, centerY, Textcolor);
>>>>>>> 4ece66935a3c404e16dbc39fdba5faf4f9f4c306

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