%% GENERAL FUNCTION AND MONITOR SETUP:

% First of all, the code aims to create a function IOGMotionMain, which
% sets input value to "setUp", which is the chosen setup monitor.
% Then, ptb, a variable created is set to take the value of
% PTBSettingsIOGMotion of the setUp chosen. a try/catch loop is presented
% here in case there is an error in choosing the setup and the monitor
% settings for debugging purposes.

%% DESIGN OF THE STIMULI, MONDREAN MASKS AND THE FIXATION CROSS: 

% The code then sets different features and sizes of the design of
% the stimulus for the experiment (two gratings in each eye, one grating
% having one horizontal and one vertival grating, and the other one the
% same).
% Also importantly, designing the Mondrean masks that will surround the
% gratings stimuli in a rectangular manner.

% Creation of the fixation cross at the center of each grating, with their
% position, size, and color in relation to the gratings and the screen
% monitor.

%% INSTRUCTIONS AND FUSION TEST:

% Then, we open a series of windows for experimental instructions based on another script's function that
% was defined, with a try/catch loop to rethrow an error in case there is
% one (openExperimentWindow.m)

% Then, another try/catch loop is displayed for another script's function
% that creates the fusion test before the actual experiment (alignFusion.m)

%% READING DATA FROM EXCEL FILES TO COUNTERBALANCE AND RANDOMIZE DIFFERENT CUES (MOTION DIRECTION, COLOR, AND ORIENTATION).

% First, we assign a variable called "data" to a "readtable" function that
% reads the each file of the four runs that have the different conditions with
% different motion directions of the gratings, orientations and colors
% (four trials in each run, for each possible condition).

% Using the created struct (data), we assign variables to the existing
% column names in the files (e.g. Motion1 = data.Motion1, Color1 = data.color1)...


% Then, we assign values 1 and 2 to orientations horizontal and vertical,
% respectively (but this could maybe be also done in the cases section
% below).

% These are to be used later during the randomization stage in the while
% loop.

%% CREATION OF A REPETITION MATRIX FOR MOTION SIMULATION

% We assign a variable x to create a repetition matrix containing 314 rows
% and 314 columns, and in each row there are values ranging from 1 to 314
% throughout the columns.

%% CREATION OF MONDREAN MASKS

% Using the x variable, we create two alphamasks that are Mondrian masks,
% first by assigning the first mask to a repetition matrix in the size of x
% and filling it with zero values, and doing the same for the second mask.

%% COUNTERBALANCING ORDER OF CONDITIONS

% Before the start of the actual while loop with the different
% cases/conditions displayed, we need to counterbalance for the order of
% the conditions. So, we create a for loop that iterates over the four
% different conditions. We also create a variable (namely
% shuffledScenarios), which chooses randomly one of the conditions. we
% assign it to a group1Order, in which a group of participants have that
% shuffled order, and we create a group2Order, in which another group of
% participants are assigned the flip version of the shuffled order. We also
% make sure the data on which participants got which groupOrder is saved
% into two mat files: One for Group Order 1 and another for Group Order 2.

%% START OF THE WHILE LOOP FOR THE DIFFERENT CONDITIONS/CASES

% We start with a while true loop which iterates over the different
% scenarios/conditions and creates the different gratings orientations and
% alpha masks surrounding the gratings in both eyes.
% First condition only displays orientation, so it should only create
% sine-wave gratings that are horizontal-vertical for one eye and
% vertical-horizontal for the other eye.

% Second condition displays orientation and color, so it should also have
% a code which creates green and red colors that are interchangeable for
% horizontal and vertical orientations and are randomized using the Excel
% files.

% Third condition displays orientation and motion but no color, so it
% should create gratings for orientation, and motionDirections which should
% be randomized based on the excel files with the motion direction column.

% Fourth condition displays all grouping cues: orientation, motion, and color, so it
% should do what was mentioned before altogether.

% If scenario was undefined, for example case 5, then an error should pop up
% with a text display stating that the person picked an undefined scenario.


%%  SELECTING IMAGE BUFFERS FOR COLOR OF STIMULI

% Code should now create the specific textures and appropriate colors for
% the stimuli being displayed

%% SAVING PARTICIPANT FILES

% Files should be saved for each participant in each of the four runs. 
