%% Plot results from HITL

%% Load data from csv into matrix (csv file created with payload_angle.py)
reload_data = 1;

if reload_data
    [file_name,parent_dir] = uigetfile([getenv('HOME'), '/Masters/Developer/MATLAB/Quad_Sim_Murray/system_id/HITL/iris/data/*.csv'], '[extract_data.m] Choose HITL log DATA csv file (from logger.py)')
    data_path = strcat(parent_dir, file_name);
    data = readmatrix(data_path);
end

time_offset = 10; % Time offset for where train and test time lies on data

time = data(:,1);
time = (time-time(1)); % Time in seconds

pos.x = data(:,2); % Local NED x position
pos.y = data(:,3);
pos.z = data(:,4);

vel.x = data(:,5); % Local NED x velocity
vel.y = data(:,6);
vel.z = data(:,7);    

pos_sp.x = data(:,8); % Local NED x position setpoint
pos_sp.y = data(:,9);
pos_sp.z = data(:,10);    

vel_sp.x = data(:,11); % Local NED x velocity setpoint
vel_sp.y = data(:,12);
vel_sp.z = data(:,13);

acc_sp.x = data(:,14); % Local NED x acceleration setpoint
acc_sp.y = data(:,15);
acc_sp.z = data(:,16);

angle.x = data(:,17); % Payload angle about x axis in local NED
angle.y = data(:,18);
angle.z = data(:,19);

simulink_acc_sp.x = data(:,20); % Local NED x acceleration setpoint commanded by simulink node
simulink_acc_sp.y = data(:,21);
simulink_acc_sp.z = data(:,22);

qp_status= data(:,23);

%% Group data
% y_data_noise = [vel.x, vel.y, vel.z]; % Data still noisy
% u_data_noise = [acc_sp.x, acc_sp.y, acc_sp.z];
% vel_sp_data = [vel_sp.x, vel_sp.y, vel_sp.z];

y_data_noise = [vel.x, angle.y]; % Data still noisy
u_data_noise = [acc_sp.x];
vel_sp_data = [vel_sp.x];

%% Plot 
figure
plot(time, y_data_noise)
hold on
plot(time, y_data_noise, '.')
plot(time, u_data_noise)
plot(time, vel_sp_data)  
plot(time, qp_status, 'r')  

hold off
ylim([-0.2 1.2])

title(['Velocity step - HITL - ', file_name])

%% Plot simulink acc_sp vs received-and_returned sp
figure
plot(time, simulink_acc_sp.y)
hold on
plot(time, acc_sp.x)
hold off
legend('simulink', 'received and returned')
title(['Simulink vs received sp - HITL - ', file_name])

%% Plot logging frequency:
figure
plot(diff(time))
title('logging sample time')
