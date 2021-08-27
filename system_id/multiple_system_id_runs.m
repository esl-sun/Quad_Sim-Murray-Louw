sim_type = 'Prac'
reload_data = 0; % Re-choose csv data file for SITL data
plot_results = 1;
write_csv = 1; % Output results to csv for thesis
use_MAE_diff = 0; % Use MAE metric of diff of predicitons and signal
control_vel_axis = 'x'; % only use x axis
add_training_latency = 0;
seperate_test_file = 0; % extract testing data from seperate file
        
% chapter = 'system_id';
chapter = 'results'; % folder to save csv files in

% use_angular_rate = 0;
% algorithm = 'dmd'; % 'dmd' or 'havok'
% system_id_setup;
% reload_data = 0; % Re-choose csv data file for SITL data
% % Create csv file of results;
% if write_csv
%     MAE_vs_Ntrain;
% end
% 
% algorithm = 'havok'; % 'dmd' or 'havok'
% system_id_setup;
% if write_csv
%     MAE_vs_Ntrain;
% end

file_name = '2021-08-20_03_l-1_mp-0.2_wind-0.5.csv'
data_path = strcat(parent_dir, file_name);
data = readmatrix(data_path);
algorithm = 'dmd'; % 'dmd' or 'havok'
system_id_setup;
if write_csv
    MAE_vs_Ntrain;
end

algorithm = 'havok'; % 'dmd' or 'havok'
system_id_setup;
if write_csv
    MAE_vs_Ntrain;
end

% --------------------------------------------------------------

file_name = '2021-08-12_03_manual_x_vel_steps_2mps.csv'
data_path = strcat(parent_dir, file_name);
data = readmatrix(data_path);
algorithm = 'dmd'; % 'dmd' or 'havok'
system_id_setup;
if write_csv
    MAE_vs_Ntrain;
end

algorithm = 'havok'; % 'dmd' or 'havok'
system_id_setup;
if write_csv
    MAE_vs_Ntrain;
end

% --------------------------------------------------------------

% file_name = '2021-08-12_02_manual_x_vel_steps_4mps.csv'
% data_path = strcat(parent_dir, file_name);
% data = readmatrix(data_path);
% algorithm = 'dmd'; % 'dmd' or 'havok'
% system_id_setup;
% if write_csv
%     MAE_vs_Ntrain;
% end
% 
% algorithm = 'havok'; % 'dmd' or 'havok'
% system_id_setup;
% if write_csv
%     MAE_vs_Ntrain;
% end

% --------------------------------------------------------------

file_name = '2021-08-26_01_l-1_mp-0.2_wind-6.csv'
data_path = strcat(parent_dir, file_name);
data = readmatrix(data_path);
algorithm = 'dmd'; % 'dmd' or 'havok'
system_id_setup;
if write_csv
    MAE_vs_Ntrain;
end

algorithm = 'havok'; % 'dmd' or 'havok'
system_id_setup;
if write_csv
    MAE_vs_Ntrain;
end

% % Create csv file of results;
% if write_csv
%     MAE_vs_q;
% end

% use_angular_rate = 1;
% algorithm = 'havok'; % 'dmd' or 'havok'
% system_id_setup;
% 
% % Create csv file of results;
% if write_csv
%     MAE_vs_Ntrain;
% end

% use_angular_rate = 0;
% algorithm = 'dmd'; % 'dmd' or 'havok'
% system_id_setup;
% MAE_vs_q

% use_angular_rate = 1;
% algorithm = 'havok'; % 'dmd' or 'havok'
% system_id_setup;
% 
% use_angular_rate = 1;
% algorithm = 'dmd'; % 'dmd' or 'havok'
% system_id_setup;

