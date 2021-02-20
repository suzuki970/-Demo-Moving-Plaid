clear all;
close all;
Screen('Close')
Screen('Preference', 'SkipSyncTests', 1);
addpath(genpath('./toolBox'))

%% --------------------paradigm settings------------------
cfg = [];
cfg.TIME_FIXATION = 1;      % fixation time
cfg.PRESENTATION = 180;
cfg.TIME_ISI = 2;           % ISI

cfg.FRAME_RATE = 60;
% cfg.SAMPLING_RATE = 1000;    % refresh rate of an eye tracking device
cfg.VISUAL_DISTANCE = 60;
cfg.NUM_TRIAL = 4;
cfg.SESSION=4;

cfg.BGCOLOR = 128;
cfg.DOT_PITCH = 0.271;  % Flexscan S2133 (21.3 inch, 1600 x 1200 pixels size)

cfg.SP_FREQ = 0.8; % spatial frequency [cycle/degree]
cfg.SP_FREQ = 2; % spatial frequency [cycle/degree]
cfg.NUM_LINE = 6;
% cfg.SIZE_STIM = round(pixel_size(cfg.DOT_PITCH, (1/cfg.SP_FREQ) * cfg.NUM_LINE, cfg.VISUAL_DISTANCE));
cfg.WHITE_LINE_WIDTH = 0.2; % white line width [%]
% cfg.SIZE_STIM = 6; %[degree]

% cfg.FRAME_RATE = 60;

cycleWidth = round(pixel_size(cfg.DOT_PITCH, 1/cfg.SP_FREQ, cfg.VISUAL_DISTANCE));
cfg.SIZE_STIM = cycleWidth * cfg.NUM_LINE;

lineWidth = round(pixel_size(cfg.DOT_PITCH, (1/cfg.SP_FREQ)*cfg.WHITE_LINE_WIDTH, cfg.VISUAL_DISTANCE));

square = ones(cfg.SIZE_STIM,cfg.SIZE_STIM,4,cycleWidth)*128;

%% ----------------------------------------------------
% set KeyInfo
parmSetting();

% fixation
fixlength = pixel_size(cfg.DOT_PITCH, 0.3, cfg.VISUAL_DISTANCE);
FixationXY=[centerX-1*fixlength, centerX+fixlength, centerX, centerX; centerY, centerY, centerY-1*fixlength, centerY+fixlength];
FixColor=[128 128 128];

fix = Screen('OpenOffscreenWindow',screenNumber, cfg.BGCOLOR,[],[],32);
Screen('DrawLines', fix, FixationXY,1, FixColor);

empty = Screen('OpenOffscreenWindow',screenNumber, cfg.BGCOLOR,[],[],32);
Screen('CopyWindow',win, empty);

% number of trials
condition_type = 1;
All_trial = cfg.NUM_TRIAL * condition_type;

%% stimulus parameter setting
Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%% make stim
condition_frame = 1:cycleWidth;
% condition_frame = round(linspace(1,cycleWidth,cycleWidth*0.5));

for iLine = 1:cfg.NUM_LINE
    square(:,(iLine-1)*cycleWidth+1:iLine*cycleWidth-lineWidth,:,1) = 255;
end

for iMove = 1 : cycleWidth
    square(:,:,:,iMove) = circshift(square(:,:,:,1),iMove-1,2);
end

alpha = zeros(cfg.SIZE_STIM,cfg.SIZE_STIM);
a = cfg.SIZE_STIM/2;
b = cfg.SIZE_STIM/2;

for x = 1:cfg.SIZE_STIM
    for y = 1:cfg.SIZE_STIM
        p = (x-b)^2 + (y-a)^2;
        if p <= (cfg.SIZE_STIM/2)^2
            alpha(x,y) = 255;
        else
            square(x,y,:,:) = 0;
        end
    end
end

for iMove = 1:cycleWidth
    tmp_alpha = alpha;
    tmp_alpha(square(:,:,1,iMove)==255)=255;
    tmp_alpha(square(:,:,1,iMove)==128)=round(255*0.5); %128+128*0.5
    
    square(:,:,4,iMove) = tmp_alpha;
    
    texture_right = Screen('MakeTexture',win,square(:,:,:,iMove));
    
    tmp_alpha = alpha; 
    tmp_alpha(square(:,:,1,cycleWidth+1-iMove)==255)=0;
    tmp_alpha(square(:,:,1,cycleWidth+1-iMove)==128)=round(255*0.5); %128+128*0.5
    
    square(:,:,4,cycleWidth+1-iMove) = tmp_alpha;
    texture_left = Screen('MakeTexture',win,square(:,:,:,cycleWidth+1-iMove));
    
    [window_s(iMove),screenRect] = Screen('OpenOffscreenWindow',screenNumber,cfg.BGCOLOR,[],[],32);
    Screen('CopyWindow',window_s(iMove), win);

    Screen('FillOval', win, [255 255 255], [centerX - cfg.SIZE_STIM, centerY - cfg.SIZE_STIM, centerX + cfg.SIZE_STIM, centerY + cfg.SIZE_STIM]);
    Screen('DrawTexture', win, texture_right,[],[(centerX-cfg.SIZE_STIM), (centerY-cfg.SIZE_STIM), (centerX+cfg.SIZE_STIM), (centerY+cfg.SIZE_STIM)],20);
    Screen('DrawTexture', win, texture_left,[],[(centerX-cfg.SIZE_STIM), (centerY-cfg.SIZE_STIM), (centerX+cfg.SIZE_STIM), (centerY+cfg.SIZE_STIM)],340);
    Screen('DrawLines', win, FixationXY,1, FixColor);
    
    Screen('CopyWindow',win, window_s(iMove));
end

if useEyelink
    Eyelink('Message', 'Start_Experiment');
end

% show some messages before start
showMessage(cfg,'Ready...',[],screenNumber,win);

for i_trial = 1:All_trial
    
    disp(['Trials:' num2str(i_trial) ', Condition:' num2str(condition_frame(i_trial)) ]);
    
    Baseline();
    presentation();
    if useEyelink == 1
        TrialRawData{1,i_trial} = RawData;
        Initialization();
    end
    
    ISI();
    if i_trial ~= All_trial
        if mod((i_trial),round((All_trial)/cfg.SESSION)) == 0
            disp('Break');
            if useEyelink ==1
                EyelinkCalibration
                Initialization();
            end
            ShowMessage();
        end
    end
    Screen('Close');
end

if useEyelink
    Eyelink('Message', 'End_Experiment');
end

sca;
ListenChar(0);

% save_name = ['/blackKanizsa_',cfg.participantsInfo.name,'_',today_date];
% saveFiles();