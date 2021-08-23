%% Extract data from logged topics of practical flight data and save in format for system identification
% Before running this script, first open terminal in directory with log file
% Then run: ulog2csv log_name.ulg
% to extract each topic to its own csv file

disp('start')
close all;
clear 'vel' 'vel_sp' 'acc_sp' % also used in extract_data.m

Ts = 0.03
load_csv_again = 1;

%% Functions
quat_rot_vect = @(vect, quat) quatrotate(quatinv(quat), vect); % Rotates vector by quaternion % built in "quatrotate" rotates the coordinate frame, not the vector, therefore use inverse in function (https://www.mathworks.com/matlabcentral/answers/465053-rotation-order-of-quatrotate)

%% Load topics from csv into matrix

if load_csv_again
    current_dir = pwd;
    [ulog_name,csv_folder] = uigetfile([current_dir, '/practical_flights', '/*.ulg'], 'Choose ulog file to access') % GUI to choose ulog file. % [ulog filename, path to folder with csv files]
    ulog_name = erase(ulog_name, '.ulg'); % remove file extention

    adc_report              = readmatrix(strcat(csv_folder, ulog_name, '_', 'adc_report', '_0.csv'));
    vehicle_attitude        = readmatrix(strcat(csv_folder, ulog_name, '_', 'vehicle_attitude', '_0.csv'));
    vehicle_local_position  = readmatrix(strcat(csv_folder, ulog_name, '_', 'vehicle_local_position', '_0.csv'));
    vehicle_local_position_setpoint = readmatrix(strcat(csv_folder, ulog_name, '_', 'vehicle_local_position_setpoint', '_0.csv'));
    
    disp('Loaded csv log files')
end

%% Time matching
% have common time series so no extrapolation occurs between timeseries

adc_time = adc_report(:,1)./1e6; % Timestamp of adc_report in seconds
attitude_time = vehicle_attitude(:,1)./1e6; 
position_time = vehicle_local_position(:,1)./1e6;
setpoint_time = vehicle_local_position_setpoint(:,1)./1e6;

%% Crop data
vel    = vehicle_local_position(:, 11:13); % position of uav [x,y,z]
vel_sp    = vehicle_local_position_setpoint(:, 7:9); % position of uav [x,y,z]

if load_csv_again
    figure
    plot(setpoint_time, vel_sp);
    hold on
    plot(position_time, vel(:,1))
    hold off
    legend('vel_sp.x', 'vel_sp.y', 'vel_sp.z');
    title('Click start and finish time of usable data')

    disp('Waiting for user to click start and finish time of ussable data...')
    [useable_time,~] = ginput(2);
    close all;

    % max_time = min( [max(adc_time),   max(attitude_time),   max(position_time),   max(setpoint_time)] )
    % min_time = max( [min(adc_time),   min(attitude_time),   min(position_time),   min(setpoint_time)] )

    time = (useable_time(1):Ts:useable_time(2))'; % Use values inside overlapping range so no extrapulation

    disp("Data time cropped to useable range")
end

%% Plot logging frequency
figure
plot(adc_time(2:end), 1./diff(adc_time))
hold on
plot(attitude_time(2:end), 1./diff(attitude_time))
plot(position_time(2:end), 1./diff(position_time))
plot(setpoint_time(2:end), 1./diff(setpoint_time))
hold off
legend('adc report', 'vehicle attitude', 'vehicle local position', 'vehicle local position setpoint')
title('Logging rates')
ylabel('Log frequency [Hz]')
xlabel('Time of log')

%% Attitude
uav_quat    = vehicle_attitude(:, 2:5); % Quaternions of uav (+2 to use index)
uav_quat_ts = timeseries(uav_quat, attitude_time, 'Name', 'Attitude'); % Time series of euler angles of drone
uav_quat_ts = resample(uav_quat_ts, time, 'linear'); % Resample for matching time sequence
uav_quat    = uav_quat_ts.Data; % Data from resampled timeseries

%% Velocity   
% vel extracted earlier
vel_ts = timeseries(vel, position_time, 'Name', 'Velocity'); % Time series
vel_ts = resample(vel_ts, time, 'linear'); % Resample for matching time sequence
vel    = vel_ts.Data; % Data from resampled timeseries

%% Velocity setpoint
% vel_sp extracted earlier
vel_sp_ts = timeseries(vel_sp, setpoint_time, 'Name', 'Velocity setpoint'); % Time series
vel_sp_ts = resample(vel_sp_ts, time, 'linear'); % Resample for matching time sequence
vel_sp    = vel_sp_ts.Data; % Data from resampled timeseries

%% Acceleration setpoint
acc_sp    = vehicle_local_position_setpoint(:, 10:12); % position of uav [x,y,z]
acc_sp_ts = timeseries(acc_sp, setpoint_time, 'Name', 'Acceleration setpoint'); % Time series
acc_sp_ts = resample(acc_sp_ts, time, 'linear'); % Resample for matching time sequence
acc_sp    = acc_sp_ts.Data; % Data from resampled timeseries

%% Remove Z of uav attitude

heading = quat2heading(uav_quat);
quat_inv_heading = quatinv(eul2quat([heading, zeros(size(heading)), zeros(size(heading))])); % inverse of quat of heading 

uav_quat = quatmultiply(quat_inv_heading, uav_quat); % Remove heading

%% UAV into vector form
uav_vector  = quat_rot_vect([0 0 1], uav_quat); % unit vector representing direction of payload. Rotate neutral hanging payload by joystick angle, then attitude. % "quatrotate" rotates the coordinate frame, not the vector, therefore use inverse in function (https://www.mathworks.com/matlabcentral/answers/465053-rotation-order-of-quatrotate)
uav_vector_angle_x = -atan2(uav_vector(:,2), uav_vector(:,3)); % [radians] absolute angle of payload vector from z axis, about the x axis, projected on yz plane. NOT euler angle. negative, becasue +y gives negative rotation about x
uav_vector_angle_y =  atan2(uav_vector(:,1), uav_vector(:,3)); % [radians] absolute angle of payload vector from z axis, about the y axis, projected on xz plane. NOT euler angle

uav_vector_angles = [uav_vector_angle_x, uav_vector_angle_y]; % [radians] [x, y] absolute angle of payload vector. NOT euler angles

disp('State time series')

%% Joystick attitude

% Convertion from adc value to radians
green_pot_line_fit = [ 0.038980944549164 -37.789860132384199]; % degrees linefit for polyval from calibration of pot connected to green wire
blue_pot_line_fit  = [ 0.018768173769117 -37.181837589261562];

offset_y = -0.0685; %-0.033242678592147; % [degrees] Offset calculated afterwards
offset_x = -0.013; % -0.037739964002411; % [degrees] Offset calculated afterwards

green_adc2angle = @(adc) deg2rad(polyval(green_pot_line_fit, adc)) - offset_y; % Convert green adc value to angle [rad]
blue_adc2angle  = @(adc) deg2rad(polyval(blue_pot_line_fit,  adc)) - offset_x; % Convert green adc value to angle [rad]

% Define payload angle as euler angle, convention: 'ZYX'. 
% joystick x-axis connected to drone.
% joystick y-axis connected to x-axis
% z-axis does not matter
j_y = green_adc2angle(adc_report(:,3+4)); % [radians] Euler y angle of joystick. (side to side) (3+ to convert Channel_ID of adc_report to index)
j_x = blue_adc2angle(adc_report(:,3+10)); % [radians] Euler x angle of joystick. (forwards backwards)
j_z = zeros(size(j_y)); % No z angle

joy_euler = [j_z, j_y, j_x]; %???debug Euler angles of joystick % MATLAB euler format is [z, y, x]

joy_quat    = eul2quat(joy_euler, 'ZYX');
joy_quat_ts = timeseries(joy_quat, adc_time, 'Name', 'Attitude'); % Time series of euler angles of drone

joy_quat_ts = resample(joy_quat_ts, time, 'linear'); % Resample for matching time sequence
joy_quat    = joy_quat_ts.Data; % Data from resampled timeseries

disp('Joystick time series')

%% Payload attitude

payload_abs_rot = quatmultiply(uav_quat, joy_quat); % Attitude of payload in World frame. First joystick rotation. Then UAV attitude rotation

payload_vector  = quat_rot_vect([0 0 1], payload_abs_rot); % unit vector representing direction of payload. Rotate neutral hanging payload by joystick angle, then attitude. % "quatrotate" rotates the coordinate frame, not the vector, therefore use inverse in function (https://www.mathworks.com/matlabcentral/answers/465053-rotation-order-of-quatrotate)

payload_vector_angles = [];
payload_vector_angles(:,1) = -atan2(payload_vector(:,2), payload_vector(:,3)); % x [radians] absolute angle of payload vector from z axis, about the x axis, projected on yz plane. NOT euler angle. negative, becasue +y gives negative rotation about x
payload_vector_angles(:,2) =  atan2(payload_vector(:,1), payload_vector(:,3)); % y [radians] absolute angle of payload vector from z axis, about the y axis, projected on xz plane. NOT euler angle

% payload_vector_angles = [payload_vector_angle_x, payload_vector_angle_y]; % [radians] [x, y] absolute angle of payload vector. NOT euler angles
payload_vector_angles = payload_vector_angles - mean(payload_vector_angles); % Remove offset

%% Write data to csv files
% Current folder should be in project folder for this to work
data_matrix = [time, rad2deg(payload_vector_angles), vel, vel_sp, acc_sp];
data_table = array2table(data_matrix);

data_table.Properties.VariableNames = {
    'time', ...
    'angle.x', 'angle.y', ...
    'vel.x', 'vel.y', 'vel.z', ...
    'vel_sp.x', 'vel_sp.y', 'vel_sp.z', ...
    'acc_sp.x', 'acc_sp.y', 'acc_sp.z'
    };
csv_index = strfind(csv_folder,'/');
csv_name = csv_folder( csv_index(end-1)+1 : end-1 );
writetable(data_table, [current_dir, '/system_id/Prac/honeybee_payload/data/', csv_name, '.csv']);

disp('CSV file generated')

%% Plots

figure;
plot(time, rad2deg(heading));
title('heading');

% figure;
% plot(combo_time, (uav_vector));
% legend('x', 'y', 'z');
% title('uav_vector');

% figure;
% plot(time, rad2deg(uav_vector_angles));
% legend('x', 'y', 'z');
% title('uav vector angles');

figure;
plot(time, rad2deg(payload_vector_angles(:,2)));
legend('x', 'y');
title('payload vector angles');

figure
plot(time, vel);
hold on
plot(time, vel_sp);
hold off
legend('vel.x', 'vel.y', 'vel.z', 'vel_sp.x', 'vel_sp.y', 'vel_sp.z');
title('Velocity')


%%
figure;
plot(adc_time, (j_x));
title('j_x');

figure;
plot(adc_time, (j_y));
title('j_y');
% 
% %%
% figure;
% title('euler angles');
% plot(uav_euler_ts);
% legend('Z', 'Y', 'X');

disp('plotted')

T_data = time(end) - time(1)



