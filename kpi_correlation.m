load('kpi_data.mat')

%%

experiments_data_fil = experiments_data(double(experiments_data.slope)*5 <= 15, :);
plot_corr(experiments_data_fil, 'Correlation Matrix')

experiments_data_d = experiments_data(experiments_data.Controller == "dynamic_gaits", :);
experiments_data_d = experiments_data_d(double(experiments_data_d.slope)*5 <= 15, :);
plot_corr(experiments_data_d, 'Correlation Matrix - Dynamic Gait')

experiments_data_t = experiments_data(experiments_data.Controller == "trekker", :);
experiments_data_t = experiments_data_t(double(experiments_data_t.slope)*5 <= 15, :);
plot_corr(experiments_data_t, 'Correlation Matrix - Trekker')

%%

function plot_corr(tab, title_name)
    kpi = tab.kpi;
    kpi = vertcat(kpi.full);

    vars = ['Cot', 'Dev Y', 'Slip', "Spe"];
        
    % Build matrix
    mat = [[kpi.CoT]', [kpi.Dev_y]', [kpi.Slippage]', [kpi.norm_avg_speed]'];
    
    % Correlation matrix
    R = corrcoef(mat);
    
    % Plot heatmap
    figure;
    imagesc(R);
    colormap(turbo);              % better colors (try parula/turbo)
    colorbar;
    caxis([-1 1]);                % fix scale
    axis square;
    
    % Axis ticks with names
    n = size(R,1);
    set(gca, 'XTick',1:n, 'YTick',1:n, ...
             'XTickLabel',vars, 'YTickLabel',vars, ...
             'FontSize',12, 'FontWeight','bold');
    xtickangle(45);               % tilt x labels for readability
    
    % Overlay values
    for i = 1:n
        for j = 1:n
            val = R(i,j);
            if abs(val) > 0.5
                tcolor = 'w';
            else
                tcolor = 'k';
            end
            text(j,i,sprintf('%.2f',val), ...
                'HorizontalAlignment','center', ...
                'Color',tcolor, ...
                'FontWeight','bold');
        end
    end
    
    title(title_name,'FontSize',14,'FontWeight','bold');
end