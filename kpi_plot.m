%% Initialization

clear
close all
clc

load('kpi_data.mat')

%% Create the folders

fn = fieldnames(experiments_data.kpi);

for i = 1:length(fn)
    fni = fn{i};

    [~, ~] = mkdir("plots/" + string(fni));
end

%% Correct the trials number

experiments_data.Trial(1) = 1;

trial = 1;

for i = 2:size(experiments_data, 1)
    if isequal(experiments_data(i, 2:8), experiments_data(i - 1, 2:8))
        trial = trial + 1;
    else
        trial = 1;
    end

    experiments_data.Trial(i) = trial;
end

%% Save all the plots

plotComparingEnvironments(experiments_data, "stepbystep", "trekker");
plotComparingEnvironments(experiments_data, "4in1", "trekker");
plotComparingEnvironments(experiments_data, "4in1", "dynamic_gaits");

plotComparingControllers(experiments_data);

plot_cots_vs_trials(experiments_data);

%% Elaborate data

% Generate two matrices (kpi_mean and kpi_std) that are used to plot the
% KPIs and plot them.

function plotComparingEnvironments(experiments_data, testbench_name, controller_name)
    % Filter the experiments_data to select only one the given testbench
    % and controller data.

    testbench = categorical(testbench_name);
    controller = categorical(controller_name);
    
    experiments_data_filtered = experiments_data;
    
    experiments_data_filtered = experiments_data_filtered(experiments_data_filtered.TestBench == testbench, :);
    experiments_data_filtered = experiments_data_filtered(experiments_data_filtered.Controller == controller, :);
    
    experiments_data_filtered.Environment = removecats(experiments_data_filtered.Environment);
    experiments_data_filtered.slope = removecats(experiments_data_filtered.slope);

    %% Extract some quantities
    
    environments = categories(experiments_data_filtered.Environment);
    slopes = categories(experiments_data_filtered.slope);
    speeds = vertcat(categorical(0.3), categorical(0.8));
    
    n_env = length(environments);
    n_slo = length(slopes);
    n_spe = length(speeds);

    fud = fieldnames(experiments_data_filtered.kpi);
    n_fud = length(fud);

    % Iterate over the full, up, and down data.
    for i_fud = 1:n_fud

        %% Compute the KPIs mean and std

        kpi_mean = repmat(experiments_data_filtered.kpi(1).(fud{i_fud}), n_slo, n_env * n_spe);
        kpi_std = repmat(experiments_data_filtered.kpi(1).(fud{i_fud}), n_slo, n_env * n_spe);
    
        fn = fieldnames(experiments_data_filtered.kpi(1).(fud{i_fud}));
        n_fields = length(fn);
    
        % Extract the data from the table and convert it to an array for
        % easier plotting.
        for i_env = 1:n_env
            for i_slo = 1:n_slo
                for i_spe = 1:n_spe
                    idx = experiments_data_filtered.Environment == environments(i_env) ...
                        & experiments_data_filtered.slope == slopes(i_slo) ...
                        & experiments_data_filtered.Speed == speeds(i_spe);
                    
                    data = vertcat(experiments_data_filtered.kpi(idx).(fud{i_fud}));
        
                    for i_field = 1:n_fields
                        if ~isempty(data)
                            kpi_mean(i_slo, i_env + n_env*(i_spe - 1)).(fn{i_field}) = mean(vertcat(data.(fn{i_field})));
                            kpi_std(i_slo, i_env + n_env*(i_spe - 1)).(fn{i_field}) = std(vertcat(data.(fn{i_field})));
                        else
                            kpi_mean(i_slo, i_env + n_env*(i_spe - 1)).(fn{i_field}) = NaN;
                            kpi_std(i_slo, i_env + n_env*(i_spe - 1)).(fn{i_field}) = NaN;
                        end
                    end
                end
            end
        end

        %% Plot the KPIs
    
        fig = figure('Position', get(0, 'Screensize'), 'visible','off');
        hold on
        subplot(2,2,1)
        hold on
        subplot(2,2,2)
        hold on
        subplot(2,2,3)
        hold on
        subplot(2,2,4)
        hold on
        
        colors = colororder;
        linestyles = ["-", "--", ":"];
        
        x_axs = double(string(slopes));
                
        for i_env = 1:n_env
            for i_spe = 1:n_spe
                ax = plot_kpi(x_axs, kpi_mean, kpi_std, environments, i_env, n_env, speeds, i_spe, colors, linestyles);
            end
        end

        for i = 1:4
            if ax(i).YLim(1) >= 0
                ax(i).YLim(1) = 0; % replace the lower y-axis limmit with 0 and keep the higher limit unchanged.
            end
        end
        
        figure_title = testbench_name + " - " + controller_name;
    
        sgtitle(figure_title)
    
        % set(fig, 'visible', 'on');
        % set all units inside figure to normalized so that everything is scaling accordingly
        set(findall(fig,'Units','pixels'),'Units','normalized');
        % set figure units to pixels & adjust figure size
        fig.Units = 'pixels';
        fig.OuterPosition = [0 0 1366 768];
        % define resolution figure to be saved in dpi
        res = 420;
        % recalculate figure size to be saved
        set(fig,'PaperPositionMode','manual')
        fig.PaperUnits = 'inches';
        fig.PaperPosition = [0 0 1366 768]/res;
        exportgraphics(fig, "plots/" + string(fud{i_fud}) + "/" + figure_title + ".pdf", 'ContentType', 'vector');

        close(fig)
    end
end


function plotComparingControllers(experiments_data)
    testbench = categorical("4in1");
    
    experiments_data_filtered = experiments_data;
    
    experiments_data_filtered = experiments_data_filtered(experiments_data_filtered.TestBench == testbench, :);
    
    experiments_data_filtered.Environment = removecats(experiments_data_filtered.Environment);
    experiments_data_filtered.slope = removecats(experiments_data_filtered.slope);
    
    environments = categories(experiments_data_filtered.Environment);
    
    n_env = length(environments);
    
    for i_env = 1:2
        %% Extract some quantities

        environment = environments(i_env);
    
        experiments_data_filtered_2 = experiments_data_filtered;
        
        experiments_data_filtered_2 = experiments_data_filtered_2(experiments_data_filtered_2.Environment == environment, :);
        
        experiments_data_filtered_2.Environment = removecats(experiments_data_filtered_2.Environment);
        experiments_data_filtered_2.slope = removecats(experiments_data_filtered_2.slope);
        experiments_data_filtered_2.Controller = removecats(experiments_data_filtered_2.Controller);
    
        slopes = categories(experiments_data_filtered_2.slope);
        speeds = vertcat(categorical(0.3), categorical(0.8));
        controllers = categories(experiments_data_filtered_2.Controller);
    
        n_slo = length(slopes);
        n_spe = length(speeds);
        n_con = length(controllers);

        fud = fieldnames(experiments_data_filtered_2.kpi);
        n_fud = length(fud);

        for i_fud = 1:n_fud

            %% Compute the KPIs mean and std

            kpi_mean = repmat(experiments_data_filtered_2.kpi(1).(fud{i_fud}), n_slo, n_con * n_spe);
            kpi_std = repmat(experiments_data_filtered_2.kpi(1).(fud{i_fud}), n_slo, n_con * n_spe);
        
            fn = fieldnames(experiments_data_filtered_2.kpi(1).(fud{i_fud}));
            n_fields = length(fn);
        
            for i_con = 1:n_con
                for i_slo = 1:n_slo
                    for i_spe = 1:n_spe
                        idx = experiments_data_filtered_2.Controller == controllers(i_con) ...
                            & experiments_data_filtered_2.slope == slopes(i_slo) ...
                            & experiments_data_filtered_2.Speed == speeds(i_spe);
                        
                        data = vertcat(experiments_data_filtered_2.kpi(idx).(fud{i_fud}));
            
                        for i_field = 1:n_fields
                            if length(data) ~= 0
                                kpi_mean(i_slo, i_con + n_con*(i_spe - 1)).(fn{i_field}) = mean(vertcat(data.(fn{i_field})));
                                kpi_std(i_slo, i_con + n_con*(i_spe - 1)).(fn{i_field}) = std(vertcat(data.(fn{i_field})));
                            else
                                kpi_mean(i_slo, i_con + n_con*(i_spe - 1)).(fn{i_field}) = NaN;
                                kpi_std(i_slo, i_con + n_con*(i_spe - 1)).(fn{i_field}) = NaN;
                            end
                        end
                    end
                end
            end

            %% Plot the KPIs
            
            fig = figure('Position', get(0, 'Screensize'), 'visible','off');
            hold on
            subplot(2,2,1)
            hold on
            subplot(2,2,2)
            hold on
            subplot(2,2,3)
            hold on
            subplot(2,2,4)
            hold on
            
            colors = colororder;
            linestyles = ["-", "--", ":"];
            
            x_axs = double(string(slopes));
                        
            for i_con = 1:n_con
                for i_spe = 1:n_spe
                    ax = plot_kpi(x_axs, kpi_mean, kpi_std, controllers, i_con, n_con, speeds, i_spe, colors, linestyles);
                end
            end

            for i = 1:4
                if ax(i).YLim(1) >= 0
                    ax(i).YLim(1) = 0; % replace the lower y-axis limmit with 0 and keep the higher limit unchanged.
                end
            end
    
            figure_title = "trekker vs dyn gaits - " + string(environments(i_env));
            
            sgtitle(figure_title)
    
            % set(fig, 'visible', 'on');
            % set all units inside figure to normalized so that everything is scaling accordingly
            set(findall(fig,'Units','pixels'),'Units','normalized');
            % set figure units to pixels & adjust figure size
            fig.Units = 'pixels';
            fig.OuterPosition = [0 0 1366 768];
            % define resolution figure to be saved in dpi
            res = 420;
            % recalculate figure size to be saved
            set(fig,'PaperPositionMode','manual')
            fig.PaperUnits = 'inches';
            fig.PaperPosition = [0 0 1366 768]/res;
            exportgraphics(fig, "plots/" + string(fud{i_fud}) + "/" + figure_title + ".pdf", 'ContentType', 'vector');

            close(fig)
        end
    end
end

%% Function that plots the KPIs

% Change here to change the plots.

function ax = plot_kpi(x_axs, kpi_mean, kpi_std, name_1, i_1, n_1, speeds, i_spe, colors, linestyles)
    color = colors(i_1,:);
    linestyle = linestyles(i_spe);

    ax(1) = subplot(2,2,1);
    [x, y, err] = removeNaN(x_axs, vertcat(kpi_mean(:,i_1 + n_1*(i_spe - 1)).CoT), vertcat(kpi_std(:,i_1 + n_1*(i_spe - 1)).CoT));
    errorbar(x, ...
        y, ...
        err, ...
        "Color", color, "Marker", "none", "LineStyle", linestyle, ...
        "DisplayName", string(name_1(i_1)) + " " + string(speeds(i_spe)) ...
    );
    title("Cost of Transport (Energy Usage)")
    xlabel("Inclination [deg]")
    ylabel("CoT")
    legend('Location', 'Best')

    ax(2) = subplot(2,2,3);
    [x, y, err] = removeNaN(x_axs, vertcat(kpi_mean(:,i_1 + n_1*(i_spe - 1)).CoT_1), vertcat(kpi_std(:,i_1 + n_1*(i_spe - 1)).CoT_1));
    errorbar(x, ...
        y, ...
        err, ...
        "Color", color, "Marker", "none", "LineStyle", linestyle, ...
        "DisplayName", string(name_1(i_1)) + " " + string(speeds(i_spe)) ...
    );
    title("Cost of Transport (Mechanical Energy)")
    xlabel("Inclination [deg]")
    ylabel("CoT_1")
    legend('Location', 'Best')

    ax(3) = subplot(2,2,2);
    [x, y, err] = removeNaN(x_axs, vertcat(kpi_mean(:,i_1 + n_1*(i_spe - 1)).Dev_y), vertcat(kpi_std(:,i_1 + n_1*(i_spe - 1)).Dev_y));
    errorbar(x, ...
        y, ...
        err, ...
        "Color", color, "Marker", "none", "LineStyle", linestyle, ...
        "DisplayName", string(name_1(i_1)) + " " + string(speeds(i_spe)) ...
    );
    title("Lateral Deviation")
    xlabel("Inclination [deg]")
    ylabel("Dev_y")
    legend('Location', 'Best')

    ax(4) = subplot(2,2,4);
    [x, y, err] = removeNaN(x_axs, vertcat(kpi_mean(:,i_1 + n_1*(i_spe - 1)).Slippage), vertcat(kpi_std(:,i_1 + n_1*(i_spe - 1)).Slippage));
    errorbar(x, ...
        y, ...
        err, ...
        "Color", color, "Marker", "none", "LineStyle", linestyle, ...
        "DisplayName", string(name_1(i_1)) + " " + string(speeds(i_spe)) ...
    );
    title("Slippage")
    xlabel("Inclination [deg]")
    ylabel("Slippage")
    legend('Location', 'Best')
end


%% KPI values vs the trial number

% Attempt to see if the KPI vary with the battery level (successive tests
% have a lower battery charge).

function plot_cots_vs_trials(experiments_data)
    kpi_mean = repmat(experiments_data.kpi(1).full, 3, 1);
    kpi_std = repmat(experiments_data.kpi(1).full, 3, 1);

    fn = fieldnames(experiments_data.kpi(1).full);
    n_fields = length(fn);

    for trial = 1:3
        idx = experiments_data.Trial == trial;

        data = vertcat(experiments_data.kpi(idx).full);
            
        for i_field = 1:n_fields
            kpi_mean(trial).(fn{i_field}) = mean(vertcat(data.(fn{i_field})));
            kpi_std(trial).(fn{i_field}) = std(vertcat(data.(fn{i_field})));
        end
    end

    fig = figure('Position', get(0, 'Screensize'), 'visible','off');
    hold on

    subplot(2,2,1)
    hold on
    errorbar(vertcat(kpi_mean(:).CoT), vertcat(kpi_std(:).CoT))
    title("Cost of Transport (Energy Usage)")
    xlabel("Trial")
    ylabel("CoT")

    subplot(2,2,2)
    hold on
    errorbar(vertcat(kpi_mean(:).CoT_1), vertcat(kpi_std(:).CoT_1))
    title("Cost of Transport (Mechanical Energy)")
    xlabel("Inclination [deg]")
    ylabel("CoT_1")

    subplot(2,2,3)
    hold on
    errorbar(vertcat(kpi_mean(:).Dev_y), vertcat(kpi_std(:).Dev_y))
    title("Lateral Deviation")
    xlabel("Inclination [deg]")
    ylabel("Dev_y")

    subplot(2,2,4)
    hold on
    errorbar(vertcat(kpi_mean(:).Slippage), vertcat(kpi_std(:).Slippage))
    title("Slippage")
    xlabel("Inclination [deg]")
    ylabel("Slippage")

    figure_title = "KPIs vs trial number";
            
    sgtitle(figure_title)

    % set(fig, 'visible', 'on');
    % set all units inside figure to normalized so that everything is scaling accordingly
    set(findall(fig,'Units','pixels'),'Units','normalized');
    % set figure units to pixels & adjust figure size
    fig.Units = 'pixels';
    fig.OuterPosition = [0 0 1366 768];
    % define resolution figure to be saved in dpi
    res = 420;
    % recalculate figure size to be saved
    set(fig,'PaperPositionMode','manual')
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 1366 768]/res;
    exportgraphics(fig, "plots/" + "/" + figure_title + ".pdf", 'ContentType', 'vector');

    close(fig)
end

%%

function [x, y, err] = removeNaN(x, y, err)
    % x(:) to convert to column vector

    M = [x(:), y(:), err(:)];

    R = rmmissing(M, 1);

    x = R(:,1);
    y = R(:,2);
    err = R(:,3);
end
