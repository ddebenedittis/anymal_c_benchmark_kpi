function msgStructs = extract_topic_from_bag(rosbag_file,topic_name)
% EXTRACT TOPICS FROM BAGS 
% Extracts the message structure from bag file

bag = rosbag(rosbag_file);
bSel = select(bag,'Topic',topic_name);
msgStructs = readMessages(bSel,'DataFormat','struct');

end
