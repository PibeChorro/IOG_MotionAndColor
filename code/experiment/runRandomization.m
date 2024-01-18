function runRandomization()

for subjectNum = 1:24

    % Number of runs
    runNumber = 8;

    % Number of trials per run
    trialsPerRun = 4;

    for runIdx = 1:runNumber

        % Define options
        NoMotion_NoColor = {
            'No Motion', 'No Motion', 'Black', 'Black', 'Horizontal',   'Vertical'
            'No Motion', 'No Motion', 'Black', 'Black', 'Horizontal',   'Vertical'
            'No Motion', 'No Motion', 'Black', 'Black', 'Horizontal',   'Vertical'
            'No Motion', 'No Motion', 'Black', 'Black', 'Horizontal',   'Vertical'
            };

        NM_NC_Condition = repmat(NoMotion_NoColor, 2, 1);

        NoMotion_Color = {
            'No Motion', 'No Motion', 'Green', 'Red', 'Horizontal', 'Vertical'
            'No Motion', 'No Motion', 'Green', 'Red', 'Vertical',   'Horizontal'
            };

        NM_C_Condition = repmat(NoMotion_Color, 4, 1);

        Motion_NoColor = {
            'Upward',   'Leftward',     'Black', 'Black', 'Horizontal', 'Vertical'
            'Downward', 'Leftward',     'Black', 'Black', 'Horizontal', 'Vertical'
            'Upward',   'Rightward',    'Black', 'Black', 'Horizontal', 'Vertical'
            'Downward', 'Rightward',    'Black', 'Black', 'Horizontal', 'Vertical'
            };

        M_NC_Condition = repmat(Motion_NoColor, 2, 1);

        Motion_Color = {
            'Upward',   'Leftward',     'Red', 'Green', 'Horizontal', 'Vertical'
            'Downward', 'Leftward',     'Red', 'Green', 'Horizontal', 'Vertical'
            'Upward',   'Rightward',    'Red', 'Green', 'Horizontal', 'Vertical'
            'Downward', 'Rightward',    'Red', 'Green', 'Horizontal', 'Vertical'
            'Upward',   'Leftward',     'Green', 'Red', 'Horizontal', 'Vertical'
            'Downward', 'Leftward',     'Green', 'Red', 'Horizontal', 'Vertical'
            'Upward',   'Rightward',    'Green', 'Red', 'Horizontal', 'Vertical'
            'Downward', 'Rightward',    'Green', 'Red', 'Horizontal', 'Vertical'
            };

        M_C_Condition = Motion_Color;

        runTrials = cell(trialsPerRun, 6);

        % Combine all conditions into one cell array
        allConditions = {NM_NC_Condition, NM_C_Condition, M_NC_Condition, M_C_Condition};

        % Randomize the order of conditions
        randomizedConditions = allConditions(randperm(length(allConditions)));

        for conditionIdx = 1:length(randomizedConditions)
        
            runTrials(1, :) = NM_NC_Condition(1, :);
            runTrials(2,:) = M_C_Condition(1,:);
            NM_NC_Condition(1, :) = [];
            M_C_Condition(1, :) = [];
          
            % Get the color and orientation combination of the selected Motion_Color
            selected_M_C_color_orientation = runTrials(2, 3:6);

            selected_M_Orientation = runTrials(2, [1:2, 5:6]);

            selectedOption = [];

            i = 1;

            while isempty(selectedOption) && i <= size(NM_C_Condition, 1)
                currentOption = NM_C_Condition(i, 3:6);

                if ~isequal(currentOption, selected_M_C_color_orientation)
                    selectedOption = NM_C_Condition(i, :);
                    runTrials(3,:) = selectedOption;
                end

                i = i + 1;
            end

            % Remove the selected option from the next choices for the trial array recruitment
            NM_C_Condition(i-1, :) = [];

            selectedOption_M = [];

            while isempty(selectedOption_M) && i <= size(M_NC_Condition, 1)
                currentOption_M = M_NC_Condition(i, [1:2, 5:6]);

                if ~isequal(currentOption_M,selected_M_Orientation)
                    selectedOption_M = M_NC_Condition(i, :);
                    runTrials(4,:) = selectedOption_M;
                end

                i = i + 1;

                if ~isempty(selectedOption_M)
                % Remove the selected option from the M_NC_Condition array
                 M_NC_Condition(i-1, :) = [];
                end
            end

        end

        runTrials = runTrials(randperm(size(runTrials, 1)), :);

        NM_NC_Condition(1,:) = [];
        M_C_Condition(1, :) = [];
        NM_C_Condition(1, :) = [];
        M_NC_Condition(1, :) = [];


        % Convert cell array to table
        T = cell2table(runTrials, 'VariableNames', {'Motion1', 'Motion2', 'Color1', 'Color2', 'Orientation1', 'Orientation2'});
    
        % Write table to CSV file
        writetable(T, sprintf('sub-%02d_run%02d_IOG.csv', subjectNum, runIdx));

    end

end
end