function getKeyResponses_IOG(~)

    setUp = 'CIN-Mac-Setup';

%     ptb = PTBSettingsIOGMotion(setUp);

%     try
%         ptb = PTBSettingsIOGMotion(setUp);
%     catch PTBERROR
%         sca;
%         rethrow(PTBERROR);
%     end

    % Regardless of HOW the experiment ended.
    % Stop KbQueue data collection
    % KbQueueStop(ptb.Keyboard2)
    % ptb.Keyboard2 = keyboardIndices(1);
    KbQueueStop(ptb.Keyboard2);     
    
    % the exact times of which button was pressed at which point. Cannot be
    % preallocated because we do not know how many switches may occur

    get.data.idDown     = [];
    get.data.timeDown   = [];
    get.data.idUp       = [];
    get.data.timeUp     = [];
    % Extract events
    while KbEventAvail(ptb.Keyboard2)
        [evt, ~] = KbEventGet(ptb.Keyboard2);
        
        if evt.Pressed == 1 % for key presses
            get.data.idDown   = [get.data.idDown; evt.Keycode];
            get.data.timeDown = [get.data.timeDown; evt.Time];
        else % for key releases
            get.data.idUp   = [get.data.idUp; evt.Keycode];
            get.data.timeUp = [get.data.timeUp; evt.Time];
        end
    end
    disp(['Key Down: ', num2str(evt.Keycode)]);
end