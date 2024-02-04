function [horizontalOffset,verticalOffset] = alignFusion(ptb)
% alignFusion: Find the disparity that creates fusion in the subject
%   Draw a frame with text on both sides of the screen
%   The subject can move the frame in any direction until it is fused
%   returns: the offset in x and y 

FusionText   = ['Fusion test: use the left and right keys\n' ... 
    'to adjust and the middle key to continue'];
ListenChar(2);
    horizontalOffset = 0;
    verticalOffset = 0;
    change = 0.003;
    framesize = max([ptb.screenXpixels, ptb.screenYpixels])/3; 

    % varialbe that if true calls SetStereoSideBySideParameters
    updateStereo = false;
    while true
        if updateStereo
            SetStereoSideBySideParameters(ptb.window, [0+horizontalOffset, 0+verticalOffset], ...
                [1, 1], [1-horizontalOffset, 0-verticalOffset], [1, 1]);
                updateStereo = false;
        end

        % Select   left-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer', ptb.window, 0);
        Screen('FrameRect', ptb.window, 0, CenterRectOnPoint([0 0 framesize framesize], ptb.xCenter, ptb.yCenter), 10);

        DrawFormattedText(ptb.window, FusionText,'center', 'center', ...
            0, 20, [], [], [], [], CenterRectOnPoint([0 0 framesize framesize], ...
            ptb.xCenter, ptb.yCenter)); % is this needed?

        % Select right-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer', ptb.window, 1);
        Screen('FrameRect', ptb.window, 0,  CenterRectOnPoint([0 0 framesize framesize], ...
            ptb.xCenter, ptb.yCenter), 10);
    
        DrawFormattedText(ptb.window, FusionText,'center', 'center', ...
            0, 20, [], [], [], [], CenterRectOnPoint([0 0 framesize framesize], ...
            ptb.xCenter, ptb.yCenter)); % is this needed?

        % Tell PTB drawing is finished for this frame:
        Screen('DrawingFinished', ptb.window);
        
        Screen('Flip', ptb.window);

        [KeyIsDown, ~, keyCode, ~] = KbCheck;%(ptb.Keyboard2);

        if KeyIsDown
            if find(keyCode)==ptb.Keys.left
                horizontalOffset = horizontalOffset-change;
                disp('=>pressed LEFT')
                updateStereo = true;
            elseif find(keyCode)==ptb.Keys.right
                horizontalOffset = horizontalOffset+change;
                disp('=>pressed RIGHT')
                updateStereo = true;
            elseif find(keyCode)==ptb.Keys.up
                verticalOffset = verticalOffset+change;
                disp('=>pressed UP')
                updateStereo = true;
            elseif find(keyCode)==ptb.Keys.down
                verticalOffset = verticalOffset-change;
                disp('=>pressed DOWN')
                updateStereo = true;
            elseif find(keyCode)==ptb.Keys.accept
                disp('=>pressed SPACE')
                break
            else
                disp(['Pressed' num2str(KbName(find(keyCode)))])
            end
                fprintf('x-offset: %100.2f, y-offset:%100.2f \n', horizontalOffset, verticalOffset);
        end
    end
ListenChar(0);
end