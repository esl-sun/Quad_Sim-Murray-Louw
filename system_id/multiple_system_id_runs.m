sim_type = 'Simulink'
reload_data = 0; % Re-choose csv data file for SITL data
plot_results = 1;
write_csv = 0; % Output results to csv for thesis
use_MAE_diff = 0; % Use MAE metric of diff of predicitons and signal
control_vel_axis = 'x'; % only use x axis
add_training_latency = 0;
use_angular_rate = 0;
seperate_test_file = 0; % extract testing data from seperate file

chapter = 'control'; % folder to save csv files in ('system_id', 'results', 'control')

algorithm = 'dmd'; % 'dmd' or 'havok'
system_id_setup;

if write_csv
    MAE_vs_Ntrain;
end


