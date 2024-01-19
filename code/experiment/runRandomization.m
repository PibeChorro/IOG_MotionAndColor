function runRandomization()

for subjectNum = 1:24

    % Number of runs
    runNumber = 8;

    % Number of trials per run
    trialsPerRun = 4;

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
        
        % Reverse the order of rows
        Motion_NoColor = flipud(Motion_NoColor);
        
        % Replicate the modified Motion_NoColor array
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


    for runIdx = 1:runNumber

        runTrials = cell(trialsPerRun, 6);
        
            runTrials(1, :) = NM_NC_Condition(1, :);
            runTrials(2, :) = M_C_Condition(1, :);
            runTrials(3, [1, 2]) = NM_C_Condition(1, [1,2]);
          
            % Gets the color and orientation combination of the selected Motion_Color
            selected_M_C_color = runTrials(2, 3:4);
            selected_M_C_orientation = runTrials(2, 5:6);

            selected_M_Orientation = runTrials(2, [1:2, 5:6]);
            selected_NM_C_Orientation = NM_C_Condition(1, 5:6);
            
            selectedOption_C = [];

            while isempty(selectedOption_C)
                currentOption_C = NM_C_Condition(1, [3,4]);

                if ~isequal(currentOption_C, selected_M_C_color)
                    selectedOption_C = currentOption_C;
                    runTrials(3,[3,4]) = selectedOption_C;
                    runTrials(3,[5,6]) = selected_M_C_orientation;
                else
                    if isequal(selected_M_C_orientation, selected_NM_C_Orientation)
                        selectedOption_C = NM_C_Condition(1, [4,3]);
                        runTrials(3,[3,4]) = selectedOption_C;
                        runTrials(3,[5,6]) = selected_NM_C_Orientation;
                    else
                        selectedOption_C = currentOption_C;
                        runTrials(3,[3,4]) = selectedOption_C;
                        runTrials(3,[5,6]) = selected_NM_C_Orientation;
                    end

                end
            end

            selectedOption_M = [];

            while isempty(selectedOption_M)
                currentOption = M_NC_Condition(1, [1:2, 5:6]);
                
                if ~isequal(currentOption, selected_M_Orientation)
                    selectedOption_M = M_NC_Condition(1, :);
                    runTrials(4,:) = selectedOption_M;
                else
                    selectedOption_M = M_NC_Condition(1, [2:1, 3:4, 6:5]);
                    runTrials(4,:) = selectedOption_M;
                end
            end


           NM_NC_Condition(1, :) = [];
           M_C_Condition(1, :) = [];
           NM_C_Condition(1, :) = [];
           M_NC_Condition(1, :) = [];


        runTrials = runTrials(randperm(size(runTrials, 1)), :);

        
        % Convert cell array to table
        T = cell2table(runTrials, 'VariableNames', {'Motion1', 'Motion2', 'Color1', 'Color2', 'Orientation1', 'Orientation2'});
    
        % Write table to CSV file
        writetable(T, sprintf('sub-%02d_run%02d_IOG.csv', subjectNum, runIdx));
    end
end
end