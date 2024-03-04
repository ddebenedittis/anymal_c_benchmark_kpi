function [perc_state] = compute_perc_state(stateStructs)
%COMPUTE_PERC_STATE Compute the percentage of time in which the robot state is
% error_sensor, error_estimator, unknown, ok, or state_uninitialized.

states = cellfun(@(m) double(m.State), stateStructs);

perc_state.error_sensor = sum(states == stateStructs{1}.STATEERRORSENSOR) / length(states);
perc_state.error_estimator = sum(states == stateStructs{1}.STATEERRORESTIMATOR) / length(states);
perc_state.error_unknown = sum(states == stateStructs{1}.STATEERRORUNKNOWN) / length(states);
perc_state.state_ok = sum(states == stateStructs{1}.STATEOK) / length(states);
perc_state.state_uninitialized = sum(states == stateStructs{1}.STATEUNINITIALIZED) / length(states);

end
