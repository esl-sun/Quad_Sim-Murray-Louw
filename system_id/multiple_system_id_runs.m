sim_type = 'HITL'
uav_name = 'iris'
reload_data = 1; % Re-choose csv data file for SITL data
plot_results = 1;
write_csv = 0; % Output results to csv for thesis
use_MAE_diff = 0; % Use MAE metric of diff of predicitons and signal
control_vel_axis = 'x'; % only use x axis
add_training_latency = 0;
pos_control_latency = 0.01; % measured latenecy is 0.04. which includes to MAVROS and back through MAVROS. Only apply half
use_angular_rate = 0;
seperate_test_file = 0; % extract testing data from seperate file
train_with_pid_and_mpc = 0; % USe training data with PID and MPC controllers in one simulation

Ts = 0.04 % Desired sample time

chapter = 'results'; % folder to save csv files in ('system_id', 'results', 'control')

algorithm = 'dmd'; % 'dmd' or 'havok'
system_id_setup;

% if write_csv
%     MAE_vs_Ntrain;
% end

% reload_data=0;
% algorithm = 'havok'; % 'dmd' or 'havok'
% system_id_setup;

