%% Trial Script to Plot Data

%% 1) Robot Position
figure
hold on
plot(time,pos_base(:,1),...
    time,pos_base(:,2),...
    time,pos_base(:,3),'linewidth',5);
legend('$p_x$','$p_y$','$p_z$','FontSize',40,'Interpreter','latex')
xlabel('time [s]','FontSize',30,'Interpreter','latex');
ylabel('Base Position $[m]$','FontSize',30,'Interpreter','latex');
%title('Base Position')
ax = gca;
ax.FontSize = 30; 
axis tight
grid on
set(gcf, 'Position', get(0, 'Screensize'));
% Resize axis
InSet = get(gca, 'TightInset');
set(gca, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3), 1-InSet(2)-InSet(4)]);

%% 2) Robot Orientation
figure
hold on
plot(time,ori_base(:,1),...
    time,ori_base(:,2),...
    time,ori_base(:,3),...
    time,ori_base(:,4),'linewidth',5);
legend('$q_x$','$q_y$','$q_z$','$q_w$','FontSize',30,'Interpreter','latex')
xlabel('time [s]','FontSize',30,'Interpreter','latex');
ylabel('Base Orientation $[rad]$','FontSize',30,'Interpreter','latex');
%title('Base Position')
ax = gca;
ax.FontSize = 30; 
axis tight
grid on
set(gcf, 'Position', get(0, 'Screensize'));
% Resize axis
InSet = get(gca, 'TightInset');
set(gca, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3), 1-InSet(2)-InSet(4)]);

%% 3) Robot Velocity
figure
hold on
plot(time,vel_base(:,1),...
    time,vel_base(:,2),...
    time,vel_base(:,3),'linewidth',5);
legend('$v_x$','$v_y$','$v_z$','FontSize',30,'Interpreter','latex')
xlabel('time [s]','FontSize',30,'Interpreter','latex');
ylabel('Base Velocity $[m/s]$','FontSize',30,'Interpreter','latex');
%title('Base Position')
ax = gca;
ax.FontSize = 30; 
axis tight
grid on
set(gcf, 'Position', get(0, 'Screensize'));
% Resize axis
InSet = get(gca, 'TightInset');
set(gca, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3), 1-InSet(2)-InSet(4)]);

%% 4) Joint Positions (1 Leg)
figure
hold on
plot(time,joint_positions(:,1),...
    time,joint_positions(:,2),...
    time,joint_positions(:,3),'linewidth',5);
legend('$q_{LF}^{HAA}$','$q_{LF}^{HFE}$','$q_{LF}^{KFE}$','FontSize',30,'Interpreter','latex')
xlabel('time [s]','FontSize',30,'Interpreter','latex');
ylabel('Joint Positions - LF Leg $[rad]$','FontSize',30,'Interpreter','latex');
%title('Base Position')
ax = gca;
ax.FontSize = 30; 
axis tight
grid on
set(gcf, 'Position', get(0, 'Screensize'));
% Resize axis
InSet = get(gca, 'TightInset');
set(gca, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3), 1-InSet(2)-InSet(4)]);

%% 5) Joint Velocities (1 Leg)
figure
hold on
plot(time,joint_velocities(:,1),...
    time,joint_velocities(:,2),...
    time,joint_velocities(:,3),'linewidth',5);
legend('$\dot q_{LF}^{HAA}$','$\dot q_{LF}^{HFE}$','$\dot q_{LF}^{KFE}$','FontSize',30,'Interpreter','latex')
xlabel('time [s]','FontSize',30,'Interpreter','latex');
ylabel('Joint Velocities - LF Leg $[rad/s]$','FontSize',30,'Interpreter','latex');
%title('Base Position')
ax = gca;
ax.FontSize = 30; 
axis tight
grid on
set(gcf, 'Position', get(0, 'Screensize'));
% Resize axis
InSet = get(gca, 'TightInset');
set(gca, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3), 1-InSet(2)-InSet(4)]);

%% 6) Joint Torques (1 Leg)
figure
hold on
plot(time,joint_torques(:,1),...
    time,joint_torques(:,2),...
    time,joint_torques(:,3),'linewidth',5);
legend('$\tau_{LF}^{HAA}$','$\tau_{LF}^{HFE}$','$\tau_{LF}^{KFE}$','FontSize',30,'Interpreter','latex')
xlabel('time [s]','FontSize',30,'Interpreter','latex');
ylabel('Joint Torques - LF Leg $[rad/s]$','FontSize',30,'Interpreter','latex');
%title('Base Position')
ax = gca;
ax.FontSize = 30; 
axis tight
grid on
set(gcf, 'Position', get(0, 'Screensize'));
% Resize axis
InSet = get(gca, 'TightInset');
set(gca, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3), 1-InSet(2)-InSet(4)]);

%% 7) Motor Current (1 Leg, 1 Joint)
figure
hold on
plot(time_i,motorCurrent(:,1),'linewidth',5);
legend('$i_{LF}^{HAA}$','FontSize',30,'Interpreter','latex')
xlabel('time [s]','FontSize',30,'Interpreter','latex');
ylabel('Motor Current - LF Leg, HAA Joint $[A]$','FontSize',30,'Interpreter','latex');
%title('Base Position')
ax = gca;
ax.FontSize = 30; 
axis tight
grid on
set(gcf, 'Position', get(0, 'Screensize'));
% Resize axis
InSet = get(gca, 'TightInset');
set(gca, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3), 1-InSet(2)-InSet(4)]);

%% 8) Battery Percentage
figure
hold on
plot(time_battery,battery_SoC(:,1).*100,'linewidth',5);
legend('$SoC$','FontSize',30,'Interpreter','latex')
xlabel('time [s]','FontSize',30,'Interpreter','latex');
ylabel('Battery State of Charge $[\%]$','FontSize',30,'Interpreter','latex');
%title('Base Position')
ax = gca;
ax.FontSize = 30; 
axis tight
grid on
set(gcf, 'Position', get(0, 'Screensize'));
% Resize axis
InSet = get(gca, 'TightInset');
set(gca, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3), 1-InSet(2)-InSet(4)]);

%% 9) Battery Voltage
figure
hold on
plot(time_battery,battery_V(:,1),'linewidth',5);
legend('$V_{battery}$','FontSize',30,'Interpreter','latex')
xlabel('time [s]','FontSize',30,'Interpreter','latex');
ylabel('Battery Voltage $[V]$','FontSize',30,'Interpreter','latex');
%title('Base Position')
ax = gca;
ax.FontSize = 30; 
axis tight
grid on
set(gcf, 'Position', get(0, 'Screensize'));
% Resize axis
InSet = get(gca, 'TightInset');
set(gca, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3), 1-InSet(2)-InSet(4)]);

%% 10) Battery Voltage
figure
hold on
plot(time_battery,battery_C(:,1),'linewidth',5);
legend('$i_{battery}$','FontSize',30,'Interpreter','latex')
xlabel('time [s]','FontSize',30,'Interpreter','latex');
ylabel('Battery Current $[A]$','FontSize',30,'Interpreter','latex');
%title('Base Position')
ax = gca;
ax.FontSize = 30; 
axis tight
grid on
set(gcf, 'Position', get(0, 'Screensize'));
% Resize axis
InSet = get(gca, 'TightInset');
set(gca, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3), 1-InSet(2)-InSet(4)]);