%{
---------- description ----------
Created on Fri Feb 19 2021
Author : Yuta Suzuki

Eye-tracker     : EyeLink
Display         : Display++
Visual distance : 60 cm

Copyright (c) 2021 Yuta Suzuki
This software is released under the MIT License, see LICENSE.
%}

clear all;
close all;
Screen('Close')
Screen('Preference', 'SkipSyncTests', 1);
addpath(genpath('./toolBox'))

%% ------------- paradigm settings ------------------
cfg = [];
cfg.TIME_FIXATION = 1;  % fixation time
cfg.PRESENTATION  = 10; % presentation
cfg.TIME_ISI      = 2;  % ISI

cfg.SP_FREQ = 0.8; % spatial frequency [cycle/degree]
cfg.NUM_LINE = 6;
cfg.WHITE_LINE_WIDTH = 0.2; % white line width [%]

% cfg.SAMPLING_RATE = 1000;    % refresh rate of an eye tracking device
cfg.FRAME_RATE = 60;
cfg.VISUAL_DISTANCE = 60;
cfg.NUM_TRIAL = 1;
cfg.SESSION = 1;

cfg.BGCOLOR = 128;
cfg.DOT_PITCH = 0.271;      % Flexscan S2133 (21.3 inch, 1600 x 1200 pixels size)
cfg.LINECOLOR = [[120,120,120];[50,0,50]];    % circle color [background,line]
cycleWidth = round(pixel_size(cfg.DOT_PITCH, 1/cfg.SP_FREQ, cfg.VISUAL_DISTANCE));
cfg.SIZE_STIM = cycleWidth * cfg.NUM_LINE;

cfg.LINECOLOR(3,:) = round(cfg.LINECOLOR(2,:) * 0.5 + cfg.LINECOLOR(1,:)*0.5);

% cfg.LINEANGLE = [340,20];   % toward above
cfg.LINEANGLE = [20,340];   % toward bottom

cfg.ctrl = true;

lineWidth = round(pixel_size(cfg.DOT_PITCH, (1/cfg.SP_FREQ)*cfg.WHITE_LINE_WIDTH, cfg.VISUAL_DISTANCE));

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


% square(x,y,locs(one slide),alpha)
square = ones(cfg.SIZE_STIM,cfg.SIZE_STIM,4,cycleWidth);
square_ctrl = ones(cfg.SIZE_STIM,cfg.SIZE_STIM,4,cycleWidth);

% base color
for rgb=1:3
    square(:,:,rgb,:) = cfg.LINECOLOR(2,rgb);
    square_ctrl(:,:,rgb,:) = cfg.LINECOLOR(3,rgb);
end

% make zebra
for iLine = 1:cfg.NUM_LINE
    for rgb=1:3
        square(:,(iLine-1)*cycleWidth+1:iLine*cycleWidth-lineWidth,rgb,1) = cfg.LINECOLOR(1,rgb);
        square_ctrl(:,(iLine-1)*cycleWidth+1:iLine*cycleWidth-lineWidth,rgb,1) = cfg.LINECOLOR(1,rgb);
    end
    square(:,(iLine-1)*cycleWidth+1:iLine*cycleWidth-lineWidth,4,1) = 255;
    square_ctrl(:,(iLine-1)*cycleWidth+1:iLine*cycleWidth-lineWidth,4,1) = 255;
end

% make steps
for iMove = 1:cycleWidth
    square(:,:,:,iMove) = circshift(square(:,:,:,1),iMove-1,2);
    square_ctrl(:,:,:,iMove) = circshift(square_ctrl(:,:,:,1),iMove-1,2);
end

% alpha inside circle = 255
alpha = zeros(cfg.SIZE_STIM,cfg.SIZE_STIM);
a = cfg.SIZE_STIM/2;
b = cfg.SIZE_STIM/2;

for x = 1:cfg.SIZE_STIM
    for y = 1:cfg.SIZE_STIM
        p = (x-b)^2 + (y-a)^2;
        
        % inside
        if p <= (cfg.SIZE_STIM/2)^2
            alpha(x,y) = 255;
            % ouside
        else
            square(x,y,:,:) = 0;
            square_ctrl(x,y,:,:) = 0;
        end
    end
end

for iMove = 1:cycleWidth
    
    % Right
    tmp_alpha = alpha;
    
    tmp_alpha(square(:,:,1,iMove)==cfg.LINECOLOR(1,1) & ...
        square(:,:,2,iMove)==cfg.LINECOLOR(1,2) & ...
        square(:,:,3,iMove)==cfg.LINECOLOR(1,3))=255;
    
    tmp_alpha(square(:,:,1,iMove)==cfg.LINECOLOR(2,1) &...
        square(:,:,2,iMove)==cfg.LINECOLOR(2,2) &...
        square(:,:,3,iMove)==cfg.LINECOLOR(2,3))=round(255*0.5); %128+128*0.5
    
    square(:,:,4,iMove) = tmp_alpha;
    texture_right = Screen('MakeTexture',win,square(:,:,:,iMove));
    
    % Left
    tmp_alpha = alpha;
    
    if cfg.ctrl
           tmp_alpha(square(:,:,1,cycleWidth+1-iMove)==cfg.LINECOLOR(1,1) & ...
        square(:,:,2,cycleWidth+1-iMove)==cfg.LINECOLOR(1,2) & ...
        square(:,:,3,cycleWidth+1-iMove)==cfg.LINECOLOR(1,3))=0;
    
        tmp_alpha(square(:,:,1,cycleWidth+1-iMove)==cfg.LINECOLOR(2,1) &...
        square(:,:,2,cycleWidth+1-iMove)==cfg.LINECOLOR(2,2) &...
        square(:,:,3,cycleWidth+1-iMove)==cfg.LINECOLOR(2,3))=0; %128+128*0.5
     else
         tmp_alpha(square(:,:,1,cycleWidth+1-iMove)==cfg.LINECOLOR(1,1) & ...
        square(:,:,2,cycleWidth+1-iMove)==cfg.LINECOLOR(1,2) & ...
        square(:,:,3,cycleWidth+1-iMove)==cfg.LINECOLOR(1,3))=0;
    
        tmp_alpha(square(:,:,1,cycleWidth+1-iMove)==cfg.LINECOLOR(2,1) &...
            square(:,:,2,cycleWidth+1-iMove)==cfg.LINECOLOR(2,2) &...
            square(:,:,3,cycleWidth+1-iMove)==cfg.LINECOLOR(2,3))=round(255*0.5); %128+128*0.5
      end
    square_ctrl(:,:,4,cycleWidth+1-iMove) = tmp_alpha;
    square(:,:,4,cycleWidth+1-iMove) = tmp_alpha;
    
%     texture_left = Screen('MakeTexture',win,square_ctrl(:,:,:,cycleWidth+1-iMove));
    texture_left = Screen('MakeTexture',win,square(:,:,:,cycleWidth+1-iMove));
    
    % Draw texture
    [window_s(iMove),screenRect] = Screen('OpenOffscreenWindow',screenNumber,cfg.BGCOLOR,[],[],32);
    Screen('CopyWindow',window_s(iMove), win);
    
%     Screen('FillOval', win, ones(1,3)*cfg.LINECOLOR(1),...
%         [centerX - cfg.SIZE_STIM, centerY - cfg.SIZE_STIM,...
%         centerX + cfg.SIZE_STIM, centerY + cfg.SIZE_STIM]);
    
    Screen('DrawTexture', win, texture_right,[],...
        [(centerX-cfg.SIZE_STIM), (centerY-cfg.SIZE_STIM),...
        (centerX+cfg.SIZE_STIM), (centerY+cfg.SIZE_STIM)],...
        cfg.LINEANGLE(1));
    
    Screen('DrawTexture', win, texture_left,[],...
        [(centerX-cfg.SIZE_STIM), (centerY-cfg.SIZE_STIM),...
        (centerX+cfg.SIZE_STIM), (centerY+cfg.SIZE_STIM)],...
        cfg.LINEANGLE(2));
    
    Screen('FrameOval', win,ones(1,3)*cfg.BGCOLOR,...
        [(centerX-cfg.SIZE_STIM)-3, (centerY-cfg.SIZE_STIM)-3,...
        (centerX+cfg.SIZE_STIM)+3, (centerY+cfg.SIZE_STIM)+3],5)
    
    if cfg.ctrl
        Screen('CopyWindow',win, window_s(iMove));
        imageArray=Screen('GetImage',window_s(iMove));
    end
    
    Screen('DrawLines', win, FixationXY,1, FixColor);
    Screen('CopyWindow',win, window_s(iMove));
    
    
end

if useEyelink
    Eyelink('Message', 'Start_Experiment');
end

%% show messages before start
showMessage(cfg,'Ready...',[],screenNumber,win);

%% main
for i_trial = 1:All_trial
    
    disp(['Trials:' num2str(i_trial) ', Condition:' num2str(condition_frame(i_trial)) ]);
    
    fixation();
    presentation();
    
    if i_trial ~= All_trial
        if mod((i_trial),round((All_trial)/cfg.SESSION)) == 0
            disp('Break');
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
