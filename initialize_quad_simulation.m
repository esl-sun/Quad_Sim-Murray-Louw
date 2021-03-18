%% initialize simulation
is_step = false;
enable_payload = 1;


%% Simulation constants
sim_time = 400;
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


%% Estimation
% 
% % RLS for payload mass estimation
% rls_filter = 30;
% rls_cov = 100;
% alpha = 0.2;
% 
% % FFT for cable length estimation
% window = 40;
% window_delay = 5;
% 
% f_res = 0.01;
% fft_min_freq = 0.16;
% fft_max_freq = 1.58;
% 
% % bisgaard sine wave estimator
% numFreqs = 38; % look at 48 frequencies between 0.5 - 5m
% numShifts = 36; % 
% meas_freq = 20; % 
% cable_est_time = 5; % seconds given for cable estimation
% py.importlib.import_module('sine_wave_estimator')

%% Kalman Filter
% Q = diag([0.2 0.2 2*pi/180 1*pi/180 2*pi/180 1*pi/180]);
% %Q = diag([0.2 0.2 2*pi/18 1*pi/18 2*pi/18 1*pi/18]);
% 
% %Rk = (pi/36)*1;
% Rk = diag([pi/36 pi/36 0.1 0.1]);
% Rk_direct = diag([0.1 0.1]); % EKF with direct angle measurements
% 
% is_real_time_cov = 0;
% 
% % simulate camera measurements
% Pb_in_c = [0.3; 0; -0.01];
% cam_noise = 2e-9;
% EKF_freq = 10*1;
% cam_freq = 2*pi*10;
% cam_bias = 0;
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


%% LQR
% Ass = [0          0           0           0           0           (mp/mq)*g;
%      0          0           0   (g*mp)/mq   0           0;
%      0          0           0   -g*(mq+mp)/(l*mq)   0           0;
%      0          0           1           0           0           0;
%      0          0           0           0           0           -g*(mq+mp)/(l*mq);
%      0          0           0           0           1           0];
%  
% Bss = [1/mq       0;
%      0          1/mq;
%      0          -1/(l*mq);
%      0          0;
%      -1/(l*mq)  0;
%      0          0]; 
%  
% Css = [1 1 0 0 0 0];
%  
%  
% Ass_aug= [0          0           -1         0           0           0           0           0;
%           0          0           0          -1          0           0           0           0;
%           0          0           0          0           0           0           0           (mp/mq)*g;
%           0          0           0          0           0       (g*mp)/mq       0           0;
%           0          0           0          0           0   -g*(mq+mp)/(l*mq)   0           0;
%           0          0           0          0           1           0           0           0;
%           0          0           0          0           0           0           0           -g*(mq+mp)/(l*mq);
%           0          0           0          0           0           0           1           0];
%       
% Bss_aug = [zeros(2, 2); Bss];
% 
% 
%                
% if control_angles
%     Q_lqr = diag([50*1 50*1 50*1 50*1 1*200/100 300/100 1*200/100 300/100]); 
% else
%     Q_lqr = diag([50*1 50*1 50*1 50*1 1*200/100 0*3/100 1*200/100 0*3/100]);
% end
% R_lqr = 10*diag([1 1]);
% 
% %Q_lqr = diag([1/(15^2) 1/(15^2) 1/(12^2) 1/(12^2) 2/((180*2*pi)^2) 3/((180*2*pi)^2) 2/((180*2*pi)^2) 3/((180*2*pi)^2)]);
% %R_lqr = diag([1/(max_total_T^2) 1/(max_total_T^2)]);
% 
% %K_lqr = lqr(Ass_aug, Bss_aug, Q_lqr, R_lqr);
% 
%% notch filter
% zeta_z_notch = 0.0; % 0.05
% zeta_p_notch = 1; % 0.5 1.0
% type = 1; % 1 = notch, 2 = LPF
% freq_factor = 1.0;

%% Waypoints
% waypoints for simulation                                
waypoints = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0], [2, 0, 0], [2, 0, 0], [0, 0, 0], [0, 0, 0], [10, 0, 0], [10, 0, 0], [0, 0, 0], [0, 0, 0]];
waypoints = vec2mat(waypoints, 3);
waypoints(:,3) = -waypoints(:,3); % Convert z to down
threshold = 1e-3;
waypoint_time = 20;

% if is_step == true
%     waypoints = [0 0 0];
% end


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
























