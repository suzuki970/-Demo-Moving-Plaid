clear all

%% make Stimulus Movie

frame_rate = 60;
stim_time = 1;
SCREEN_WIDTH = 1920;
SCREEN_HEIGHT = 1080;

tic
file = ['stim.avi'];
rootFolder = '/Users/yuta/Desktop/Github/-Demo-Moving-Plaid/stim/';

fileList = dir([rootFolder 'test*']);
fileList = fileList(~ismember({fileList.name}, {'.', '..','.DS_Store'}));

writerObj = VideoWriter(file);
writerObj.FrameRate = frame_rate;
writerObj.Quality = 100;
open(writerObj);


for i_frame = 1:length(fileList)
    img0 = double(imread([rootFolder fileList(i_frame).name]))./255;
    
%     img0 = double(imread(strcat('./gradation_shift/test_',num2str(i_frame)),'png'))./255;
    imshow(img0);
    frame = getframe;
    writeVideo(writerObj,frame);
end
close(writerObj);
toc
clear writerObj frame
