%% Initialize

clc;
clear;
close all;

%% Open all images

all_images = dir(fullfile('./slip/**/*.png'));

for i = 1:length(all_images)
    img_name = all_images(i).name;
    img_dir = all_images(i).folder;
    img{i} = imread(fullfile(img_dir, img_name));
end

%% 

for i = 1:length(all_images)
    curr_d = im2double(img{i});

    if i > 1
        base_d = im2double(img{i-1});
    else
        base_d = im2double(img{2});
    end

    diff_rgb = sqrt(sum((base_d - curr_d).^2, 3));
    diff = diff_rgb > 0.2;

    red_mask = cat(3, ones(size(diff)), zeros(size(diff)), zeros(size(diff)));

    % Convert current image to double [0,1]
    img_d = im2double(img{i});

    % Alpha blending
    alpha = 0.5; % transparency factor
    img_blend = img_d;
    for c = 1:3
        img_blend(:,:,c) = img_blend(:,:,c) .* ~diff + ...
                           (img_blend(:,:,c) * (1 - alpha) + red_mask(:,:,c) * alpha) .* diff;
    end

    % Save result
    imwrite(img_blend, fullfile('slip_out/', all_images(i).name(1:end-4) + "_diff.png"))
end