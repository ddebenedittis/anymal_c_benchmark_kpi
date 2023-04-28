clear
close all
clc

load('kpi_data.mat')

experiments_data.Controller = categorical(experiments_data.Controller);


%% All Plots Ammassed Together

% figure()
% 
% n = length(bag_files);
% CoT_1 = zeros([n,1]);
% Slippage = zeros([n,1]);
% Dev_y = zeros([n,1]);
% 
% for i = 1:n
%     CoT_1(i) = kpi{i}.CoT_1;
%     Slippage(i) = kpi{i}.Slippage;
%     Dev_y(i) = kpi{i}.Dev_y;
% end
% 
% subplot(3,1,1)
% plot(CoT_1, '-o')
% title('Cost Of transport')
% 
% subplot(3,1,2)
% plot(Slippage, '-o')
% title('Slippage')
% 
% subplot(3,1,3)
% plot(Dev_y, '-o')
% title('Deviation')


%% 

plotComparingEnvironments(experiments_data, "stepbystep", "trekker")
plotComparingEnvironments(experiments_data, "4in1", "trekker")
plotComparingEnvironments(experiments_data, "4in1", "dynamic_gaits")

plotComparingControllers(experiments_data)


%% Functions

function plotComparingEnvironments(experiments_data, testbench_name, controller_name)
    testbench = categorical(testbench_name);
    controller = categorical(controller_name);
    
    experiments_data_filtered = experiments_data;
    
    experiments_data_filtered = experiments_data_filtered(experiments_data_filtered.TestBench == testbench, :);
    experiments_data_filtered = experiments_data_filtered(experiments_data_filtered.Controller == controller, :);
    
    experiments_data_filtered.Environment = removecats(experiments_data_filtered.Environment);
    experiments_data_filtered.slope = removecats(experiments_data_filtered.slope);
    
    environments = categories(experiments_data_filtered.Environment);
    slopes = categories(experiments_data_filtered.slope);
    speeds = vertcat(categorical(0.3), categorical(0.8));
    
    n_env = length(environments);
    n_slo = length(slopes);
    n_spe = length(speeds);
    
    kpi_mean = repmat(experiments_data_filtered.kpi(1), n_slo, n_env * n_spe);
    kpi_std = repmat(experiments_data_filtered.kpi(1), n_slo, n_env * n_spe);
    
    fn = fieldnames(experiments_data_filtered.kpi);
    n_fields = length(fn);
    
    for i_con = 1:n_env
        for i_slo = 1:n_slo
            for i_spe = 1:n_spe
                idx = experiments_data_filtered.Environment == environments(i_con) ...
                    & experiments_data_filtered.slope == slopes(i_slo) ...
                    & experiments_data_filtered.Speed == speeds(i_spe);
                
                data = experiments_data_filtered.kpi(idx);
    
                for i_field = 1:n_fields
                    kpi_mean(i_slo, i_con + n_env*(i_spe - 1)).(fn{i_field}) = mean(vertcat(data.(fn{i_field})));
                    kpi_std(i_slo, i_con + n_env*(i_spe - 1)).(fn{i_field}) = std(vertcat(data.(fn{i_field})));
                end
            end
        end
    end
    
    fig = figure('Position', get(0, 'Screensize'));
    hold on
    subplot(3,1,1)
    hold on
    subplot(3,1,2)
    hold on
    subplot(3,1,3)
    hold on
    
    colors = colororder;
    linestyles = ["-", "--", ":"];
    
    x_axs = double(string(slopes));
    
    line_handles = {};
    
    for i_con = 1:n_env
        for i_spe = 1:n_spe
            color = colors(i_con,:);
            linestyle = linestyles(i_spe);
    
            subplot(3,1,1)
            [x, y, err] = removeNaN(x_axs, vertcat(kpi_mean(:,i_con + n_env*(i_spe - 1)).CoT_1), vertcat(kpi_std(:,i_con + n_env*(i_spe - 1)).CoT_1));
            line_handles{i_con, i_spe} = errorbar(x, ...
                y, ...
                err, ...
                "Color", color, "Marker", "none", "LineStyle", linestyle, ...
                "DisplayName", string(environments(i_con)) + " " + string(speeds(i_spe)) ...
            );
            title("Cost of Transport")
            xlabel("Inclination [deg]")
            ylabel("CoT_1")
            lgd = legend;
            ylim([0, inf]) % replace the lower y-axis limmit with 0 and keep the higher limit unchanged.
    
            subplot(3,1,2)
            [x, y, err] = removeNaN(x_axs, vertcat(kpi_mean(:,i_con + n_env*(i_spe - 1)).Dev_y), vertcat(kpi_std(:,i_con + n_env*(i_spe - 1)).Dev_y));
            line_handles{i_con, i_spe} = errorbar(x, ...
                y, ...
                err, ...
                "Color", color, "Marker", "none", "LineStyle", linestyle, ...
                "DisplayName", string(environments(i_con)) + " " + string(speeds(i_spe)) ...
            );
            title("Lateral Deviation")
            xlabel("Inclination [deg]")
            ylabel("Dev_y")
            lgd = legend;
            ylim([0, inf]) % replace the lower y-axis limmit with 0 and keep the higher limit unchanged.
    
            subplot(3,1,3)
            [x, y, err] = removeNaN(x_axs, vertcat(kpi_mean(:,i_con + n_env*(i_spe - 1)).Slippage), vertcat(kpi_std(:,i_con + n_env*(i_spe - 1)).Slippage));
            line_handles{i_con, i_spe} = errorbar(x, ...
                y, ...
                err, ...
                "Color", color, "Marker", "none", "LineStyle", linestyle, ...
                "DisplayName", string(environments(i_con)) + " " + string(speeds(i_spe)) ...
            );
            title("Slippage")
            xlabel("Inclination [deg]")
            ylabel("Slippage")
            lgd = legend;
            ylim([0, inf]) % replace the lower y-axis limmit with 0 and keep the higher limit unchanged.
        end
    end
    
    figure_title = testbench_name + " - " + controller_name;

    sgtitle(figure_title)

    exportgraphics(fig, "plots/" + figure_title + ".pdf", 'ContentType', 'vector');
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
    
        kpi_mean = repmat(experiments_data_filtered_2.kpi(1), n_slo, n_con * n_spe);
        kpi_std = repmat(experiments_data_filtered_2.kpi(1), n_slo, n_con * n_spe);
        
        fn = fieldnames(experiments_data_filtered_2.kpi);
        n_fields = length(fn);
    
        for i_con = 1:n_con
            for i_slo = 1:n_slo
                for i_spe = 1:n_spe
                    idx = experiments_data_filtered_2.Controller == controllers(i_con) ...
                        & experiments_data_filtered_2.slope == slopes(i_slo) ...
                        & experiments_data_filtered_2.Speed == speeds(i_spe);
                    
                    data = experiments_data_filtered_2.kpi(idx);
        
                    for i_field = 1:n_fields
                        kpi_mean(i_slo, i_con + n_con*(i_spe - 1)).(fn{i_field}) = mean(vertcat(data.(fn{i_field})));
                        kpi_std(i_slo, i_con + n_con*(i_spe - 1)).(fn{i_field}) = std(vertcat(data.(fn{i_field})));
                    end
                end
            end
        end
        
        fig = figure('Position', get(0, 'Screensize'));
        hold on
        subplot(3,1,1)
        hold on
        subplot(3,1,2)
        hold on
        subplot(3,1,3)
        hold on
        
        colors = colororder;
        linestyles = ["-", "--", ":"];
        
        x_axs = double(string(slopes));
        
        line_handles = {};
        
        for i_con = 1:n_con
            for i_spe = 1:n_spe
                color = colors(i_con,:);
                linestyle = linestyles(i_spe);
        
                subplot(3,1,1)
                [x, y, err] = removeNaN(x_axs, vertcat(kpi_mean(:,i_con + n_con*(i_spe - 1)).CoT_1), vertcat(kpi_std(:,i_con + n_con*(i_spe - 1)).CoT_1));
                line_handles{i_con, i_spe} = errorbar(x, ...
                    y, ...
                    err, ...
                    "Color", color, "Marker", "none", "LineStyle", linestyle, ...
                    "DisplayName", string(controllers(i_con)) + " " + string(speeds(i_spe)) ...
                );
                title("Cost of Transport")
                xlabel("Inclination [deg]")
                ylabel("CoT_1")
                lgd = legend;
                ylim([0, inf]) % replace the lower y-axis limmit with 0 and keep the higher limit unchanged.
        
                subplot(3,1,2)
                [x, y, err] = removeNaN(x_axs, vertcat(kpi_mean(:,i_con + n_con*(i_spe - 1)).Dev_y), vertcat(kpi_std(:,i_con + n_con*(i_spe - 1)).Dev_y));
                line_handles{i_con, i_spe} = errorbar(x, ...
                    y, ...
                    err, ...
                    "Color", color, "Marker", "none", "LineStyle", linestyle, ...
                    "DisplayName", string(controllers(i_con)) + " " + string(speeds(i_spe)) ...
                );
                title("Lateral Deviation")
                xlabel("Inclination [deg]")
                ylabel("Dev_y")
                lgd = legend;
                ylim([0, inf]) % replace the lower y-axis limmit with 0 and keep the higher limit unchanged.
        
                subplot(3,1,3)
                [x, y, err] = removeNaN(x_axs, vertcat(kpi_mean(:,i_con + n_con*(i_spe - 1)).Slippage), vertcat(kpi_std(:,i_con + n_con*(i_spe - 1)).Slippage));
                line_handles{i_con, i_spe} = errorbar(x, ...
                    y, ...
                    err, ...
                    "Color", color, "Marker", "none", "LineStyle", linestyle, ...
                    "DisplayName", string(controllers(i_con)) + " " + string(speeds(i_spe)) ...
                );
                title("Slippage")
                xlabel("Inclination [deg]")
                ylabel("Slippage")
                lgd = legend;
                ylim([0, inf]) % replace the lower y-axis limmit with 0 and keep the higher limit unchanged.
            end
        end

        figure_title = "trekker vs dyn gaits - " + string(environments(i_env));
        
        sgtitle(figure_title)

        exportgraphics(fig, "plots/" + figure_title + ".pdf", 'ContentType', 'vector');
    end
end

function [x, y, err] = removeNaN(x, y, err)
    % x(:) to convert to column vector

    M = [x(:), y(:), err(:)];

    R = rmmissing(M, 1);

    x = R(:,1);
    y = R(:,2);
    err = R(:,3);
end
