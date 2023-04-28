%% Initialization

clear
clc
close all

addpath('./functions/');
constants_initialization;

%% Extract topics from bag file and compute the metric

experiments_data_file = pwd + "/../experiments_data_v2.csv";

opts = detectImportOptions(experiments_data_file);
experiments_data = readtable(experiments_data_file, opts);

experiments_data.slope = categorical(experiments_data.slope);
experiments_data.Environment = categorical(experiments_data.Environment);
experiments_data.TestBench = categorical(experiments_data.TestBench);
experiments_data.Speed = categorical(experiments_data.Speed);

% experiments_data.slope = categorical(experiments_data.slope);

experiments_data.kpi(1) = struct("CoT", NaN, "CoT_1", NaN, "Dev_y", NaN, "Slippage", NaN);

bag_path = pwd + "/../bags/";
up_down = "full";

% Input parameters

all_files = dir(fullfile(bag_path));
all_files([all_files.isdir]) = [];  % remove directories

bag_files = [];

for i = 1:length(all_files)
    bag_file = char(all_files(i).name);

    index = find(contains(experiments_data.Bagfile, bag_file(1:12)));

    if contains(experiments_data.Notes(index), "NOPROCESS") == 1
        continue
    end


    % If the bag name is not in the experiments_data csv it must be
    % discarded.
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

% Load constants

norm_speed = {};
kpi = {};

fprintf("The total number of files is %d.\n", n_bag_files)

parpool(3)

w = waitbar(0,'Please wait ...');

% Create DataQueue and listener
D = parallel.pool.DataQueue;
afterEach(D,@parforWaitbar);

parforWaitbar(w,n_bag_files)

parfor i = 1:n_bag_files
    fprintf("Running the %d-th iteration...\n", i)

    try
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
        
        [time_battery, battery_SoC, battery_V, battery_C] = compute_battery_status(batteryStructs, ...
            t_start, t_end);
        
        %% Getting robot state variables
        [pos_body, ori_body, vel_body, joint_positions, joint_velocities, joint_accelerations, ...
            joint_torques, time, t_start, t_end, lim_start, lim_end] = compute_robot_state(stateStructs, ...
            navStructs, 0, up_down);
        
        %% Getting experiment navigation results
        mission_status = compute_mission_status(navStructs);

        slippage_metric = compute_slippage(stateStructs, lim_start, lim_end);
        
        %% Find odom to map transforms
        Todom2map = get_transforms(tfStructs, 'odom', 'map', length(pos_body), ...
            t_start, t_end);
        
        %% Get battery state of charge
        [time_battery, battery_SoC, battery_V, battery_C] = compute_battery_status(batteryStructs, ...
            t_start, t_end);
        
        %% Get motor current
        % Example only for one motor (copy/paste for others)
        [motorCurrent, time_i] = compute_motor_current(mcurrStructs, t_start, t_end);
        
        %% Trasforming positions and velocities from odom into map
        pos_base = transform_data(pos_body, Todom2map);
        ori_base = ori_body;
        vel_base = vel_body;            % Velocity seems to be in base frame
        
        %% Converting orientation into RPY
        rpy = quat2eul(ori_base);
        rpy = unwrap(rpy);

        % Success (To be computed by hand "mission_status" from two bags of and
        % experiment)

        kpi_local = struct("CoT", NaN, "CoT_1", NaN, "Dev_y", NaN, "Slippage", NaN);

        % Normalized Velocity
        speed = arrayfun(@(ROWIDX) norm(vel_base(ROWIDX,:)), (1:size(vel_base,1)).');
        norm_speed{i} = speed./sqrt(g*h_R);
        % norm_speed_avg = mean(norm_speed{i});

        % Cost of Transport
        Energy = batt_E*(battery_SoC(1) - battery_SoC(end));
        distance = sum(sqrt(sum(diff(pos_base).^2')));
        kpi_local.CoT = Energy/(mass_R*g*distance);

        % Alternative CoT (Using Mechanical Energy)
        Energy_1 = trapz(dot(joint_torques,joint_velocities,2));
        kpi_local.CoT_1 = Energy_1/(mass_R*g*distance);

        % Deviation Index
        int_Dev_y = trapz(abs(pos_base(:,2)));
        kpi_local.Dev_y = (h_CoM/h_R)*(1/w_R)*int_Dev_y;

        % Slippage
        kpi_local.Slippage = slippage_metric;

        kpi{i} = kpi_local;
    catch e
        fprintf("At the %d-th iteration there was an error in processing the data.\n" + ...
            "The bag that failed is: " + bag_files(i) + "\n" + ...
            "The kpi are filled with NaN.\n", i);

        fprintf(1,'The identifier was:\n%s',e.identifier);
        fprintf(1,'There was an error! The message was:\n%s\n\n',e.message);

        norm_speed{i} = NaN;
        kpi_local = struct("CoT", NaN, "CoT_1", NaN, "Dev_y", NaN, "Slippage", NaN);
    end

    send(D,[]);
end

delete(w);


%%

for i = 1:n_bag_files
    bag_file = char(bag_files(i));

    index = find(contains(experiments_data.Bagfile, bag_file(1:12)));

    experiments_data.kpi(index) = kpi{i};
end

% Delete all the rows that are NOPROCESS.
experiments_data(contains(experiments_data.Notes, "NOPROCESS"), :) = [];


%% 

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
