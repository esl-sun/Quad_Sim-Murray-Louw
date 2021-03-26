%% initialize simulation
enable_payload = 1;

%% Simulation constants
sim_time = 500;
sim_freq = 250;


%% Simulation Folder Setup
% Add subfolders to path   
addpath(genpath('quad_models'));
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
initialize_quad_parameters_griffin;

%% Quad Controller Gains
% execute .m to initialize standard PID controller gains as well as
% saturation values
initialize_quad_gains_griffin;
%init_quad_control_adaptive_griffin;

%% Quad Models and Controllers
% execute .m file to initialize all linear models of quad dynamics for
% different controllers
initialize_quad_models_controllers;

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

time_max = 30; % Min time between waypoints (s)
time_min = 5; % Max time between waypoints (s)

rng_seed = 0;
[waypoints, waypoints_time] = random_waypoints(num_waypoints, step_min, step_max, waypoint_min, waypoint_max, time_min, time_max, rng_seed);

% Manual waypoints:
% waypoints = [ ...
%     0, 0, 0;
%     0, 0, 0;
%     0, 1, 0];
% waypoint_time = [...
%     5;
%     5;
%     5];

% plot(cumsum(waypoint_time),waypoints)
% title('waypoints')
% legend('x', 'y', 'z');

%% Simulation inputs
% initialize state inputs
initialize_inputs;

%% Step response
initialize_step 


% Test comment from laptop
function [waypoints, waypoints_time] = random_waypoints(num_waypoints, step_min, step_max, waypoint_min, waypoint_max, time_min, time_max, rng_seed)
%% Returns matrix with a random waypoints per row, and random time intervals between waypoints

% num_waypoints = Number of waypoints

% waypoint_max = Max values in waypoint [x,y,z]
% waypoint_min = Min values in waypoint [x,y,z]
% 
% step_max = Max step/change in waypoint [x,y,z]
% step_min = Min step/change in waypoint [x,y,z]
% 
% time_max = Min time between waypoints (s)
% time_min = Max time between waypoints (s)

    minmax = @(x, min_x, max_x) max(min(x,max_x),min_x); % anonymous function to restrict input x between min and max values

    rng(rng_seed); % Initialise random number generator for repeatability
    
    waypoints = zeros(num_waypoints,3); % Initialize empty matrix
    waypoint_time = zeros(num_waypoints,1); % Vector of time between waypoints. If time < 0: wait till reach threshhold before next waypoint

    waypoint_start = [0, 0, 10]; % Starting waypoint [x,y,z] (z is up positive for now)
    waypoints(1,:) = waypoint_start;
    
    for i = 2:num_waypoints % Populate waypoint matrix
        waypoint_step = ((step_max - step_min).*rand(1,3) + step_min).*sign(randn(1,3)); % Step size to next waypoint [x,y,z]
        waypoints(i,:) = waypoints(i-1,:) + waypoint_step; % Generate next waypoint
        waypoints(i,:) = minmax(waypoints(i,:), waypoint_min, waypoint_max); % Limit waypoints to within min and max range
        waypoint_time(i) = floor(((time_max - time_min).*rand() + time_min)); % Time interval between waypoints
    end

    waypoints(:,3) = -waypoints(:,3); % Convert z to down-positive
    
end




















