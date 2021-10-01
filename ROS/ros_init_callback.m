%% Used in InitCallback function of any Simulink model using ros to initialise connections
disp('[InitFcn] Running initialise function for ROS connections')
% Need ro run roscore on Jetson Nano before building or running this code
rosshutdown
rosinit('192.168.55.1')

mpc_step_time = 2; % [seconds] time when switch from PID to MPC
vel_step_size = 1; % Size of North velocity step
enable_mpc_control = 1; % Set to 0 to use PID control

Ts_sim = 0.01;
Ts_publish = 0.01; % Publishing sample time. Publish faster than needed for mavros rate inconsintency
Ts_sub = 0.01; % Subscribing sample time
Ts_pos_control = 0.01; % Position and velocity controller sample time


control_vel_axis = 'x';
switch control_vel_axis
    case 'x'
        num_axis = 1;
    case 'xy'
        num_axis = 2;
end
mpc_states = 1; % Indexes to select for MPC control

initialise_iris_gains;
initialize_mpc_iris_no_load;