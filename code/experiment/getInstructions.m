function [design] = getInstructions()

design.FusionText   = [
        'Fusionstest: nutze die und Tasten, um das Feld einzustellen. \n'...
        'Drücke die Taste um zu bestätigen'];
 if nargin < 2
     design = struct;
 end
 
% %% sanity check: are all the fields present in log and design?
% % design

if ~isfield(design, 'stimulusPresentationTime')
     design.stimulusPresentationTime = 120;
 end
 if ~isfield(design, 'ITI')
     design.ITI = 10;
 end
 if ~isfield(design, 'numTrials')
     design.numTrials = 5;
 end
% % log
%  if ~isfield(log, 'subjectNr')
%      log.subjectNr = 'test';
%  end
%  if ~isfield(log, 'numStimuli')
%      log.numStimuli = 4;
%  end
% 
%  if strcmp (log.language, 'german')
%      %% determine response keys
%      % check if subjectNr is a number
%      [subNr, success] = str2num(log.subjectNr);
%      if success
%          if mod(subNr,2)
%              log.indoorResponse  = 'links';
%              log.outdoorResponse = 'rechts';
%          else
%              log.indoorResponse  = 'rechts';
%              log.outdoorResponse = 'links';
%          end
%      else
%          log.indoorResponse  = 'links';
%          log.outdoorResponse = 'rechts';
%      end
%      log.confirm = 'mittlere';

     
    %% general instructions
%     if strcmp(log.language, 'german')
%          design.Introduction = [
%              'Vielen Dank dass du an unserer Binocular Rivalry Studie teilnimmst.\n\n'...
%              'Drücke eine beliebige Taste um fortzufahren'
%              ];
%          % fixation cross
%          design.fixOnFixCross = [
%              'Zwischen den trials fixiere bitte das Fixationskreuz\n\n' ...
%              'Drücke einen beliebige Taste um fort zu fahren'
%              ];
%          design.waitTillStart = [
%              'Wir starten in ' num2str(round(design.ITI)) 's.\n\n' 
%              ];
%     end
%  
%      design.RunIsOver = [
%          'Der Durchlauf ist vorbei.\n\n' ...
%          'Drücke eine beliebige Taste und wende dich an den Versuchsleiter'
%          ];
%      design.proceedText = 'Drücke eine beliebige Taste um fort zu fahren';
% 
%     %% Align fusion
%      design.FusionText   = [
%          'Fusionstest: nutze die ' log.indoorResponse ' and ' log.outdoorResponse ' Tasten, um das Feld einzustellen. \n'...
%          'Drücke die ' log.confirm ' Taste um zu bestätigen'];
%  else
%      %% determine response keys
%      % check if subjectNr is a number
%      [subNr, success] = str2num(log.subjectNr);
%      if success
%          if mod(subNr,2)
%              log.indoorResponse  = 'left';
%              log.outdoorResponse = 'right';
%          else
%              log.indoorResponse  = 'right';
%              log.outdoorResponse = 'left';
%          end
%      else
%          log.indoorResponse  = 'left';
%          log.outdoorResponse = 'right';
%      end
%      log.confirm = 'middle';
%     % English version of instructions
% 
%     %% general instructions
     design.Introduction = [
         'Thank you very much for participating in our study.\n\n'...
         'Press any button to proceed.'
         ];
%     % fixation cross
     design.fixOnFixCross = [
         'Between trials please fixate on the fixation cross.\n\n' ...
         'Press any button to proceed'
         ];
     design.waitTillStart = [
         'We start in ' num2str(round(design.ITI)) 's.\n\n' 
         ];
     design.RunIsOver    = [
         'This run is now over\n\n' ...
         'Press any button to continue'
         ];
     design.proceedText = 'Press any button to proceed';
%     %% Align fusion
     design.FusionText   = ['Fusion test: use and to adjust or press to continue'];
%  end
end
