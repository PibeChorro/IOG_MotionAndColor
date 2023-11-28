function openExperimentWindow(ptb, ~)

    % Clear the screen
    Screen('FillRect', ptb.window, ptb.backgroundColor);

    % Display text at the specified position (or center if not provided)
    DrawFormattedText(ptb.window,['Hello! You will now see instructions on the screen, and you should ' ...
        'press SPACE when ready'], 'center', 'center',0);

    % Flip the screen
    Screen('Flip', ptb.window);

    % Wait for the spacebar press
    KbWait([], ptb.Keys.accept);

    % Clear the screen again
    Screen('FillRect', ptb.window, ptb.backgroundColor);
    Screen('Flip', ptb.window);

end