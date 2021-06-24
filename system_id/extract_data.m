%% Get data in a form for HAVOK or DMD to be performed
close all
Ts = 0.03;     % Desired sample time
Ts_havok = Ts;

if use_sitl_data    
    % Load data from csv into matrix (csv file created with payload_angle.py)
    [file_name,parent_dir] = uigetfile('/home/esl/Masters/Developer/MATLAB/Quad_Sim_Murray/system_id/SITL/*.csv', '[extract_data.m] Choose csv file with SITL log data (from payload_angle.y)')
    data = readmatrix(strcat(parent_dir, '/', file_name));
    
    simulation_data_file = file_name;
    
    time = data(:,1);
    time = (time-time(1)); % Time in seconds
    
    vel_x = data(:,2); % Local NED x velocity
    vel_y = data(:,3);
    vel_z = data(:,4);
    
    acc_sp_x = data(:,5); % Local NED x acceleration setpoint
    acc_sp_y = data(:,6);
    acc_sp_z = data(:,7);
    
    angle_x = data(:,8); % Payload angle about x axis in local NED
    angle_y = data(:,9);
    
    % Gather data  
    %% ??? For some reason, angle_x works with x. in x direction. Should it not be angle about y axis?
    control_vel_axis = 'x' % Axis that MPC controls. 'x' or 'xy'
    switch control_vel_axis
        case 'x'
            y_data_noise = [vel_x, angle_x];
            u_data_noise = [acc_sp_x];
        case 'xy'
            y_data_noise = [vel_x, vel_y, angle_x, angle_y];
            u_data_noise = [acc_sp_x, acc_sp_y];
        otherwise
            error('Only supports control_vel_axis = x or xy')
    end
    
    % Smooth data (Tune window size till data still represented well)
    y_data_smooth = smoothdata(y_data_noise, 'loess', 20);
    u_data_smooth = smoothdata(u_data_noise, 'gaussian', 6); % Smooth u differently because of non-differentialable spikes
    
    %% Plot    
%     figure(5)
%     plot(time, y_data_smooth)
%     hold on
%     plot(time, y_data_noise)
%     plot(time, u_data_smooth)
%     plot(time, u_data_noise)    
%     hold off
%     title('Data noisy vs smooth')
%     xlim([321.6674  328.8901])
%     ylim([-4.4410    6.5628])
    
    %% Create timeseries
    y_data = timeseries(y_data_smooth, time);
    u_data = timeseries(u_data_smooth, time);    
    
else
    % Extract data from .mat file saved from Simulink run
    simulation_data_file = 'PID_X_smoothed_no_noise_payload_2';

    load([uav_folder, '/data/', simulation_data_file, '.mat']) % Load simulation data

    % Adjust for constant disturbance / mean control values
    % u_bar = mean(out.u.Data,1); % Input needed to keep at a fixed point
    % out.u.Data  = out.u.Data - u_bar; % Adjust for unmeasured input
    
    % Get data used for HAVOK
    y_data = out.y;
    u_data = out.u;
end

time_offset = 100; % Time offset for where train and test time lies on data
    
% Remove input offset

% hover_time = (0:Ts:50)+10; % Time in which uav is just hovering
% u_hover = resample(u_data, hover_time); % Data where uav is at standstill hovering
% u_bar = mean(u_hover.Data);
u_bar = mean(u_data.Data);
u_data.Data = u_data.Data - u_bar;

% Training data
train_time = time_offset+(0:Ts:200)';
y_train = resample(y_data, train_time );% Resample time series to desired sample time and training period  
u_train = resample(u_data, train_time );  
t_train = y_train.Time';
N_train = length(t_train);

y_train = y_train.Data';
u_train = u_train.Data';

% Testing data
test_time = time_offset+(200:Ts:260)';
y_test = resample(y_data, test_time );  
u_test = resample(u_data, test_time );  
t_test = y_test.Time';
N_test = length(t_test); % Num of data samples for testing

y_test = y_test.Data';
u_test = u_test.Data';

%% Plot 
% figure
% plot(t_train, y_train)
% hold on
% plot(t_train, u_train)
% hold off
% title('Training data')









