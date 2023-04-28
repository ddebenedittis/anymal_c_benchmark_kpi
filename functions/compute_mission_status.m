function mission_status = compute_mission_status(navStructs)
% COMPUTE MISSION STATUS
% Compute the status of the mission goals
%
% navStructs - contains result of 
%       navStructs = extract_topic_from_bag(file_path,...
%               '/path_planning_and_following/navigate_to_goal/result');

% Mission Status
mission_status = cellfun(@(m) double(m.Result.GOALREACHED),navStructs);
end

