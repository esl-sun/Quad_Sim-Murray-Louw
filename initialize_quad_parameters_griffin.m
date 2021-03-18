%% GRIFFIN Model

% Mass and Inertia
mq = 4.5;
Ixx = 0.23;
Iyy = 0.235;
Izz = 0.328;
I = [Ixx 0 0 ; 0 Iyy 0 ; 0 0 Izz]; % inertia matrix


% Geometry
d = 0.49; % quad arm length
Rn = 0.022; % virtual yaw moment arm


% Propulsion:
tau_T = 0.07; % motor time constant
virtual_controls_mat = [1 1 1 1; -1/sqrt(2) 1/sqrt(2) 1/sqrt(2) -1/sqrt(2); 1/sqrt(2) -1/sqrt(2) 1/sqrt(2) -1/sqrt(2); 1 1 -1 -1];
mixing_matrix = virtual_controls_mat';
max_total_T_kg = 4 * 3.2; % max thrust in kg (total)
max_total_T = max_total_T_kg * g; % maximum total thrust
max_T = max_total_T / 4; % maximum thrust per motor
hover_perc = mq*g / max_total_T; % hover percentage of full throttle
hover_total_T = max_total_T * hover_perc; % total hover thrust
hover_T = hover_total_T / 4; % hover thrust per motor


% Aerodynamic:
C_D = [0.064; 0.067; 0.089]; % From Pierro - need to calculate in flight test
Cdp = 0.01*1;
tau_w = 5;
v_w_kmh = [0; 0; 0];
v_w = v_w_kmh./3.6;
v_gust = 0.1*0;
rho = 1.225; % air density

% Noise parameters
omega_b_noise = 6e-8;
quat_noise = 6e-8;
vel_e_noise = 4e-8;
pos_e_noise = 4e-7;

omega_b_bias = -[1, 2, 1.5]*3*pi/180*0;
vel_e_bias = [0.2, -0.1, 0.3]*0;

drift_factor = 200;
drift_tau = 4;


%% Payload model
mp = 2;
l = 1;
k = 0;
c = 0.03;
