%% Plot results from MATLAB simulation of UAV
disp('Start')

%% Load data from sim into matrix

m_time = out.pos.Time;
m_data = out.pos.Data;

%% Plot data
close all;

figure;
plot(m_time, m_data);
disp('Click on graph where reponse begins')
[time_start,~] = ginput(1); % Get start of responce from user click

duration = 12; % Number of seconds after start to plot
threshold = m_time(2) - m_time(1)
start_index = find(abs(m_time - time_start) < threshold); % Find index closest to start time
start_index = start_index(1);

end_index = find(abs(m_time - (time_start + duration) ) < 1e-1); % Find index closest to end time
end_index = end_index(1);

m_time = m_time(start_index:end_index) - time_start;
m_data = m_data(start_index:end_index);

plot(m_time, m_data);
title('MATLAB sim data')

disp('Done.')

