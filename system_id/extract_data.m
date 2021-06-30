%% Get data in a form for HAVOK or DMD to be performed
close all

if use_sitl_data    
    % Load data from csv into matrix (csv file created with payload_angle.py)
    if reload_data
        [file_name,parent_dir] = uigetfile('/home/esl/Masters/Developer/MATLAB/Quad_Sim_Murray/system_id/SITL/*.csv', '[extract_data.m] Choose csv file with SITL log data (from payload_angle.y)')
        data = readmatrix(strcat(parent_dir, '/', file_name));
    end
    
    simulation_data_file = file_name;
    
    time_offset = 0; % Time offset for where train and test time lies on data
    
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
    
    pos_sp_x = data(:,10);
    pos_sp_y = data(:,11);
    pos_sp_z = data(:,12);
    
    % Gather data  
    %% ??? For some reason, angle_x works with x. in x direction. Should it not be angle about y axis?
    
    switch control_vel_axis
        case 'x'
            y_data_noise = [vel_x, angle_y]; % Data still noisy
            u_data_noise = [acc_sp_x];
            pos_sp_data = [pos_sp_x];
%             p_data_noise = [pos_x]; % position data not in y
        case 'xy'
            y_data_noise = [vel_x, vel_y, angle_x, angle_y];
            u_data_noise = [acc_sp_x, acc_sp_y];
            pos_sp_data = [pos_sp_x, pos_sp_z];
%             p_data_noise = [pos_x, pos_y]; % position data not in y
        otherwise
            error('Only supports control_vel_axis = x or xy')
    end
    
    % Smooth data (Tune window size till data still represented well)
    y_data_smooth = smoothdata(y_data_noise, 'loess', 20);
    u_data_smooth = smoothdata(u_data_noise, 'gaussian', 6); % Smooth u differently because of non-differentialable spikes
%     p_data_smooth = smoothdata(u_data_noise, 'loess', 20); % Smooth u differently because of non-differentialable spikes
    % Dont need to smooth pos_sp
    
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
    pos_sp_data = timeseries(pos_sp_data, time);
%     p_data = timeseries(p_data_smooth, time);    
    
else
    % Extract data from .mat file saved from Simulink run
%     simulation_data_file = 'PID_x_payload_mp0.2_l0.5_smooth'
%     data_file = [uav_folder, '/data/', simulation_data_file, '.mat']
%     load(data_file) % Load simulation data
    
    if reload_data
        start_folder = [pwd, '/system_id/Simulink/*.mat'];
        [file_name,parent_dir] = uigetfile(start_folder, '[extract_data.m] Choose data file')
        data_file = [parent_dir, '/', file_name];
        load(data_file)
    end
    
    time_offset = 0; % Time offset for where train and test time lies on data
    
    % Get data used for HAVOK
    y_data = out.y;
    u_data = out.u;
    pos_sp_data = out.pos_sp;
%     p_data = out.pos; % position data not in y
end
    
% Training data
train_time = time_offset+(0:Ts:300)';
y_train = resample(y_data, train_time );% Resample time series to desired sample time and training period  
u_train = resample(u_data, train_time );  
pos_sp_train = resample(pos_sp_data, train_time );  

t_train = y_train.Time';
N_train = length(t_train);

y_train = y_train.Data';
u_train = u_train.Data';
pos_sp_train = pos_sp_train.Data';

% Testing data
test_time = time_offset+(200:Ts:260)';
y_test = resample(y_data, test_time );  
u_test = resample(u_data, test_time );  
t_test = y_test.Time';
N_test = length(t_test); % Num of data samples for testing

y_test = y_test.Data';
u_test = u_test.Data';

% Position data (not in y)
% p_test = resample(p_data, test_time );  
% p_test = p_test.Data';

% Remove offset / Centre input around zero

% hover_time = (0:Ts:50)+10; % Time in which uav is just hovering
% u_hover = resample(u_data, hover_time); % Data where uav is at standstill hovering
% u_bar = mean(u_hover.Data);
u_bar = mean(u_train, 2);
u_train = u_train - u_bar;
u_test = u_test - u_bar;

% Dimentions
ny = size(y_train,1);
nu = size(u_train,1);

%% Plot 
% figure
% plot(t_train, y_train)
% hold on
% plot(t_train, u_train)
% hold off
% title('Training data')









