function Flicker_Test_IOG(ptb, design)
%isolumSingleColorFlickerMethod: this function creates a table with
%subjectively equiluminant RGB-values
%   input:
%       log - struct containing information about the subject and subject
%       directory
%       ptb - struct containing information about PsychToolBox3 window and
%       button IDs
%   The function reads in a table of RGB-values extracted from the stimuli
%   used in this experiment. The RGB-values are used in the flicker task to
%   get subjectively equiluminant colors

%% design related stuff
% the color pairs that need to be made equiluminant

design.grayBackgroundInDegrees  = 3;
design.grayBackgroundInPixelsX  = round(ptb.PixPerDegWidth* 2 *design.grayBackgroundInDegrees); 
design.grayBackgroundInPixelsY  = round(ptb.PixPerDegHeight*design.grayBackgroundInDegrees);

ptb.colorRect = [...
    ptb.screenXpixels/2-design.grayBackgroundInPixelsX/2 ... 
    ptb.screenYpixels/2-design.grayBackgroundInPixelsY/2 ...
    ptb.screenXpixels/2+design.grayBackgroundInPixelsX/2 ...
    ptb.screenYpixels/2+design.grayBackgroundInPixelsY/2];

% Define response buttons
terminateButton     = ptb.Keys.escape;
lumIncreaseButton   = ptb.Keys.left;
lumDecreaseButton   = ptb.Keys.right; 
confirmButton       = ptb.Keys.accept; % Space

% stepsize with which the luminance should be increased/decreased
stepSize = 5/255;

%% gamma correction
% read in setup specific gamma correction table
switch ptb.SetUp
    case 'CIN-personal'
        LUT = repmat(0:255,3,1)';
        invLUT = repmat(0:255,3,1)';
    case 'CIN-experimentroom'
        monCalDir = fullfile('..', 'monitor_calibration', ...
            'EIZO_CIN5th_Brightness50_SpectraScan670_derived.mat');
        load(monCalDir); %#ok<LOAD> 
        % The look-up table (LUT) is the *inverted* gamma function measured
        % from the monitor in order to linearize the luminance steps
        % The *inverted* LUT (invLUT) is the *actual* gamma function we use
        % *once* to gammafy the colors, so that linearization in the first
        % step keeps the original color
        LUT = round(cal.iGammaTable*255); 
        invLUT = round(cal.gammaTable*255);
    otherwise
        disp('WARNING!!! Set up is not monitor-specific');
        LUT = repmat(0:255,3,1)';
        invLUT = repmat(0:255,3,1)';
end

% Disable keyboard output to Matlab
ListenChar(2)

%% get equiluminant colors 
% create copy of color table to fill up with equiluminant values
% iterate over the two colors

    % before we start we gammaficate the colors so that when we linearize
    % the color, we still start at the same color
    design.redColor = img_gammaConvert(invLUT,design.redColor);
    design.greenColor = img_gammaConvert(invLUT,design.greenColor);
    % luminance factors
    curOneLumFactor     = [1 1 1]; 
    curOtherLumFactor   = [1 1 1];

    % maximum factor to avoid exceeding boundaries
    maxCurOneLumFactor = 1./max(design.redColor);
    maxCurOtherLumFactor = 1./max(design.greenColor);

    curFrame = 1;
    spaceDown = 0;  % Has P pressed the space bar?
    responseKeyReleased = 1;    % Has P released response key?
    tic
    while ~spaceDown
        % gamma correction
        correctedOneColor  = img_gammaConvert(LUT,design.redColor.*curOneLumFactor);
        correctedOtherColor = img_gammaConvert(LUT,design.greenColor.*curOtherLumFactor);
    
        % Select   left-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer', ptb.window, 0);
        if mod(curFrame,2) == 1 % Inversed color
            Screen('FillRect', ptb.window, correctedOtherColor,ptb.colorRect)
        elseif mod(curFrame,2) == 0 % True color
            Screen('FillRect', ptb.window, correctedOneColor,ptb.colorRect)
        end
    
        % Select   right-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer', ptb.window, 1);
        if mod(curFrame,2) == 1 % Inversed color
            Screen('FillRect', ptb.window, correctedOtherColor,ptb.colorRect)
        elseif mod(curFrame,2) == 0 % True color
            Screen('FillRect', ptb.window, correctedOneColor,ptb.colorRect)
        end
    
        Screen('DrawingFinished', ptb.window); % Tell PTB that no further drawing commands will follow before Screen('Flip')
        
        % Record and process responses
        [ keyIsDown, ~, keyCode ] = KbCheck;
        if responseKeyReleased == 1 && keyIsDown == 1
            responseKeyReleased = 0;
            keyId = find(keyCode);
            switch keyId(1) % If, accidentally, multiple keys were pressed, choose the one with the lower ID
                   
                case terminateButton
                    break   % User terminated execution by pressing ESC               

                case lumIncreaseButton
                    curOneLumFactor = curOneLumFactor+stepSize;
                    curOtherLumFactor = curOtherLumFactor-stepSize;

                case lumDecreaseButton
                    curOneLumFactor = curOneLumFactor-stepSize;
                    curOtherLumFactor = curOtherLumFactor+stepSize;

                case confirmButton
                    fprintf('Accepted\n')
                    design.redColor(1) = correctedOneColor(1);
                    design.redColor(2) = correctedOneColor(2);
                    design.redColor(3) = correctedOneColor(3);

                    design.greenColor(1) = correctedOtherColor(1);
                    design.greenColor(2) = correctedOtherColor(2);
                    design.greenColor(3) = correctedOtherColor(3);

                    while KbCheck; end % Wait until all keys have been released
                    spaceDown = 1;    % P confirmed adjustment
            end % switch

            % Make sure the luminance factor does not exceed boundaries
            if any(curOneLumFactor > maxCurOneLumFactor)
                curOneLumFactor(curOneLumFactor > maxCurOneLumFactor) = maxCurOneLumFactor; 
            end
            if  any(curOtherLumFactor > maxCurOtherLumFactor) 
                curOtherLumFactor(curOtherLumFactor > maxCurOtherLumFactor) = maxCurOtherLumFactor; 
            end
            if any(curOneLumFactor <= 0)
                curOtherLumFactor(curOneLumFactor <= 0) = 0;
            end
            if any(curOtherLumFactor <= 0)
                curOtherLumFactor(curOtherLumFactor <= 0) = 0;
            end
        elseif keyIsDown == 0
            responseKeyReleased = 1;
        end % if keyIsDown
        curFrame = curFrame + 1;
        Screen('Flip',ptb.window);
        toc
    end
    ListenChar(0);                                                          % enable button input
% save the equiluminant colors
% saveDir = fullfile(log.subjectDirectory, 'stimuli', 'equilumColors.csv');
% writetable(equilumColorTable,saveDir);
end