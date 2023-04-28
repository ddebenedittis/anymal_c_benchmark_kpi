function [motorCurrent, time_i] = compute_motor_current(mcurrStructs, t_start, t_end)
% COMPUTE MOTOR CURRENT
% Compute the motor current
%
% mcurrStructs - contains result of 
%       extract_topic_from_bag(file_path,'/log/state/current/...')

% Motor Current
motorCurrent = cellfun(@(m) double(m.Value),mcurrStructs);

% Get time vector
time_i = cellfun(@(m) double(m.Header.Stamp.Sec) + double(m.Header.Stamp.Nsec)*1e-9, ...
    mcurrStructs);

% Find trimming indexes (different from others since different pub rate)
[i_start, i_end, i_mid] = trim_in_time(mcurrStructs, 5e-1, t_start, t_end);

% Split
if ~exist('t_end','var')
else
    motorCurrent = motorCurrent(1:i_end,:);
    time_i = time_i(1:i_end,:);
end

if ~exist('t_start','var')
else
    motorCurrent = motorCurrent(i_start:end,:);
    time_i = time_i(i_start:end,:);
end

% Refactor time from 0 to end
time_i = time_i - time_i(1);

end

