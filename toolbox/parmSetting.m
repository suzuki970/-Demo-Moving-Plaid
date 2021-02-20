warning('off')
rng('shuffle');

% OpenGL
AssertOpenGL;

%%participant's info
prompt = 'Demo? 1:demo -- > ';
demoMode = input(prompt);
if demoMode~=1
    demoMode = false;
else
    demoMode = true;
end

prompt = 'Name?';
cfg.participantsInfo.name = input(prompt,'s');
while 1
    if isempty(cfg.participantsInfo.name)
        prompt = 'Name is null. try again -- > ';
        cfg.participantsInfo.name = input(prompt,'s');
    else
        break;
    end
end

prompt = 'No.?';
cfg.participantsInfo.no = input(prompt);
while 1
    if isempty(cfg.participantsInfo.no)
        prompt = 'No. is null. try again -- > ';
        cfg.participantsInfo.no = input(prompt,'s');
    else
        break;
    end
end
today_date = datestr(now, 30);

% hide a cursor point
HideCursor;
ListenChar(2);
myKeyCheck;

if demoMode
    useEyelink = false;     % eyelink
else
    useEyelink = true;     % eyelink
end

% set KeyInfo
% escapeKey = KbName('q');
% spaceKey = KbName('space');
% % returnKey = KbName('return');
% returnKey = KbName('a');
cfg.KEYNAME = [];
cfg.KEYNAME.escapeKey = KbName('q');
cfg.KEYNAME.returnKey = KbName('a');
cfg.KEYNAME.NumKey4 = KbName('4');
cfg.KEYNAME.NumKey6 = KbName('6');

% set screen number
screens=Screen('Screens');
screenNumber=max(screens);
% screenNumber=1;

% making main screen and off screen window
[win, rect] = Screen('OpenWindow',screenNumber, cfg.BGCOLOR);
% , [50, 50, 1000, 600]
[centerX, centerY] = RectCenter(rect);
cfg.rect = [centerX centerY];

%% eyelink on/off: 1 or 2
if useEyelink
    eyelinkSetup();
    edfFile = [cfg.participantsInfo.name '.edf']; % open file to record data to
    status = Eyelink('Openfile', edfFile);
    if status ~= 0
        Screen('CloseAll');
        Screen('ClearAll');
        ListenChar(0);
        sca;
        return
    end
    EyelinkCalibration();
    Initialization();
end