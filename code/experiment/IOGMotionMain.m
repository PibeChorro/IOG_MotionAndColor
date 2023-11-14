function IOGMotionMain(setUp)

if nargin < 1
    setUp = 'CIN-experimentroom';
end

ptb = PTBSettingsIOGMotion(setUp);

%% design related
design = getInstructions();

design.stimulusPresentationTime = 90 - ptb.ifi/2;
design.ITI                      = 10 - ptb.ifi/2;
design.stimSizeInDegrees        = 1.7;
design.fixCrossInDegrees        = 0.25;
design.mondreanInDegrees        = 5;
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

% resize stimuli
% define a rectangle where the stimulus is drawn
design.destinationRect = [...
    ptb.screenXpixels/2-design.stimSizeInPixelsX/2 ... 
    ptb.screenYpixels/2-design.stimSizeInPixelsY/2 ...
    ptb.screenXpixels/2+design.stimSizeInPixelsX/2 ...
    ptb.screenYpixels/2+design.stimSizeInPixelsY/2];

% fixation cross
design.fixCrossCoords = [
    -design.fixCrossInPixelsX/2 design.fixCrossInPixelsX/2 0 0; ...
    0 0 -design.fixCrossInPixelsY/2 design.fixCrossInPixelsY/2
    ];

alignFusion(ptb, design);

x = repmat(1:314, 314,1);

alphaMask1  = zeros(size(x));
alphaMask2 = alphaMask1;
alphaMask1(:,1:157) = 1;
alphaMask2(:,157:end) = 1;

while true
    x = x+1;
    y = sin(x*0.1);
    y = ((y+1)/2);
    
    y(:,:,2) = zeros(size(x));
    y(:,:,3) = zeros(size(x));
    y2 = zeros(size(y));
    y2(:,:,2) = y(:,:,1)';

    yOther = y;
    y2Other = y2;
    y(:,:,4) = alphaMask1;
    y2(:,:,4) = alphaMask2;

    yOther(:,:,4) = alphaMask2;
    y2Other(:,:,4) = alphaMask1;
    
    
    design.whiteBackground = ones(size(x));
    whiteBackgroundTex = Screen('MakeTexture', ptb.window, design.whiteBackground);

    % Select image buffer for true color image:
    Screen('SelectStereoDrawBuffer', ptb.window, 0);
    Screen('DrawTexture', ptb.window, backGroundTexture);
%     Screen('DrawTexture', ptb.window, whiteBackgroundTex);
    
    tex1 = Screen('MakeTexture', ptb.window, y);     % create texture for stimulus
    Screen('DrawTexture', ptb.window, tex1, [], design.destinationRect);
    
    tex2 = Screen('MakeTexture', ptb.window, y2);     % create texture for stimulus
    Screen('DrawTexture', ptb.window, tex2, [], design.destinationRect);
    
    Screen('DrawLines', ptb.window, design.fixCrossCoords, ...
    ptb.lineWidthInPix, ptb.white, [ptb.xCenter ptb.yCenter]);
    
    % Select image buffer for true color image:
    Screen('SelectStereoDrawBuffer', ptb.window, 1);
    Screen('DrawTexture', ptb.window, backGroundTexture);
%     Screen('DrawTexture', ptb.window, whiteBackgroundTex);
    
    tex1Other = Screen('MakeTexture', ptb.window, yOther);     % create texture for stimulus
    Screen('DrawTexture', ptb.window, tex1Other, [], design.destinationRect);
    
    tex2Other = Screen('MakeTexture', ptb.window, y2Other);     % create texture for stimulus
    Screen('DrawTexture', ptb.window, tex2Other, [], design.destinationRect);
    
    Screen('DrawLines', ptb.window, design.fixCrossCoords, ...
    ptb.lineWidthInPix, ptb.white, [ptb.xCenter ptb.yCenter]);
    
    Screen('DrawingFinished', ptb.window);
    Screen('Flip', ptb.window);
    
    Screen('Close', tex1);
    Screen('Close', tex2);
    Screen('Close', tex1Other);
    Screen('Close', tex2Other);
    
%     WaitSecs(0.05);
end

end