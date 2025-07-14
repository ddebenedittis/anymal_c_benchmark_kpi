%% Instructions

% Put the images in the img folder and run the script.

%% Initialization

clear all;
close all;
clc;

%% Params

exgi_threshold = 16;

% Modified
% min_green = 100;
% max_green = 210;
% max_blue = 155;
% max_red = 155;
% dim_cluster = 200;

min_green = 110;
max_green = 255;
max_blue = 150;
max_red = 150;
dim_cluster = 30;

% % original
% min_green = 130;
% max_green = 200;
% max_blue = 155;
% max_red = 180;
% dim_cluster = 8;
% 
% % testing
% min_green = 50;
% max_green = 200;
% max_blue = 100;
% max_red = 100;
% dim_cluster = 8;

% Colours (R,G,B)
color_veg = [ 70, 158,  53];   % true vegetation (TP)
color_not = [101,  67,  33];   % true background  (TN)
color_fp  = [255, 165,   0];   % false positive   (FP) – predicted veg, GT not
color_fn  = [  0, 255, 255];   % false negative   (FN) – missed veg

%% Process photos

extensions = ["jpg", "JPG", "png", "PNG"];

if ~exist('results', 'dir')
    mkdir('results')
end

for extension = extensions
    all_images = dir(fullfile('./img/**/*.' + extension));
    
    for i = 1:length(all_images)
        if contains(all_images(i).name, 'gt')
            continue;
        end
        if contains(all_images(i).name, 'cover')
            continue;
        end

        img_name = all_images(i).name;
        img_dir = all_images(i).folder;
        handle = imread(fullfile(img_dir, img_name));

        gt_name = img_name(1:end-4) + "_gt.png";
        gt_handle = imread(fullfile(img_dir, gt_name));
        gt = gt_handle > 0;


        
        % veg_cover = bwareaopen((handle(:,:,2)>min_green)&(handle(:,:,2)<max_green)&(handle(:,:,3)<max_blue)&(handle(:,:,1)<max_red),dim_cluster);
        % matrix_boolean = double(zeros(size(squeeze(handle(:,:,1)))));

        matrix_exgi = 2*double(squeeze(handle(:,:,2))) - (double(squeeze(handle(:,:,1)))+double(squeeze(handle(:,:,3)))) - exgi_threshold; % EXGI 2*G-(R+B)
        matrix_boolean = min(1,max(0,matrix_exgi));

        % ---------- confusion components ----------
        TP =  matrix_boolean &  gt;
        TN = ~matrix_boolean & ~gt;
        FP =  matrix_boolean & ~gt;
        FN = ~matrix_boolean &  gt;
        
        veg_cover_boolean = bwareaopen(matrix_boolean, dim_cluster);

        perc_list(i) = sum(sum(veg_cover_boolean))/(size(veg_cover_boolean,1)*size(veg_cover_boolean,2));
        disp(perc_list)

        % ---------- colour overlay ----------
        veg_cover_colored = zeros(size(handle), "uint8");
        for c = 1:3
            veg_cover_colored(:,:,c) = uint8(TN)*color_not(c) ...
                       + uint8(TP)*color_veg(c) ...
                       + uint8(FP)*color_fp(c) ...
                       + uint8(FN)*color_fn(c);
        end

        % veg_cover_colored(:,:,1) = color_not(1) + uint8(veg_cover_boolean * (color_veg(1) - color_not(1)));
        % veg_cover_colored(:,:,2) = color_not(2) + uint8(veg_cover_boolean * (color_veg(2) - color_not(2)));
        % veg_cover_colored(:,:,3) = color_not(3) + uint8(veg_cover_boolean * (color_veg(3) - color_not(3)));
        
        text_str = ['Cover: ' num2str(perc_list(i) * 100, '%0.2f') '%'];
        gt_text_str = ['Annotated Cover: ' num2str(sum(sum(gt)) / numel(gt) * 100, '%0.2f') '%'];
        position = [0 0];
        gt_position = [205 0];
        box_color = {"black"};
        veg_cover_colored = insertText(veg_cover_colored,position,text_str,FontSize=24,TextBoxColor=box_color, ...
            BoxOpacity=0.4,TextColor="white");
        veg_cover_colored = insertText(veg_cover_colored,gt_position,gt_text_str,FontSize=24,TextBoxColor=box_color, ...
            BoxOpacity=0.4,TextColor="white");

        res_dir = img_dir;
        processed_img_path = fullfile(res_dir, strcat(img_name(1:end-4), '_cover.', extension));

        imwrite(veg_cover_colored, processed_img_path);
        
        % figure;
        % imshow(handle, 'Border', 'tight');
        % figure;
        % imshow(veg_cover, 'Border', 'tight');   
        % pause
        % close all
    end
end