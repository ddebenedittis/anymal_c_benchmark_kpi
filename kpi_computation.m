%% Initialization

clear
clc
close all force

addpath('./functions/');
constants_initialization;

%% Load the experiments csv data and manipulate it

experiments_data_file = pwd + "/../experiments_data_v2.csv";

opts = detectImportOptions(experiments_data_file);
experiments_data = readtable(experiments_data_file, opts);

% Convert some fields to categorical data type
experiments_data.slope = categorical(experiments_data.slope);
experiments_data.Environment = categorical(experiments_data.Environment);
experiments_data.TestBench = categorical(experiments_data.TestBench);
experiments_data.Speed = categorical(experiments_data.Speed);
experiments_data.Controller = categorical(experiments_data.Controller);

% Delete all the rows that are NOPROCESS.
experiments_data(contains(experiments_data.Notes, "NOPROCESS"), :) = [];

% Add a column to contain the kpi values
kpi_example.full = struct("CoT", NaN, "CoT_1", NaN, "Dev_y", NaN, "Slippage", NaN, "norm_avg_speed", NaN);
kpi_example.up = kpi_example.full;
kpi_example.down = kpi_example.full;
experiments_data.kpi(1) = kpi_example;

bag_path = pwd + "/../bags/";
up_down_flags = ["full", "up", "down"];

%% Get the bag filenames that must be processed

all_files = dir(fullfile(bag_path));
all_files([all_files.isdir]) = [];  % remove directories

bag_files = [];

for i = 1:length(all_files)
    bag_file = char(all_files(i).name);

    index = find(contains(experiments_data.Bagfile, bag_file(1:12)));

    % If the bag name is not in the experiments_data csv do not process the
    % bags.
    flag = 0;
    for j = 1:length(experiments_data.Bagfile)
        if experiments_data.Bagfile{j}(1:12) == all_files(i).name(1:12)
            flag = 1;
            break
        end
    end
    if flag == 0
        continue
    end

    bag_files = [bag_files, string(all_files(i).name)];
end

n_bag_files = length(bag_files);

%% Main processing loop

norm_speed = {};
kpi = {};

fprintf("The total number of files is %d.\n", n_bag_files)

% Remove these lines and substitute the parfor with a simple for cycle to
% avoid using the Parallel Computing Toolbox.
% Delete preexisting parpools and create a new one.
poolobj = gcp('nocreate');
delete(poolobj);
poolobj = parpool(3);

% Create a waitbar
w = waitbar(0,'Please wait ...');
D = parallel.pool.DataQueue;
afterEach(D,@parforWaitbar);
parforWaitbar(w,n_bag_files);

parfor i = 1:n_bag_files
    fprintf("Running the %d-th iteration...\n", i)

    for up_down = up_down_flags
        norm_speed{i}.(up_down) = NaN;
    end

    bag_file = bag_files(i);

    % Derived parameters
    file_path = bag_path + bag_file;

    % Extract each topic structure from bag
    stateStructs = extract_topic_from_bag(file_path,'/state_estimator/anymal_state');
    tfStructs = extract_topic_from_bag(file_path,'/tf');
    batteryStructs = extract_topic_from_bag(file_path,'/pdb/battery_state_ros');
    % Example only for one motor (copy/paste for others)
    mcurrStructs = extract_topic_from_bag(file_path,'/log/state/current/LF_HAA');
    navStructs = extract_topic_from_bag(file_path,...
        '/path_planning_and_following/navigate_to_goal/result');
    trajStructs = extract_topic_from_bag(file_path,...
        '/path_planning_and_following/trajectory_poses');
    actStructs = extract_topic_from_bag(file_path,...
        '/path_planning_and_following/active_path');
    
    time = cellfun(@(m) double(m.Header.Stamp.Sec) + double(m.Header.Stamp.Nsec)*1e-9, ...
        stateStructs);
    t_start = time(1);
    t_end = time(end);
    
    for up_down = up_down_flags
    
        % Get robot state variables
        [pos_body, ori_body, vel_body, joint_positions, joint_velocities, joint_accelerations, ...
            joint_torques, time, t_start, t_end, lim_start, lim_end] = compute_robot_state(stateStructs, ...
            navStructs, 0, up_down);
        
        % Get experiment navigation results
        mission_status = compute_mission_status(navStructs);

        slippage_metric = compute_slippage(stateStructs, lim_start, lim_end);
        
        % Find odom to map transforms
        Todom2map = get_transforms(tfStructs, 'odom', 'map', length(pos_body), ...
            t_start, t_end);
        
        % Get battery state of charge
        [time_battery, battery_SoC, battery_V, battery_C] = compute_battery_status(batteryStructs, ...
            t_start, t_end);
        
        % Get motor current
        % Example only for one motor (copy/paste for others)
        [motorCurrent, time_i] = compute_motor_current(mcurrStructs, t_start, t_end);
        
        % Trasform positions and velocities from odom into map
        pos_base = transform_data(pos_body, Todom2map);
        ori_base = ori_body;
        vel_base = vel_body;            % Velocity seems to be in base frame
        
        % Convert orientation into RPY
        rpy = quat2eul(ori_base);
        rpy = unwrap(rpy);

        % Compute the kpi

        kpi_local = struct("CoT", NaN, "CoT_1", NaN, "Dev_y", NaN, "Slippage", NaN, "norm_avg_speed", NaN);

        % Normalized Velocity
        speed = arrayfun(@(ROWIDX) norm(vel_base(ROWIDX,:)), (1:size(vel_base,1)).');
        norm_speed{i}.(up_down) = speed./sqrt(g*h_R);
        kpi_local.norm_avg_speed = mean(speed./sqrt(g*h_R));

        % Cost of Transport
        energy_consumption = batt_E*(battery_SoC(1) - battery_SoC(end));
        distance = sum(sqrt(sum(diff(pos_base).^2')));
        kpi_local.CoT = energy_consumption/(mass_R*g*distance);

        % Alternative CoT (Using Mechanical Energy)
        Energy_1 = trapz(dot(joint_torques,joint_velocities,2));
        kpi_local.CoT_1 = Energy_1/(mass_R*g*distance);

        % Deviation Index
        int_Dev_y = trapz(abs(pos_base(:,2)));
        kpi_local.Dev_y = (h_CoM/h_R)*(1/w_R)*int_Dev_y;

        % Slippage
        kpi_local.Slippage = slippage_metric;

        % Save the kpi
        kpi{i}.(up_down) = kpi_local;
    end

    send(D,[]);
end

delete(w);

delete(poolobj);

%% Save the kpi in the experiments_data table

for i = 1:n_bag_files
    bag_file = char(bag_files(i));

    index = find(contains(experiments_data.Bagfile, bag_file(1:12)));

    experiments_data.kpi(index) = kpi{i};
end

%% parforWaitbar function

function parforWaitbar(waitbarHandle,iterations)
    persistent count h N
    
    if nargin == 2
        % Initialize
        
        count = 0;
        h = waitbarHandle;
        N = iterations;
    else
        % Update the waitbar
        
        % Check whether the handle is a reference to a deleted object
        if isvalid(h)
            count = count + 1;
            waitbar(count / N,h);
        end
    end
end
