%% initialize simulation
% Run this script to setup all params to run Simulink file: quad_simulation_with_payload

%% Simulation options
format compact

sim_time = 20;
fixed_step_size = 0.002; % Used for fixed step size of shared model configuration across reference models
sim_freq = 1/fixed_step_size; % Frequency of simulation

mpc_start_time = 1; % Time in secods that switch happens from velocity PID to MPC
Ts_pos_control = 0.01; % [s] Subcribing sample time Position control sample time (Ts = 1/freq)
Ts_sub = 1/100; % [s] Subscribing sample time
Ts_pub_setpoint = 0.02; % [s] Publishing rate of setpoint
step_size_ros = 0.004; % [s] Step size for solver of simulink ROS nodes
pos_control_latency = 0 ;% 0.05; % Transport delay added to acc_sp to match Simulink and SITL results
add_training_latency = 1; % Add latency to training data for system identification
enable_noise = 0
tune_scale = 1; % Scale PID values

uav_name = 'honeybee'
enable_aerodynamics = 0 % 1 = add effect of air
payload_type = 1 % 0 = no payload, 1 = 3D swinging payload, 2 = 2D double pendulum payload

control_option = 0 % 0 = only PID, 1 = MPC, 2 = LQR
use_new_control = 0 % Set to 1 to use non-PID (MPC or LQR) control signals. Set to 0 to only use PID
new_control_start_time = 1; % Time at which non-PID acc_sp starts to be used

enable_random_waypoints = 0 % Set to 1 to generate random waypoints. Set to 0 to use manual waypoint entries
enable_velocity_step = 1 % Ignore position controller, use single velocity step input
enable_vel_training_input = 0 % Ignore other velocity sp input, use velocity sepoints for training data
enable_smoother = 0 % Smooth PID pos control output with exponentional moving average

sim_type = 'Prac'; % The origin of the data, 'Simulink' or 'SITL' or 'Prac'
run_simulation = 0 % Set to 1 to automatically run simulink from MATLAB script
control_vel_axis = 'x' % Axis that MPC controls. 'x' or 'xy'
choose_model = 1 % Manually choose model file for MPC
enable_jerk_limited_mpc = 0; % Enable jerk limited pos S trajectory reference for MPC
file_name_comment = '' % Comment added to simulation_data_file name

%% Pre-set settings:
pre_set_options = 5

switch pre_set_options
    case 1 % Vel steps training
        use_sitl_data = 0 % Use data from SITL, else use data saved from Simulink
        payload_type = 1 % 0 = no payload, 1 = 3D swinging payload, 2 = 2D double pendulum payload
        control_option = 0 % 0 = only PID, 1 = MPC, 2 = LQR
        use_new_control = 0 % Set to 1 to use non-PID (MPC or LQR) control signals. Set to 0 to only use PID
        enable_vel_training_input = 1 % Ignore other velocity sp input, use velocity sepoints for training data
        tune_scale = 0.7; % Scale PID values
        file_name_comment = ''
        
    case 2 % PID vel step
        payload_type = 1 % 0 = no payload, 1 = 3D swinging payload, 2 = 2D double pendulum payload
        control_option = 0 % 0 = only PID, 1 = MPC, 2 = LQR
        use_new_control = 0 % Set to 1 to use non-PID (MPC or LQR) control signals. Set to 0 to only use PID
        enable_vel_training_input = 0 % Ignore other velocity sp input, use velocity sepoints for training data
        enable_velocity_step = 1 % Ignore position controller, use single velocity step input
        file_name_comment = '_single_step';
        
    case 3 % SITL MPC vel step
        disp('SITL MPC vel step')
        disp('-----------------')
        payload_type = 2 % 0 = no payload, 1 = 3D swinging payload, 2 = 2D double pendulum payload
        control_option = 1 % 0 = only PID, 1 = MPC, 2 = LQR
        use_new_control = 1 % Set to 1 to use non-PID (MPC or LQR) control signals. Set to 0 to only use PID
        enable_vel_training_input = 0 % Ignore other velocity sp input, use velocity sepoints for training data
        enable_velocity_step = 1 % Ignore position controller, use single velocity step input
        file_name_comment = '';
        sim_type = 'SITL'; % The origin of the data, 'Simulink' or 'SITL' or 'Prac'
        run_simulation = 0 % Set to 1 to automatically run simulink from MATLAB script
        control_vel_axis = 'x' % Axis that MPC controls. 'x' or 'xy'
        choose_model = 1 % Manually choose model file for MPC
        
    case 4 % Double pend training vel steps 
        sim_type = 'Simulink'
        tune_scale = 0.7; % Scale PID values
        use_sitl_data = 0 % Use data from SITL, else use data saved from Simulink
        payload_type = 2 % 0 = no payload, 1 = 3D swinging payload, 2 = 2D double pendulum payload
        control_option = 0 % 0 = only PID, 1 = MPC, 2 = LQR
        use_new_control = 0 % Set to 1 to use non-PID (MPC or LQR) control signals. Set to 0 to only use PID
        enable_vel_training_input = 1 % Ignore other velocity sp input, use velocity sepoints for training data
        file_name_comment = ''
        
    case 5 % Double pend MPC step
        sim_type = 'Simulink'
        use_sitl_data = 0 % Use data from SITL, else use data saved from Simulink
        payload_type = 2 % 0 = no payload, 1 = 3D swinging payload, 2 = 2D double pendulum payload
        control_option = 0 % 0 = only PID, 1 = MPC, 2 = LQR
        use_new_control = 1 % Set to 1 to use non-PID (MPC or LQR) control signals. Set to 0 to only use PID
        new_control_start_time = 1; % Time at which non-PID acc_sp starts to be used
        enable_vel_training_input = 0 % Ignore other velocity sp input, use velocity sepoints for training data
        enable_random_waypoints = 0 % Set to 1 to generate random waypoints. Set to 0 to use manual waypoint entries
        enable_velocity_step = 1 % Ignore position controller, use single velocity step input
        file_name_comment = ''
       
end

%% Force dependant settings

if payload_type == 0
    enable_payload = 0;
else
    enable_payload = 1;
end

if control_option == 0
    use_new_control = 0 % Set to 0 to only use PID
end

%% Other setting variables
if enable_payload
    uav_name = [uav_name, '_payload'];
end

switch control_vel_axis
    case 'x' % [dx angle_y]
        num_axis = 1; % Number of controlled axis
    case 'xy' % [dx, dy, angle_x, angle_y]
        num_axis = 2; % Number of controlled axis
end

if enable_random_waypoints || enable_vel_training_input
    sim_time = 400;
end

%% Simulation Folder Setup
% Add subfolders to path   
% addpath(genpath('quad_models'));
%addpath(genpath('Payload_parameter_estimation'));
%addpath(genpath('lqr_control'));
%addpath(genpath('EKF_angle_estimation'));

% Change location of generated files
myCacheFolder = '.matlab_cache/simCache';
% myCodeFolder = '.matlab_cache/simCodeGen';
myCodeFolder = [getenv('HOME'), '/Masters/Developer/MATLAB/Quad_Sim_Murray/simCodeGen'];

%% Constants
% execute .m file to initialize constants
initialize_quad_sim_constants;

%% Quad model
% execute .m file to initialize quadrotor parameters for sim model
switch uav_name
    case 'griffin'
        initialize_quad_parameters_griffin;
    case 'honeybee'
        initialize_quad_parameters_honeybee_reg;
    case 'honeybee_payload'
        initialize_quad_parameters_honeybee_reg;
end

%% Hover
hover_init = hover_perc; % hover percentage of full throttle
hover_T_init = hover_T; % hover thrust per motor

if enable_payload
    hover_init = (mq+mp)*g / max_total_T; % hover percentage of full throttle
    hover_T_init = hover_init * max_total_T / 4;
end

%% Quad Controller Gains
% execute .m to initialize standard PID controller gains as well as
% saturation values
switch uav_name
    case 'griffin'
        initialize_quad_gains_griffin;
    case 'honeybee'
        initialize_quad_gains_honeybee_reg;
    case 'honeybee_payload'
        initialize_quad_gains_honeybee_reg;
end

%% System ID
uav_folder = ['system_id/', sim_type, '/', uav_name]; % Base folder for this uav

if enable_smoother
    smoother = '_smooth';
else
    smoother = '';
end

switch payload_type
    case 0
        payload_str = 'no_load';
    case 1
        payload_str = ['single_pend', '_mp', num2str(mp), '_l', num2str(l)];
    case 2
        payload_str = ['double_pend', '_m1-', num2str(mp1), '_m2-', num2str(mp2), '_l1-', num2str(l1), '_l2-', num2str(l2)],
end

if enable_velocity_step || enable_vel_training_input
    setpoint_str = '_vel_steps';
else
    setpoint_str = '_pos_steps';
end

switch control_option
    case 0
        control_str = '_PID'
    case 1
        control_str = '_MPC'
    case 2
        control_str = '_LQR'
end

simulation_data_file = [payload_str, control_str, setpoint_str, file_name_comment]

disp('Done.')




















