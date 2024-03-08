%% Initialization
clear all;
close all;
clc;

%% Params
exgi_threshold = 10;
dim_cluster = 30;

%% Process video
video_path = './vid/input.mp4';
output_video_path = './vid/output';

video_reader = VideoReader(video_path);
video_writer = VideoWriter(output_video_path);
open(video_writer);

while hasFrame(video_reader)
    frame = readFrame(video_reader);
    
    matrix_exgi = 2*double(frame(:,:,2)) - (double(frame(:,:,1))+double(frame(:,:,3))) - exgi_threshold;
    matrix_boolean = min(1,max(0,matrix_exgi));
    
    veg_cover = bwareaopen(matrix_boolean,dim_cluster);
    veg_cover = double(veg_cover);
    
    writeVideo(video_writer, veg_cover);
end

close(video_writer);
