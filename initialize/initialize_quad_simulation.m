%% initialize simulation
% Run this script to setup all params to run Simulink file: quad_simulation_with_payload

%% Simulation options
format compact

sim_time = 400;
sim_freq = 1000; % Used for sample time of blocks and fixed step size of models
mpc_start_time = 1; % Time in secods that switch happens from velocity PID to MPC
Ts_pos_control = 0.01; % [s] Subcribing sample time Position control sample time (Ts = 1/freq)
Ts_sub = 1/100; % [s] Subscribing sample time
Ts_pub_setpoint = 0.02; % [s] Publishing rate of setpoint
step_size_ros = 0.004; % [s] Step size for solver of simulink ROS nodes
pos_control_latency = 0 ;%0.05; % Transport delay added to acc_sp to match Simulink and SITL results
add_training_latency = 1; % Add latency to training data for system identification

uav_name = 'honeybee'
enable_aerodynamics = 0 % 1 = add effect of air
enable_payload = 1
enable_noise = 0

control_option = 0 % 0 = only PID, 1 = MPC, 2 = LQR
use_new_control = 1 % Set to 1 to use non-PID (MPC or LQR) control signals. Set to 0 to only use PID
if control_option == 0
    use_new_control = 0 % Set to 0 to only use PID
end
new_control_start_time = 1; % Time at which non-PID acc_sp starts to be used

enable_random_waypoints = 0 % Set to 1 to generate random waypoints. Set to 0 to use manual waypoint entries
enable_velocity_step = 1 % Ignore position controller, use single velocity step input
enable_vel_training_input = 1 % Ignore other velocity sp input, use velocity sepoints for training data
enable_smoother = 0 % Smooth PID pos control output with exponentional moving average

run_simulation = 0 % Set to 1 to automatically run simulink from MATLAB script
control_vel_axis = 'x' % Axis that MPC controls. 'x' or 'xy'
use_sitl_data = 0 % Use data from SITL, else use data saved from Simulink
choose_model = 1 % Manually choose model file for MPC
enable_jerk_limited_mpc = 0; % Enable jerk limited S trajectory reference for MPC
file_name_comment = '_velocity_steps' % Comment added to simulation_data_file name

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

if enable_velocity_step
    sim_time = 20
end

%% Input smoothing
moving_ave_exp = 0.97;

%% Enable payload
payload_variant = Simulink.Variant('enable_payload == 1');

%% Enable noise
no_noise_variant = Simulink.Variant('enable_noise == 0'); % Variant subsytem block to uncomment payload if needed
noise_variant = Simulink.Variant('enable_noise == 1');

%% Enable MPC jerk limited trajectory
jerk_limited_mpc_variant = Simulink.Variant('enable_jerk_limited_mpc == 1'); % Variant subsytem block to uncomment payload if needed
step_mpc_variant = Simulink.Variant('enable_jerk_limited_mpc == 0'); % Variant subsytem block to uncomment payload if needed

%% Simulation constants

%% Simulation Folder Setup
% Add subfolders to path   
% addpath(genpath('quad_models'));
%addpath(genpath('Payload_parameter_estimation'));
%addpath(genpath('lqr_control'));
%addpath(genpath('EKF_angle_estimation'));

% Change location of generated files
myCacheFolder = '.matlab_cache/simCache';
% myCodeFolder = '.matlab_cache/simCodeGen';
myCodeFolder = '/home/esl/Masters/Developer/MATLAB/Quad_Sim_Murray/simCodeGen';
Simulink.fileGenControl('set', 'CacheFolder', myCacheFolder, 'CodeGenFolder', myCodeFolder, 'createDir', true);

% Generate QUAD_MODEL s-function
%mex Payload_parameter_estimation/RLS_MASS.c -outdir Payload_parameter_estimation

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

%% Quad Models and Controllers
% execute .m file to initialize all linear models of quad dynamics for
% different controllers
initialize_quad_models_controllers;

%% System ID
if use_sitl_data
    sim_type = 'SITL'; % Choose source of data: SITL or Simulink
else
    sim_type = 'Simulink'; % Choose source of data: SITL or Simulink
end
uav_folder = ['system_id/', sim_type, '/', uav_name]; % Base folder for this uav

if enable_smoother
    smoother = '_smooth';
else
    smoother = '';
end

simulation_data_file = ['PID_', control_vel_axis,'_payload', '_mp', num2str(mp), '_l', num2str(l), smoother, file_name_comment]

%% MPC
mpc_states = [1]; % Indexes of states selected for MPC to control. i.e. [1, 2] to control x and y
pid_states = setdiff([1 2 3], mpc_states); % States controlled by PID if MPC active 
mpc_variant = Simulink.Variant('control_option == 1'); % Variant subsytem block to uncomment MPC if needed
 
if control_option == 1
    initialize_mpc_honeybee; % Initialise mpc position controller (ensure havok or dmd models have been loaded)
end

%% LQR
lqr_variant = Simulink.Variant('control_option == 2'); % Variant subsytem block to uncomment LQR if needed
if control_option == 2
    initialize_lqr_honeybee; % Initialise LQR position controller
end

%% Simulation inputs
% initialize state inputs
initialize_inputs;
initialize_controller_inputs; % Scheduled waypoints and velocity setpoints

%% Step response
initialize_step 

%% Run simulation
if run_simulation
    tic;
    disp('Start simulation.')
    out = sim('quad_simulation_with_payload.slx')
    disp('Execution time:')
    toc
end

disp('Done.')




















