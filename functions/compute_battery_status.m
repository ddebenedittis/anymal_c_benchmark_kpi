function [time_battery, battery_SoC, battery_V, battery_C] = compute_battery_status(batteryStructs, ...
    t_start, t_end)
% COMPUTE BATTERY STATUS
% Compute the battery SoC, Voltage, and Current.
%
% batteryStructs - contains result of 
%       extract_topic_from_bag(file_path,'/pdb/battery_state');

% Time
time_battery = cellfun(@(m) double(m.Header.Stamp.Sec) + double(m.Header.Stamp.Nsec)*1e-9, ...
    batteryStructs);

% Battery status
battery_SoC = cellfun(@(m) double(m.Percentage),batteryStructs);

% Battery voltage
battery_V = cellfun(@(m) double(m.Voltage),batteryStructs);

% Battery voltage
battery_C = cellfun(@(m) double(m.Current),batteryStructs);

% Find trimming indexes (different from others since different pub rate)
[i_start, i_end, ~] = trim_in_time(batteryStructs, 1e-1, t_start, t_end);

% Split
if ~exist('t_end','var')
else
    time_battery = time_battery(1:i_end,:);
    battery_SoC = battery_SoC(1:i_end,:);
    battery_V = battery_V(1:i_end,:);
    battery_C = battery_C(1:i_end,:);
end

if ~exist('t_start','var')
else
    time_battery = time_battery(i_start:end,:);
    battery_SoC = battery_SoC(i_start:end,:);
    battery_V = battery_V(i_start:end,:);
    battery_C = battery_C(i_start:end,:);
end

% Refactor time from 0 to end
time_battery = time_battery - time_battery(1);

end

