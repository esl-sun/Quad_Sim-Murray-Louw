disp('start')

%% Load topics from csv into matrix
load_csv_again = 0; % Set to 1 to load new csv every time
if load_csv_again
    current_dir = pwd;
    [filename,csv_folder] = uigetfile([current_dir, '/*.csv'], 'Choose GAZEBO csv file') % GUI to choose file. % [ulog filename, path to folder with csv files]
%     file_name = erase(file_name, '.csv'); % remove file extention

    gazebo = readmatrix([csv_folder,filename]);
    disp('loaded gazebo csv file')
end

g_time = gazebo(:,1);
g_data = gazebo(:,2);

%% Plots
% close all;

figure;
plot(g_time, g_data);
disp('Click on graph where reponse begins')
[time_start,~] = ginput(1); % Get start of responce from user click

duration = 12; % Number of seconds after start to plot

start_index = find(abs(g_time - time_start) < 1e-1); % Find index closest to start time
start_index = start_index(1);

end_index = find(abs(g_time - (time_start + duration) ) < 1e-1); % Find index closest to end time
end_index = end_index(1);

g_time = g_time(start_index:end_index) - time_start;
g_data = g_data(start_index:end_index);

plot(g_time, g_data);
title(['SITL - ', filename])

disp('exit')

