if useEyelink
    Eyelink('Message', 'Fixation');
end

Screen('CopyWindow', window_s(5),win);

Screen('Flip', win,0,1);

tic
while toc < cfg.TIME_FIXATION
    if useEyelink
        getDataEyelink();
        %         addpoints(h,RawData(data_index-1).time,RawData(data_index-1).pa);
        %         drawnow
    end
end

if useEyelink
    TrialRawData{1,1} = RawData;
    Initialization();
end