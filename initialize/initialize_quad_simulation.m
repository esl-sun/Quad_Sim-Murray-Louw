%% initialize simulation
% Run this script to setup all params to run Simulink file: quad_simulation_with_payload

%% Simulation options
enable_payload = 1;
enable_velocity_step = 0; % 1 = do velocity step input test, 0 = normal control
enable_aerodynamics = 0; % 1 = add effect of air

x_vel_step = 1; % Step size of x velocity
y_vel_step = 0; % Step size of x velocity
z_vel_step = 0; % Step size of x velocity

%% Simulation constants
sim_time = 50;
sim_freq = 500; % Used for sample time of blocks and fixed step size of models

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
% initialize_quad_parameters_griffin;
initialize_quad_parameters_honeybee_reg;

%% Quad Controller Gains
% execute .m to initialize standard PID controller gains as well as
% saturation values
% initialize_quad_gains_griffin;
initialize_quad_gains_honeybee_reg;

%% Quad Models and Controllers
% execute .m file to initialize all linear models of quad dynamics for
% different controllers
initialize_quad_models_controllers;

%% MPC
initialize_mpc; % Initialise mpc controller (ensure havok or dmd models have been loaded)

%% Hover
hover_init = hover_perc; % hover percentage of full throttle
hover_T_init = hover_T; % hover thrust per motor

if enable_payload
    hover_init = (mq+mp)*g / max_total_T; % hover percentage of full throttle
    hover_T_init = hover_init * max_total_T / 4;
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

time_max = 15; % MAx time between waypoints (s)
time_min = 5; % Min time between waypoints (s)

rng_seed = 0;
[waypoints, waypoints_time] = random_waypoints(num_waypoints, step_min, step_max, waypoint_min, waypoint_max, time_min, time_max, rng_seed);

% Manual waypoints: [x, y, z] = [N, E, Up]
% takeoff_height = 1;
% waypoints = [ ...
%     0, 0, takeoff_height;
%     0, 0, takeoff_height;
%     1, 0, takeoff_height];
% 
% waypoints_time = [...
%     5;
%     5;
%     15];

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
tic;
disp('Start simulation.')
out = sim('quad_simulation_with_payload.slx')
disp('Execution time:')
toc

disp('Done.')




















