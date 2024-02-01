function savedata(get,ptb,design)
    %.............................GET RESPONSES...........................%
    % Regardless of HOW the experiment ended.
    % Stop KbQueue data collection
    KbQueueStop(ptb.Keyboard2); 
    KbQueueStop(ptb.Keyboard1);     
    
    % the exact times of which button was pressed at which point. Cannot be
    % preallocated because we do not know how many switches may occur
    get.data.idDown     = [];
    get.data.timeDown   = [];
    get.data.idUp       = [];
    get.data.timeUp     = [];
    % Extract events
    while KbEventAvail(ptb.Keyboard2)
        [evt, ~] = KbEventGet(ptb.Keyboard2);
        
        if evt.Pressed == 1
            get.data.idDown   = [get.data.idDown; evt.Keycode];
            get.data.timeDown = [get.data.timeDown; evt.Time];
        else
            get.data.idUp   = [get.data.idUp; evt.Keycode];
            get.data.timeUp = [get.data.timeUp; evt.Time];
        end
    end

    % filename dependent on task [objects|gratings] and run [1-6]
    fileName = sprintf('sub-%02d_task-IOG_run-%02d',get.subjectNumber,get.runNumber); %[get.sub '_task-' get.task sprintf('_run-%02d',get.runNr)];

    get.subjectDirectory = sprintf('../../sourcedata/sub-%02d', get.subjectNumber);
    if ~exist(get.subjectDirectory, 'dir')
        mkdir(get.subjectDirectory)
    end
    
    % get the file
    if design.useET 
        try
            fprintf('Receiving data file ''%s''\n',  get.edfFile);
            status=Eyelink('ReceiveFile');
            WaitSecs(2);
            if status > 0
                fprintf('ReceiveFile status %d\n', status);
            end
            if exist(get.edfFile, 'file') == 2
                fprintf('Data file ''%s'' can be found in ''%s''\n',  get.edfFile, pwd );
            end
        catch rdf
            fprintf('Problem receiving data file ''%s''\n', get.edfFile );
            rethrow(rdf);
        end
    end

    if strcmp(get.end,'Finished with errors') % PRG: save in jsut one file.
        save(fullfile(get.subjectDirectory, [fileName '_' char(datetime) '_ptb_error']),'ptb');
        save(fullfile(get.subjectDirectory, [fileName '_' char(datetime) '_get_error']),'get');
        save(fullfile(get.subjectDirectory, [fileName '_' char(datetime) '_design_error']),'design');
        if design.useET
            unixStr=['mv ' get.edfFile ' ' fullfile(get.subjectDirectory, [fileName '_error.edf'])];
            unix(unixStr);
        end
    elseif strcmp(get.end,'Escape')
        save(fullfile(get.subjectDirectory, [fileName '_' char(datetime) '_ptb_cancelled']),'ptb');
        save(fullfile(get.subjectDirectory, [fileName '_' char(datetime) '_get_cancelled']),'get'); 
        save(fullfile(get.subjectDirectory, [fileName '_' char(datetime) '_design_cancelled']),'design');
        if design.useET
            unixStr=['mv ' get.edfFile ' ' fullfile(get.subjectDirectory, [fileName '_cancelled.edf'])];
            unix(unixStr);
        end
        fprintf('\n Saved cancelled data.... \n');
    elseif strcmp(get.end,'Success')
        save(fullfile(get.subjectDirectory, [fileName '_' char(datetime) '_ptb']),'ptb');
        save(fullfile(get.subjectDirectory, [fileName '_' char(datetime) '_get']),'get'); 
        save(fullfile(get.subjectDirectory, [fileName '_' char(datetime) '_design']),'design');
        fprintf('\n Saved success data.... \n');
        if design.useET
            unixStr=['mv ' get.edfFile ' ' fullfile(get.subjectDirectory, [fileName '.edf'])];
            unix(unixStr);
        end
        [resultsTable, success] = formatResponses(get,ptb);
        if success
            % save table as csv file
            writetable(resultsTable, fullfile(get.folderName, [fileName '.csv']));
        else
            fprintf('Could not save results table');
        end
    end 
        
end