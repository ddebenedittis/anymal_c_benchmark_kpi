%% Instructions



%% Initialization

clear all;
close all;
clc;

%% Params

exgi_threshold = 12;

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

%% Process photos

extensions = ["jpg", "JPG", "png", "PNG"];

if ~exist('results', 'dir')
    mkdir('results')
end

for extension = extensions
    all_images = dir(fullfile('./img/**/*.' + extension));
    
    for i = 1:length(all_images)
        img_name = all_images(i).name;
        img_dir = all_images(i).folder;
        handle = imread(fullfile(img_dir, img_name));
        
        % veg_cover = bwareaopen((handle(:,:,2)>min_green)&(handle(:,:,2)<max_green)&(handle(:,:,3)<max_blue)&(handle(:,:,1)<max_red),dim_cluster);
        % matrix_boolean = double(zeros(size(squeeze(handle(:,:,1)))));

        matrix_exgi = 2*double(squeeze(handle(:,:,2))) - (double(squeeze(handle(:,:,1)))+double(squeeze(handle(:,:,3)))) - exgi_threshold; % EXGI 2*G-(R+B)
        matrix_boolean = min(1,max(0,matrix_exgi));
        
        veg_cover = bwareaopen(matrix_boolean,dim_cluster);
        veg_cover_handle = imshow(veg_cover, 'Border','tight');  

        processed_img_path = fullfile(img_dir, strcat(img_name(1:end-4), '_cover.', extension));

        saveas(veg_cover_handle, processed_img_path, lower(extension));

        perc_list(i) = sum(sum(veg_cover))/(size(veg_cover,1)*size(veg_cover,2));
        disp(perc_list)
        
        % figure;
        % imshow(handle, 'Border', 'tight');
        % figure;
        % imshow(veg_cover, 'Border', 'tight');   
        % pause
        % close all
    end
end