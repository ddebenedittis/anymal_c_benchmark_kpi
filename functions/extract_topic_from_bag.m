function msgStructs = extract_topic_from_bag(rosbag_file, topic_name, downsampling_factor)
% EXTRACT TOPICS FROM BAGS 
% Extracts the message structure from bag file

bag = rosbag(rosbag_file);
bSel = select(bag,'Topic',topic_name);
if nargin == 2
    msgStructs = readMessages(bSel, 'DataFormat', 'struct');
else
    msgStructs = readMessages(bSel, 1:downsampling_factor:bSel.NumMessages, 'DataFormat', 'struct');
end

end
