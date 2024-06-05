%% Trial Script to Plot Data

% Position
figure
hold on
plot(time,pos_base(:,1),...
    time,pos_base(:,2),...
    time,pos_base(:,3),'linewidth',1);
legend('$p_x$','$p_y$','$p_z$','FontSize',10,'Interpreter','latex')
xlabel('time [s]','Interpreter','latex');
ylabel('Base Position $p$','Interpreter','latex');
title('Base Position')
axis tight
grid on

% Velocity
figure
hold on
plot(time,vel_base(:,1),...
    time,vel_base(:,2),...
    time,vel_base(:,3),'linewidth',1);
legend('$v_x$','$v_y$','$v_z$','FontSize',10,'Interpreter','latex')
xlabel('time [s]','Interpreter','latex');
ylabel('Base Velocity $v_b$','Interpreter','latex');
title('Base Velocity')
axis tight
grid on

% SoC
figure
hold on
plot(time_battery,battery_SoC(:,1),'linewidth',1);
legend('$SoC$','FontSize',10,'Interpreter','latex')
xlabel('time [s]','Interpreter','latex');
ylabel('State of Charge $SoC$','Interpreter','latex');
title('State of Charge')
axis tight
grid on