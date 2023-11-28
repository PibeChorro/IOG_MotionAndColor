function openExperimentWindow(ptb, ~)

    % Clear the screen
    Screen('FillRect', ptb.window, [], []);
  
    Screen('FrameRect', ptb.window, [0 0 0]);

    DrawFormattedText(ptb.window, 'Hello everyone','center', 'center', 0, 20);

     % Tell PTB drawing is finished for this frame:
     Screen('DrawingFinished', ptb.window);
        
     Screen('Flip', ptb.window);

end