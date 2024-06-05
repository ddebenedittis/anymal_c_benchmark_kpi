%% Trial Script to Plot Data

%% Cut in time
t_f = 40;
[~, i_f] = min(abs(time-t_f));
[~, i_f_i] = min(abs(time_i-t_f));
[~, i_f_b] = min(abs(time_battery-t_f));


%% 1) Robot Position and Orientation
figure
hold on
plot(time(1:i_f),pos_base(1:i_f,1),...
    time(1:i_f),pos_base(1:i_f,2),...
    time(1:i_f),pos_base(1:i_f,3), ...
    time(1:i_f),rpy(1:i_f,1),...
    time(1:i_f),rpy(1:i_f,2),...
    time(1:i_f),rpy(1:i_f,3),'linewidth',5);
legend('$p_x$','$p_y$','$p_z$','$\phi$','$\theta$','$\psi$','FontSize',45,'Interpreter','latex')
xlabel('time [s]','FontSize',40,'Interpreter','latex');
ylabel('Base Position $[m]$ and Orientation $[rad]$','FontSize',40,'Interpreter','latex');
%title('Base Position')
ax = gca;
ax.FontSize = 30; 
ax.LineWidth = 5;
axis tight
grid on
box on
set(gcf, 'Position', get(0, 'Screensize'));
% Resize axis
InSet = get(gca, 'TightInset');
set(gca, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3), 1-InSet(2)-InSet(4)]);

%% 2) Robot Velocity
figure
hold on
plot(time(1:i_f),vel_base(1:i_f,1),...
    time(1:i_f),vel_base(1:i_f,2),...
    time(1:i_f),vel_base(1:i_f,3),'linewidth',5);
legend('$v_x$','$v_y$','$v_z$','FontSize',45,'Interpreter','latex')
xlabel('time [s]','FontSize',40,'Interpreter','latex');
ylabel('Base Velocity $[m/s]$','FontSize',40,'Interpreter','latex');
%title('Base Position')
ax = gca;
ax.FontSize = 30; 
ax.LineWidth = 5;
axis tight
grid on
box on
set(gcf, 'Position', get(0, 'Screensize'));
% Resize axis
InSet = get(gca, 'TightInset');
set(gca, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3), 1-InSet(2)-InSet(4)]);

%% 3) Joint Positions (1 Leg)
figure
hold on
plot(time(1:i_f),joint_positions(1:i_f,1),...
    time(1:i_f),joint_positions(1:i_f,2),...
    time(1:i_f),joint_positions(1:i_f,3),'linewidth',5);
legend('$q_{LF}^{HAA}$','$q_{LF}^{HFE}$','$q_{LF}^{KFE}$','FontSize',45,'Interpreter','latex')
xlabel('time [s]','FontSize',40,'Interpreter','latex');
ylabel('Joint Positions - LF Leg $[rad]$','FontSize',40,'Interpreter','latex');
%title('Base Position')
ax = gca;
ax.FontSize = 30; 
ax.LineWidth = 5;
axis tight
grid on
box on
set(gcf, 'Position', get(0, 'Screensize'));
% Resize axis
InSet = get(gca, 'TightInset');
set(gca, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3), 1-InSet(2)-InSet(4)]);

%% 4) Joint Velocities (1 Leg)
figure
hold on
plot(time(1:i_f),joint_velocities(1:i_f,1),...
    time(1:i_f),joint_velocities(1:i_f,2),...
    time(1:i_f),joint_velocities(1:i_f,3),'linewidth',5);
legend('$\dot q_{LF}^{HAA}$','$\dot q_{LF}^{HFE}$','$\dot q_{LF}^{KFE}$','FontSize',45,'Interpreter','latex')
xlabel('time [s]','FontSize',40,'Interpreter','latex');
ylabel('Joint Velocities - LF Leg $[rad/s]$','FontSize',40,'Interpreter','latex');
%title('Base Position')
ax = gca;
ax.FontSize = 30; 
ax.LineWidth = 5;
axis tight
grid on
box on
set(gcf, 'Position', get(0, 'Screensize'));
% Resize axis
InSet = get(gca, 'TightInset');
set(gca, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3), 1-InSet(2)-InSet(4)]);

%% 5) Joint Torques (1 Leg)
figure
hold on
plot(time(1:i_f),joint_torques(1:i_f,1),...
    time(1:i_f),joint_torques(1:i_f,2),...
    time(1:i_f),joint_torques(1:i_f,3),'linewidth',5);
legend('$\tau_{LF}^{HAA}$','$\tau_{LF}^{HFE}$','$\tau_{LF}^{KFE}$','FontSize',45,'Interpreter','latex')
xlabel('time [s]','FontSize',40,'Interpreter','latex');
ylabel('Joint Torques - LF Leg $[rad/s]$','FontSize',40,'Interpreter','latex');
%title('Base Position')
ax = gca;
ax.FontSize = 30; 
ax.LineWidth = 5;
axis tight
grid on
box on
set(gcf, 'Position', get(0, 'Screensize'));
% Resize axis
InSet = get(gca, 'TightInset');
set(gca, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3), 1-InSet(2)-InSet(4)]);

%% 6) Motor Current (1 Leg, 1 Joint)
figure
hold on
plot(time_i(1:i_f_i),motorCurrent(1:i_f_i,1),'linewidth',5);
legend('$i_{LF}^{HAA}$','FontSize',45,'Interpreter','latex')
xlabel('time [s]','FontSize',40,'Interpreter','latex');
ylabel('Motor Current - LF Leg, HAA Joint $[A]$','FontSize',40,'Interpreter','latex');
%title('Base Position')
ax = gca;
ax.FontSize = 30; 
ax.LineWidth = 5;
axis tight
grid on
box on
set(gcf, 'Position', get(0, 'Screensize'));
% Resize axis
InSet = get(gca, 'TightInset');
set(gca, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3), 1-InSet(2)-InSet(4)]);

%% 7) Battery Voltage and Current
figure
hold on
plot(time_battery(1:i_f_b),battery_V(1:i_f_b,1),...
    time_battery(1:i_f_b),battery_C(1:i_f_b,1),'linewidth',5);
legend('$V_{battery}$', '$i_{battery}$', 'FontSize',45,'Interpreter','latex')
xlabel('time [s]','FontSize',40,'Interpreter','latex');
ylabel('Battery Voltage $[V]$ and Current $[A]$','FontSize',40,'Interpreter','latex');
%title('Base Position')
ax = gca;
ax.FontSize = 30; 
ax.LineWidth = 5;
axis tight
grid on
box on
set(gcf, 'Position', get(0, 'Screensize'));
% Resize axis
InSet = get(gca, 'TightInset');
set(gca, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3), 1-InSet(2)-InSet(4)]);

%% 8) Battery SoC
figure
hold on
plot(time_battery(1:i_f_b),battery_SoC(1:i_f_b,1).*100,'linewidth',5);
legend('$SoC$', 'FontSize',45,'Interpreter','latex')
xlabel('time [s]','FontSize',40,'Interpreter','latex');
ylabel('Battery State of Charge $[\%]$','FontSize',40,'Interpreter','latex');
%title('Base Position')
ax = gca;
ax.FontSize = 30; 
ax.LineWidth = 5;
axis tight
grid on
box on
set(gcf, 'Position', get(0, 'Screensize'));
% Resize axis
InSet = get(gca, 'TightInset');
set(gca, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3), 1-InSet(2)-InSet(4)]);
