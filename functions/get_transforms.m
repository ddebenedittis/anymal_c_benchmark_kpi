function Todom2map = get_transforms(tfStructs, from_frame, to_frame, ...
    des_len, t_start, t_end)
% GET TRANSFORMS
% Get transforms from from_frame to to_frame
% Also interpolates and resamples to the desired length
%
% tfStructs - contains result of
%       extract_topic_from_bag(file_path,'/tf');

% Find trim indexes and trim all outputs
[i_start, i_end] = trim_tf_in_time(tfStructs, t_start, t_end);
tfStructs = tfStructs(i_start:i_end);

% Getting IDs transforms from from_frame to to_frame
ids = [];
for i = 1 : length(tfStructs)
    
    tfStruct = tfStructs{i};
    
    % Avoid trasforms between feet (those have size 12, others 1)
    if length(tfStructs{i}.Transforms) == 1
        
        % Check parent and child
        parent_frame = tfStruct.Transforms.Header.FrameId;
        child_frame = tfStruct.Transforms.ChildFrameId;
        
        % If correct one, save
        if strcmp(parent_frame, from_frame)
            if strcmp(child_frame, to_frame)
                ids = [ids, i];
            end
        end
    end
    
end

% Iterate and extract the transforms from from_frame to to_frame
translations = zeros(length(ids),3);
quaternions = zeros(length(ids),4);
for i = 1 : length(ids)
    tfStruct = tfStructs{ids(i)};
    odom2map = tfStruct.Transforms.Transform;
    translations(i,:) = [odom2map.Translation.X, odom2map.Translation.Y, odom2map.Translation.Z];
    quaternions(i,:) = [odom2map.Rotation.W, odom2map.Rotation.X, odom2map.Rotation.Y, odom2map.Rotation.Z];
end

% Resampling transation and quaternions
translations_o = translations;
quaternions_o = quaternions;
translations_r = translations;
quaternions_r = quaternions;

while length(translations_r) < des_len
    k = 1;
    for i = 1 : length(translations_o) - 1
        % Check if dimensions ok
        if length(translations_r) >= des_len
            break;
        end
        % Interpolate two adjacents and insert in between the result
        translation_int = (translations_o(i,:) + translations_o(i+1,:))./2;
        quaternion_int = slerp(quaternions_o(i,:).', quaternions_o(i+1,:).', 0.5).';
        translations_r = [translations_r(1:k,:);
            translation_int;
            translations_r(k+1:end,:)];
        quaternions_r = [quaternions_r(1:k,:);
            quaternion_int;
            quaternions_r(k+1:end,:)];
        k = k + 2;
    end
    translations_o = translations_r;
    quaternions_o = quaternions_r;
end

% Save transforms from quaternion and traslation
for i = 1 : des_len
    rotation = quat2rotm(quaternions_r(i,:));
    Todom2map_curr = [rotation, translations_r(i,:).';
        zeros(1,3), 1];
    Todom2map{i} = Todom2map_curr;
end

end

