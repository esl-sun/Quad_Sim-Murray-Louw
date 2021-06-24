%% Get data in a form for HAVOK or DMD to be performed
close all
Ts = 0.03;     % Desired sample time
Ts_havok = Ts;

if use_sitl_data    
    % Load data from csv into matrix (csv file created with payload_angle.py)
%     [file_name,parent_dir] = uigetfile('/home/esl/Masters/Developer/MATLAB/Quad_Sim_Murray/system_id/SITL/*.csv', 'Choose csv file to access')
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
    y_data_noise = [vel_x, angle_y];
    u_data_noise = [acc_sp_x];
    
    % Smooth data
    y_data_smooth = smoothdata(y_data_noise, 'loess', 20);
    u_data_smooth = smoothdata(u_data_noise, 'gaussian', 6);
    
    % Plot    
    figure(5)
    plot(time, y_data_smooth)
    hold on
    plot(time, y_data)
    plot(time, u_data_smooth)
    plot(time, u_data)    
    hold off
    title('Data noisy vs smooth')
    xlim([321.6674  328.8901])
    ylim([-4.4410    6.5628])
    
    %% Create timeseries
    y_data = timeseries(y_data_smooth, time);
    u_data = timeseries(u_data_smooth, time);    
    
    %% Plot
    
%     vel_x_smooth = smoothdata(vel_x, 'loess', 20);
%     
%     figure(1)
%     plot(time, vel_x_smooth)
%     hold on
%     plot(time, vel_x)
%     hold off
%     legend('noisy', 'smooth')
%     
%     plot(time, angle_y.*(180/pi))
    
else
    % Extract data from .mat file saved from Simulink run
    simulation_data_file = 'PID_X_smoothed_no_noise_payload_2';

    load([uav_name, '/data/', simulation_data_file, '.mat']) % Load simulation data

    % Adjust for constant disturbance / mean control values
    % u_bar = mean(out.u.Data,1); % Input needed to keep at a fixed point
    % out.u.Data  = out.u.Data - u_bar; % Adjust for unmeasured input
    
    % Get data used for HAVOK
    y_data = out.y;
    u_data = out.u;
end

time_offset = 100;
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

figure
plot(t_train, y_train)
hold on
plot(t_train, u_train)
hold off
title('Training data')









