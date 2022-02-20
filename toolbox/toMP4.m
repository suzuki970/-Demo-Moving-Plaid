r_filename = '../stim.avi';
reader = VideoReader(r_filename); % AVI読み込み
w_filename = '../sstim.mp4';
writer = VideoWriter(w_filename, 'MPEG-4'); % MP4書き出し
% MP4のVideoWriterのプロパティを適宜変更
% Video quality
writer.Quality = 100; % 0から100の数値を指定
% Rate of video playback
writer.FrameRate = reader.FrameRate; % または正数値を指定
% Open the file for writing
open(writer)
% Convert AVI frame to MP4
while hasFrame(reader)
  img = readFrame(reader);
  writeVideo(writer, img);
end
close(writer);