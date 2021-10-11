%% Plot results from HITL

%% Load data from csv into matrix (csv file created with payload_angle.py)
chapter = 'results';
sim_type = 'HITL';
reload_data = 1;

if reload_data
    [file_name,parent_dir] = uigetfile([getenv('HOME'), '/Masters/Developer/MATLAB/Quad_Sim_Murray/system_id/HITL/iris/data/*.csv'], 'Choose MPC HITL log DATA csv file')
    data_path = strcat(parent_dir, file_name);
    data = readmatrix(data_path);
end
file_name_mpc = file_name;

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

%% Group data
mpc_data = [time, vel.x, angle.y, acc_sp.x, vel_sp.x];
y_data_noise = [vel.x, angle.y]; % Data still noisy
u_data_noise = [acc_sp.x];
vel_sp_data = [vel_sp.x];

%% Get PID data
if reload_data
    [file_name,parent_dir] = uigetfile([getenv('HOME'), '/Masters/Developer/MATLAB/Quad_Sim_Murray/system_id/HITL/iris/data/*.csv'], 'Choose PID HITL log DATA csv file')
    data_path = strcat(parent_dir, file_name);
    data = readmatrix(data_path);
end
file_name_pid = file_name;

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

%% Group data
pid_data = [time, vel.x, angle.y, acc_sp.x, vel_sp.x];

%% Plot 
% figure
plot(pid_data(:,1), pid_data(:,2))
hold on
plot(mpc_data(:,1), mpc_data(:,2))
hold off
legend('pid', 'mpc')

title(['PID vs MPC', file_name])
close all

%% Get horizontal offset
% pid_vs_mpc_offset = ginput(2)
% time_offset = pid_vs_mpc_offset(2,1) - pid_vs_mpc_offset(1,1)
pid_data(:,1) = pid_data(:,1) - time_offset;

%% Plot 
% figure
plot(pid_data(:,1), pid_data(:,2))
hold on
plot(mpc_data(:,1), mpc_data(:,2))
plot(pid_data(:,1), pid_data(:,5))
hold off
legend('pid', 'mpc')

title(['PID vs MPC', file_name])

%% Export to CSV for thesis plot
VariableTypes = {'double',  'double',   'double',   'double',   'double'};
VariableNames = {'time',    'vel.x',    'angle.y',  'acc_sp.x', 'vel_sp.x'};

% MPC
csv_filename = [getenv('HOME'), '/Masters/Thesis/', chapter, '/csv/', 'HITL_step_MPC_', sim_type, '_', file_name_mpc, '.csv'];
csv_filename
csv_matrix = mpc_data;
csv_table = table('Size',size(csv_matrix),'VariableTypes',VariableTypes,'VariableNames',VariableNames);
csv_table(:,:) = array2table(csv_matrix);
writetable(csv_table,csv_filename)


% PID
csv_filename = [getenv('HOME'), '/Masters/Thesis/', chapter, '/csv/', 'HITL_step_PID_', sim_type, '_', file_name_pid, '.csv'];
csv_filename
csv_matrix = pid_data;
csv_table = table('Size',size(csv_matrix),'VariableTypes',VariableTypes,'VariableNames',VariableNames);
csv_table(:,:) = array2table(csv_matrix);
writetable(csv_table,csv_filename)










  