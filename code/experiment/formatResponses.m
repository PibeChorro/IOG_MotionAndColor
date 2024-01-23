function [sortedResultsTable, success] = formatResponses(get,ptb)
%formatResponses: transforms key presses and releases into a table that can
%be written into a csv file for further analyses
%   input:
%       log - strucutre containing button presses and releases with
%       corresponding key IDs 
%       ptb - strucutre containing the meaning of key IDs (i.e., which key
%       ID corresponds to which percept)
%   output:
%       sortedResultsTable - a table sorted along the percep onset. The
%       columns are: Onset, duration, percept, eye the "true color" image
%       was presented to and a column that indicates whether or not we
%       added an artificial key press
%       success - a boolean whether or not everything worked fine
%
%   The function turns key presses and releases into a time series with a
%   temporal resolution of 1ms. From there we transform back into onsets
%   and durations for percepts
%   In case of differing number of key presses than releases, we add an
%   artificial key release at the end

try

    get.data.timeDown   (find(~ismember(get.data.idDown,[ptb.Keys.monocular ptb.Keys.interocular]))) = [];
    get.data.timeUp     (find(~ismember(get.data.idUp,  [ptb.Keys.monocular ptb.Keys.interocular]))) = [];
    get.data.idDown     (find(~ismember(get.data.idDown,[ptb.Keys.monocular ptb.Keys.interocular]))) = [];
    get.data.idUp       (find(~ismember(get.data.idUp,  [ptb.Keys.monocular ptb.Keys.interocular]))) = [];

        
    % stuff to save onset, duration and percept in
    percepts    = {};   % which stimulus was perceived
    condition    = {};   % which stimulus was shown
    monocular    = {};   % whether the percept was monocular
    interocular = {};    % whether the percept was interocular
    durations   = [];   % how long was the percept
    onsets      = [];   % when did the percept start
    keyAdded    = [];   % a column of zeros that only has a one in the end if we artificially added a key release

    % for each trial
    for trl = 1:length(get.data.trialOnset)
        % do we add an artificial key release at the end?
        artificialKeyreleases   = false;
        % was there any button pressed during the trial?
        anyButtonPressed        = true;
        %% get key presses during trial
        stimOnset   = get.data.trialOnset(trl);
        stimOffset  = get.data.trialOffset(trl);

        % TODO: add stim offset
        trialKeyTimeDown    = intersect(find(get.data.timeDown >= stimOnset), ...
            find(get.data.timeDown <= stimOffset));
        trialKeyTimeUp      = intersect(find(get.data.timeUp >= stimOnset), ...
            find(get.data.timeUp <= stimOffset));

        % get the actual time and id key presses and releases
        trialTimeDown   = get.data.timeDown(trialKeyTimeDown);
        trialTimeUp     = get.data.timeUp(trialKeyTimeUp);
        trialIdDown     = get.data.idDown(trialKeyTimeDown);
        trialIdUp       = get.data.idUp(trialKeyTimeUp);

        % check if button presses is empty 
        if isempty(trialTimeDown)
            trialIdUp = [];
            trialTimeUp = [];
            anyButtonPressed = false;
        end

        if anyButtonPressed
            %% separate into true color and false color key presses
            % true color
            monocularDown   = trialTimeDown(trialIdDown==ptb.Keys.monocular);
            monocularUp     = trialTimeUp(trialIdUp==ptb.Keys.monocular);
            
            % false color
            interOcularDown  = trialTimeDown(trialIdDown==ptb.Keys.interocular);
            interOcularUp    = trialTimeUp(trialIdUp==ptb.Keys.interocular);
            % check for inconsisten key presses
            %% first for true color
            % no press, but a release - subject pressed before trial
            % started
            if isempty(monocularDown) && ~isempty(monocularUp)
                monocularUp = [];
            % there are presses and releases - normal case
            elseif ~isempty(monocularDown) && ~isempty(monocularUp)
                % first release happened before the first press - as in
                % upper condition
                if monocularUp(1)<monocularDown(1)
                    monocularUp(1) = [];
                end
                % more presses than releases - subject kept pressing until
                % the end of the trial
                if length(monocularDown)>length(monocularUp)
                    monocularUp(end+1) = stimOffset;
                    artificialKeyreleases = true;
                end
            % there is a press, but no release - as in upper condition
            elseif ~isempty(monocularDown) && isempty(monocularUp)
                monocularUp(end+1) = stimOffset;
                artificialKeyreleases = true;
            end

            %% second for false color
            % no press, but a release - subject pressed before trial
            % started
            if isempty(interOcularDown) && ~isempty(interOcularUp)
                interOcularUp = [];
            % there are presses and releases - normal case
            elseif ~isempty(interOcularDown) && ~isempty(interOcularUp)
                % first release happened before the first press - as in
                % upper condition
                if interOcularUp(1)<interOcularDown(1)
                    interOcularUp(1) = [];
                end
                % more presses than releases - subject kept pressing until
                % the end of the trial
                if length(interOcularDown)>length(interOcularUp)
                    interOcularUp(end+1) = stimOffset;
                    artificialKeyreleases = true;
                end
            % there is a press, but no release - as in upper condition
            elseif ~isempty(interOcularDown) && isempty(interOcularUp)
                interOcularUp(end+1) = stimOffset;
                artificialKeyreleases = true;
            end
            
            % last check: if key presses and key releases are not the same
            % length, something has been gone wrong. However, this should not
            % happen
            if length(monocularDown) ~= length(monocularUp) || length(interOcularDown) ~= length(interOcularUp)
                error('You have a different amount of key releases and presses')
            end
    
            timeVector = stimOnset:0.001:stimOffset+ptb.ifi;
            monocularTimeSeries = zeros(size(timeVector));
            interOcularTimeSeries = zeros(size(timeVector));
            mixedTimeSeries = zeros(size(timeVector));
    
            for i = 1:length(monocularDown)
                startIdx = round((monocularDown(i) - stimOnset) * 1000) + 1;
                endIdx = round((monocularUp(i) - stimOnset) * 1000) + 1;
    
                monocularTimeSeries(startIdx:endIdx) = 1;
            end
    
            for i = 1:length(interOcularDown)
                startIdx = round((interOcularDown(i) - stimOnset) * 1000) + 1;
                endIdx = round((interOcularUp(i) - stimOnset) * 1000) + 1;
    
                interOcularTimeSeries(startIdx:endIdx) = 1;
            end
    
            % We separated the two button presses into two time serieses
            % with a resolution of 1ms. It is true for when a corresponding
            % button is pressed and false if it is not pressed.
            % We get the indices where both buttons are pressed AND where
            % no button was pressed and associate them as mixed
            % Here an example:
            % 1111111111111111111100000000000000000000111111111111111111111
            % 0000000000000000000000222222222222222222222000000000000000000
            % 0000000000000000000033000000000000000000333000000000000000000
            % ==
            % 1111111111111111111100000000000000000000000111111111111111111
            % 0000000000000000000000222222222222222222000000000000000000000
            % 0000000000000000000033000000000000000000333000000000000000000

            bothPressed = intersect(find(interOcularTimeSeries==1),find(monocularTimeSeries==1));
            nonePressed = intersect(find(interOcularTimeSeries==0),find(monocularTimeSeries==0));
            mixedTimeSeries(bothPressed) = 1;
            mixedTimeSeries(nonePressed) = 1;
    
            monocularTimeSeries(bothPressed)    = 0;
            interOcularTimeSeries(bothPressed)   = 0;
    
            % go back from time series to onset - offset arrays
            monocularTransitions = diff(monocularTimeSeries>0);
            monocularOnsetIndices = find(monocularTransitions == 1);
            monocularOffsetIndices = find(monocularTransitions == -1);
            % check if first or last entry in time series is true
            if monocularTimeSeries(1)
                monocularOnsetIndices = [1 monocularOnsetIndices];
            end
            if monocularTimeSeries(end)
                monocularOffsetIndices = [monocularOffsetIndices length(monocularTimeSeries)];
            end
            monocularOnsets = timeVector(monocularOnsetIndices) - get.data.trialOnset(1);
            monocularOffsets = timeVector(monocularOffsetIndices) - get.data.trialOnset(1);
            monocularDurations = monocularOffsets - monocularOnsets;
    
            interOcularTransitions = diff(interOcularTimeSeries>0);
            interOcularOnsetIndices = find(interOcularTransitions == 1);
            interOcularOffsetIndices = find(interOcularTransitions == -1);
            % check if first or last entry in time series is true
            if interOcularTimeSeries(1)
                interOcularOnsetIndices = [1 interOcularOnsetIndices];
            end
            if interOcularTimeSeries(end)
                interOcularOffsetIndices = [interOcularOffsetIndices length(interOcularTimeSeries)];
            end
            interOcularOnsets = timeVector(interOcularOnsetIndices) - get.data.trialOnset(1);
            interOcularOffsets = timeVector(interOcularOffsetIndices) - get.data.trialOnset(1);
            interOcularDurations = interOcularOffsets - interOcularOnsets;
    
            mixedTransitions = diff(mixedTimeSeries>0);
            mixedOnsetIndices = find(mixedTransitions == 1);
            mixedOffsetIndices = find(mixedTransitions == -1);
            % check if first or last entry in time series is true
            if mixedTimeSeries(1)
                mixedOnsetIndices = [1 mixedOnsetIndices];
            end
            if mixedTimeSeries(end)
                mixedOffsetIndices = [mixedOffsetIndices length(mixedTimeSeries)];
            end
            mixedOnsets = timeVector(mixedOnsetIndices) - get.data.trialOnset(1);
            mixedOffsets = timeVector(mixedOffsetIndices) - get.data.trialOnset(1);
            mixedDurations = mixedOffsets - mixedOnsets;

            % store in arrays
            % first true color -- monocular percept
            onsets      = [onsets; monocularOnsets'];
            durations   = [durations; monocularDurations'];
            percepts    = [percepts; repmat({'monocular'},length(monocularDurations),1)];
            % now false color -- interocular percept
            onsets      = [onsets; interOcularOnsets'];
            durations   = [durations; interOcularDurations'];
            percepts    = [percepts; repmat({'interocular'},length(interOcularDurations),1)];
            % now mixed percepts -- neither monocular nor interocular
            % percepts
            onsets      = [onsets; mixedOnsets'];
            durations   = [durations; mixedDurations'];
            percepts    = [percepts; repmat({'mixed'},length(mixedDurations),1)];
    
    
            numSwitches = length(monocularDurations) + length(interOcularDurations) + length(mixedDurations);
        else
            % apparently no button has been pressed during this trial
            % i.e., only mixed percept here
            mixedOnset = stimOnset;
            mixedDurations = stimOffset-stimOnset;

            onsets = [onsets; mixedOnset];
            durations = [durations; mixedDurations];
            percepts = [percepts; {'mixed'}];

            numSwitches = 1;
            warning('No key was pressed in trial %u\n', trl);
        end
        condition = [condition; repmat({get.data.Condition(trl)},numSwitches,1)];

        % was an artificial key press added?
        addedRelease = zeros(numSwitches,1);
        if artificialKeyreleases
            addedRelease(end) = 1;
        end
        keyAdded = [keyAdded; addedRelease];

    end
    resultsTable = table(condition, percepts, onsets, durations);
    sortedResultsTable = sortrows(resultsTable, 3);
    % add the information whether or not an artificial key release was
    % added here, so that it does not get mixed by the sorting process
    sortedResultsTable.keyAdded = keyAdded;

    success = true;

catch READINGERROR
    fprintf('Something went wrong in trial %u\n', trl);
    rethrow(READINGERROR);
end
