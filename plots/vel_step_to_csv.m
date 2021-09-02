sim_type = 'Prac'
chapter = 'modelling'
use_angular_rate = 0;
Ts = 0.03;
use_sitl_data = 0;
reload_data = 1; % Re-choose csv data file
control_vel_axis = 'xyz'
write_csv = 1;

extract_data;

%% Plot
figure
plot(y_data)
hold on
plot(vel_sp_data)
hold off
title('Click start and finish time of usable data')

%% User crop data
disp('Waiting for user to click start and finish time of ussable data...')
[useable_time,~] = ginput(2);
close all;

time = (useable_time(1):Ts:useable_time(2))'; % Use values inside overlapping range so no extrapulation

y_data      = resample(y_data, time);
vel_sp_data = resample(vel_sp_data, time);

y_data.Data      = -y_data.Data; % Invert step for positive step
vel_sp_data.Data = -vel_sp_data.Data; % Invert step for positive step

figure
plot(y_data)
hold on
plot(vel_sp_data)
hold off

disp("Data time cropped to useable range")
    
%% Get data for CSV
time = y_data.Time - y_data.Time(1); % Start at t=0s
y_data.Data(:,1)        = y_data.Data(:,1)      - y_data.Data(1,1); % Start at vel.x = 0
vel_sp_data.Data(:,1)   = vel_sp_data.Data(:,1) - vel_sp_data.Data(1,1); % Start at vel.x = 0

selected_rows = 1:2:length(time); % Only save every second sample for tikz memory constraint

csv_matrix = [time, y_data.Data(:,[1,2,3]), vel_sp_data.Data]; % Only vel and vel_sp data
csv_matrix = csv_matrix(selected_rows, :); % resample to make csv and tikz plot smaller

%% Prac data plot
prac_matrix = [y_data.Data(:,1), vel_sp_data.Data(:,1)];
prac_step = timeseries(prac_matrix, time);
plot(prac_step)

%% write to csv
if write_csv
  
    csv_filename = ['/home/murray/Masters/Thesis/', chapter, '/csv/', 'vel_step_', sim_type, '_', file_name, '.csv'];
    csv_filename

    VariableTypes = {'double',  'double',   'double',   'double',   'double',   'double',   'double'};
    VariableNames = {'time',    'vel_sp.x', 'vel_sp.y', 'vel_sp.z', 'vel.x',    'vel.y',    'vel.z'};
    csv_table = table('Size',size(csv_matrix),'VariableTypes',VariableTypes,'VariableNames',VariableNames);
    csv_table(:,:) = array2table(csv_matrix);

    writetable(csv_table,csv_filename)
end
