%% initialize simulation
is_step = true;
enable_payload = 1;


%% Simulation constants
sim_time = 35;
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
% waypoints for simulation                                
waypoints = [...
    [0, 0, 0], 
    [0, 0, 0], 
%     [2, 0, 10], 
%     [2, 0, 10], 
%     [6, 0, 12], 
%     [6, 0, 12], 
%     [6, 0, 15], 
%     [6, 0, 20], 
%     [4, 0, 20], 
%     [4, 0, 20], 
%     [5, 0, 17], 
%     [7, 0, 17],
%     [7, 0, 10],
%     [2, 0, 10],
%     [2, 0, 10],
%     [2, 0, 12],
%     [12, 0, 12],
%     [12, 0, 12],
%     [12, 0, 12],
%     [5, 0, 12],
%     [5, 0, 12],
%     [2, 0, 15],
%     [2, 0, 15],
%     [2, 0, 11],
%     [8, 0, 11],
%     [8, 0, 10],
%     [8, 0, 10],
%     [0, 0, 0],
%     [0, 0, 0],
    [1, 0, 0]];

if is_step
    waypoints = [0 0 0];
end

waypoints = vec2mat(waypoints, 3);
waypoints(:,3) = -waypoints(:,3); % Convert z to down
waypoint_time = 5; % Time before next waypoint given. If time < 0: wait till reach threshhold before next waypoint
threshold = 1e-3; % Threshold to reach waypoint
waypoint_time_vector = [0:waypoint_time:waypoint_time*size(waypoints,1)-1]';

% plot(waypoint_time_vector,waypoints)
% title('waypoints')
% legend('x', 'y', 'z');




%% Simulation inputs
% initialize state inputs
initialize_inputs;

%% Step response
initialize_step 

%% Run simulation
%quad_sim_play;

% if enable_payload
%    sim quad_simulation_with_payload_lqr.slx;
% else
%     sim quad_simulation.slx;
% end
% 
%sim('quad_simulation_with_payload_lqr')
























