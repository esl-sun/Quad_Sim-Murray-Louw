%% initialize simulation
% Run this script to setup all params to run Simulink file: quad_simulation_with_payload

%% Simulation options
sim_time = 50;
sim_freq = 500; % Used for sample time of blocks and fixed step size of models
mpc_start_time = 5; % Time in secods that switch happens from velocity PID to MPC

uav_name = 'honeybee'
enable_aerodynamics = 0 % 1 = add effect of air
enable_payload = 0
enable_noise = 0
enable_mpc = 1 % Set to 1 to uncomment MPC block
use_mpc_control = 1 % Set to 1 to use MPC control signals. Set to 0 to only use PID
enable_random_waypoints = 1 % Generate random waypoints
enable_smoother = 1 % Smooth PID pos control output with exponentional moving average
run_simulation = 1 % Set to 1 to automatically run simulink from MATLAB script

%% Input smoothing
moving_ave_exp = 0.97;

%% Enable payload
payload_variant = Simulink.Variant('enable_payload == 1');

%% Enable noise
no_noise_variant = Simulink.Variant('enable_noise == 0'); % Variant subsytem block to uncomment payload if needed
noise_variant = Simulink.Variant('enable_noise == 1');

%% Simulation constants

%% Simulation Folder Setup
% Add subfolders to path   
% addpath(genpath('quad_models'));
%addpath(genpath('Payload_parameter_estimation'));
%addpath(genpath('lqr_control'));
%addpath(genpath('EKF_angle_estimation'));

% Change location of generated files
myCacheFolder = '.matlab_cache/simCache';
myCodeFolder = '.matlab_cache/simCodeGen';
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
end

%% Quad Models and Controllers
% execute .m file to initialize all linear models of quad dynamics for
% different controllers
initialize_quad_models_controllers;

%% MPC
mpc_states = [1]; % Indexes of states selected for MPC to control. i.e. [1, 2] to control x and y
pid_states = setdiff(pid_states, mpc_states); % States controlled by PID if MPC active 

ny = length(mpc_states); % Number of measured states for mpc
nu = ny; % Number of controlled states by MPC

no_mpc_variant = Simulink.Variant('enable_mpc == 0'); % Variant subsytem block to uncomment MPC if needed
mpc_variant = Simulink.Variant('enable_mpc == 1');
if enable_mpc
    initialize_mpc_honeybee; % Initialise mpc controller (ensure havok or dmd models have been loaded)
end

%% notch filter
% zeta_z_notch = 0.0; % 0.05
% zeta_p_notch = 1; % 0.5 1.0
% type = 1; % 1 = notch, 2 = LPF
% freq_factor = 1.0;

%% Waypoints
threshold = 1e-3; % Threshold to reach waypoint, for threshold mode
num_waypoints = 100; % Number of waypoints

waypoint_max = [15, 15, 20]; % Max values in waypoint [x,y,z]
waypoint_min = [-15, -15, 10]; % Min values in waypoint [x,y,z]

step_max = [5, 2, 2]; % Max step/change in waypoint [x,y,z]
step_min = [0, 0, 0]; % Min step/change in waypoint [x,y,z]

time_max = 10; % Max time between waypoints (s)
time_min = 4; % Min time between waypoints (s)

if enable_random_waypoints
    rng_seed = 0;
    [waypoints, waypoints_time] = random_waypoints(num_waypoints, step_min, step_max, waypoint_min, waypoint_max, time_min, time_max, rng_seed);
else
    % Manual waypoints: [x, y, z] = [N, E, Up]
    takeoff_height = 1;
    waypoints = [ ...
                0, 0, takeoff_height;
                0, 0, takeoff_height;
                1, 0, takeoff_height];

    waypoints = [ ...
                0, 0, 0;
                0, 0, 1;
                0, 0, -1
                0, 0, -2];
            
    waypoints_time = [...
                5;
                5;
                5;
                5];        
end

% figure(1)
% plot(cumsum(waypoints_time),waypoints) % Plot waypoints to visualise it
% title('waypoints')
% legend('x', 'y', 'z');

%% Simulation inputs
% initialize state inputs
initialize_inputs;

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




















