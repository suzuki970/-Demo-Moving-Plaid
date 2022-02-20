if useEyelink
    Eyelink('Message', 'Fixation');
end

Screen('CopyWindow', fix,win);

[VBLTimestamp StimulusOnsetTime0 FlipTimestamp Missed Beampos] = Screen('Flip', win,0,1);
StimulusOnsetTime = 0;

tic
while StimulusOnsetTime - StimulusOnsetTime0 < cfg.TIME_FIXATION
    [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', win,0,1);    
end

if useEyelink
    TrialRawData{1,1} = RawData;
    Initialization();
end