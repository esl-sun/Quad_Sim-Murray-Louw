%% Get data in a form for HAVOK or DMD to be performed
% close all

if use_sitl_data    
    % Load data from csv into matrix (csv file created with payload_angle.py)
    if reload_data
        [file_name,parent_dir] = uigetfile('/home/esl/Masters/Developer/MATLAB/Quad_Sim_Murray/system_id/SITL/*.csv', '[extract_data.m] Choose SITL log DATA csv file (from logger.y)')
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
    
    angle_rate.x = data(:,20); % Payload angle about x axis in local NED
    angle_rate.y = data(:,21);
    angle_rate.z = data(:,22);
        
    switch control_vel_axis
        case 'x'
            y_data_noise = [vel.x, angle.y]; % Data still noisy
            u_data_noise = [acc_sp.x];
            pos_sp_data = [pos_sp.x];
            pos_data_noise = [pos.x]; % position data not in y
        case 'xy'
            y_data_noise = [vel.x, vel.y, angle.x, angle.y];
            u_data_noise = [acc_sp.x, acc_sp.y];
            pos_sp_data = [pos_sp.x, pos_sp.z];
            pos_data_noise = [pos_x, pos.y]; % position data not in y
        otherwise
            error('Only supports control_vel_axis = x or xy')
    end
    
    % Smooth data (Tune window size till data still represented well)
    y_data_smooth = smoothdata(y_data_noise, 'loess', 20);
    u_data_smooth = smoothdata(u_data_noise, 'gaussian', 8); % Smooth u differently because of non-differentialable spikes
    pos_data_smooth = smoothdata(u_data_noise, 'loess', 20);
    % Dont need to smooth pos_sp
    
    % Plot    
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
    pos_sp_data = timeseries(pos_sp_data, time);
    pos_data = timeseries(pos_data_smooth, time);    
    
else
    % Extract data from .mat file saved from Simulink run
%     simulation_data_file = 'PID_x_payload_mp0.2_l0.5_smooth'
%     data_file = [uav_folder, '/data/', simulation_data_file, '.mat']
%     load(data_file) % Load simulation data
    
    if reload_data
        start_folder = [pwd, '/system_id/Simulink/*.mat'];
        [file_name,parent_dir] = uigetfile(start_folder, '[extract_data.m] Choose data file')
        data_path = [parent_dir, file_name];
        load(data_path)
    end
    
    load(data_path)
    
    time_offset = 10; % Time offset for where train and test time lies on data
    
    % Get data used for HAVOK
    y_data = out.y;
    u_data = out.u;
%     pos_sp_data = out.pos_sp;
%     p_data = out.pos; % position data not in y
end

% Get simulation_data_file name
simulation_data_file = file_name;

% Add latency to training data
if add_training_latency
    u_data.Time = u_data.Time - pos_control_latency;
end

% Test/Train split
T_test = 100; % [s] Time length of training data
test_time = time_offset + (0:Ts:T_test)';

data_end_time = y_data.Time(end) - 20; % Max length of data available. clip last bit.
train_time = (test_time(end):Ts:data_end_time)';

% Training data
y_train = resample(y_data, train_time );% Resample time series to desired sample time and training period  
u_train = resample(u_data, train_time );  
% pos_sp.x = resample(pos_sp_data, train_time );  
t_train = y_train.Time';
N_train = length(t_train);

y_train = y_train.Data';
u_train = u_train.Data';
% pos_sp.x = pos_sp.x.Data';

% Testing data
y_test = resample(y_data, test_time );  
u_test = resample(u_data, test_time );  
t_test = y_test.Time';
N_test = length(t_test); % Num of data samples for testing

y_test = y_test.Data';
u_test = u_test.Data';

% Remove offset / Centre input around zero
u_bar = mean(u_train, 2)
u_train = u_train - u_bar;

% Re-calculate u_bar for test data, because acc_sp offset drifts
u_bar_test = mean(u_test, 2)
u_test = u_test - u_bar_test;

% Dimentions
ny = size(y_train,1);
nu = size(u_train,1);

% Save u_bar differently for SITL and Simulink
if use_sitl_data
    u_bar_sitl = u_bar
else
    u_bar_simulink = u_bar
end

%% Plot 
figure
plot(t_train, y_train)
hold on
plot(t_train, u_train)
hold off
title('Training data')
legend('vel x', 'angle E', 'acc sp x')

figure
plot(t_test, y_test)
hold on
plot(t_test, u_test)
hold off
title('Testing data')
legend('vel x', 'angle E', 'acc sp x')








