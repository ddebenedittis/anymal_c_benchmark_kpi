%% Initialization

clear
clc
close all force

addpath('./functions/');

%% Load A Bag

bag_path = "./bags/MVI_6081_2024-01-11-14-44-59.bag";

statesStruct = extract_topic_from_bag(bag_path, '/state_estimator/anymal_state');

time = cellfun(@(m) double(m.Header.Stamp.Sec) + double(m.Header.Stamp.Nsec)*1e-9, ...
    statesStruct);
t_start = time(1);
t_end = time(end);

% Base Velocity
dx_body = cellfun(@(m) double(m.Twist.Twist.Linear.X), statesStruct);
dy_body = cellfun(@(m) double(m.Twist.Twist.Linear.Y), statesStruct);
dz_body = cellfun(@(m) double(m.Twist.Twist.Linear.Z), statesStruct);
vel_body = [dx_body, dy_body, dz_body];

%% Waypoints
% Find the times at which the waypoints are reached.

bag = rosbag(bag_path);

nav2goal = readMessages(...
    select(bag, 'Topic', '/path_planning_and_following/navigate_to_goal/result'), ...
    'DataFormat', 'struct');

nav2goal_times = cellfun(@(m) double(m.Header.Stamp.Sec) + double(m.Header.Stamp.Nsec)*1e-9, ...
    nav2goal) - t_start;

for i = 1:length(nav2goal_times)-1
    parts{i} = all([time - t_start > nav2goal_times(i), time - t_start < nav2goal_times(i+1)]');
end

%% Contacts

contacts = zeros(length(time), 4);

for i = 1:length(time)
    contacts(i,:) = cellfun(@(m) m, {statesStruct{i,1}.Contacts.State});
end

step = zeros(length(time), 1);

for i = 2:length(time)
    step(i,:) = ~isequal(contacts(i,:), contacts(i-1,:));
end

%% Plot

close all

fs = 100;
[b,a] = butter(4, 0.005);

filtered_vel_body = [
    filtfilt(b, a, dx_body), filtfilt(b, a, dy_body), filtfilt(b, a, dz_body)
];

dt = mean(diff(time));
acc_body_x = gradient(filtered_vel_body(:,1), dt);

for i = 1:2

    f = figure();
    hold on
    grid on
    
    yyaxis left
    plot(time(parts{i})-t_start, vel_body(parts{i},1), 'DisplayName', 'Unfiltered');
    plot(time(parts{i})-t_start, filtered_vel_body(parts{i},1), ':', ...
        'LineWidth', 3, 'DisplayName', 'Filtered');
    ylabel('Robot Velocity [m/s]');
    ylim([-0.5, 0.5]);
    
    yyaxis right
    plot(time(parts{i})-t_start, acc_body_x(parts{i}), 'DisplayName', 'Acceleration');
    ylabel('Robot Acceleration [m/s^2]');
    ylim([-0.5, 0.5]);
    
    lgd = legend;
    xlabel('Time [s]');

    exportgraphics(f,'f'+string(i)+'.pdf','BackgroundColor','none')

    time_i_start = time(parts{i});
    time_i_start = time_i_start(1);
    tim = time(parts{i});
    acc = acc_body_x(parts{i});
    if i == 1
        idx = find(acc(10:end) < 0, 1, 'first');
    else
        idx = find(acc(10:end) > 0, 1, 'first');
    end
    tim = tim(idx+10);
    acc = acc(idx+10);

    disp(tim - time_i_start);
end
