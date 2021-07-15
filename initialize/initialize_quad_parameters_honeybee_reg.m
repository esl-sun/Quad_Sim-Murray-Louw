%% Honeybee Model

% Mass and Inertia
mq = 0.66;
Ixx = 9.305e-4;
Iyy = 1.326e-3;
Izz = 1.95e-3;
I = [Ixx 0 0 ; 0 Iyy 0 ; 0 0 Izz]; % inertia matrix

% Geometry
d = 0.11; % quad arm length
Rn = 7.997e-3; % virtual yaw moment arm

% Propulsion:
tau_T = 0.015; % motor time constant HB
virtual_controls_mat = [1 1 1 1; -1/sqrt(2) 1/sqrt(2) 1/sqrt(2) -1/sqrt(2); 1/sqrt(2) -1/sqrt(2) 1/sqrt(2) -1/sqrt(2); 1 1 -1 -1];
mixing_matrix = virtual_controls_mat';
max_total_T_kg = 4 * 6.85/9.81; % max thrust in kg (total of all motors) % Read from graph on pg. 20 Reg thesis
max_total_T = max_total_T_kg * g; % maximum total thrust
max_T = max_total_T / 4; % maximum thrust per motor
hover_perc = mq*g / max_total_T; % hover percentage of full throttle
hover_total_T = max_total_T * hover_perc; % total hover thrust
hover_T = hover_total_T / 4; % hover thrust per motor

% Aerodynamic:
C_D = [0.064; 0.067; 0.089]; % From Pierro - need to calculate in flight test
% C_D = [0.2; 0.2; 0.2]; % Anton Thesis
% C_D = [0.12; 0.12; 0.32]; % Murray added. From http://tinyurl.com/t87xgz8 - standard ZMR graph, pg.13, C_D = [15deg, 15deg, 90deg]

Cdp = 0.01*1;
tau_w = 5;
v_w_kmh = [0; 0; 0];
v_w = v_w_kmh./3.6;
v_gust = 0.1*0;
rho = 1.225; % air density

if ~enable_aerodynamics
    rho = 0; % Disable effect or aerodynamics
end

% Noise parameters
omega_b_noise = 6e-8; % Tuned by Anton to look similar to practical data
quat_noise    = 6e-8;
vel_e_noise   = 4e-8;
pos_e_noise   = 4e-7;

phi_noise   = 4*1e-9; % Tuned by Murray to look decent. Not yet practically compared
theta_noise = 2*1e-10;

omega_b_bias = -[1, 2, 1.5]*3*pi/180*0;
vel_e_bias   = [0.2, -0.1, 0.3]*0;

drift_factor = 200;
drift_tau    = 4;

%% Payload model
mp = 0.2;
l = 0.5;
c = 0.003; % From Willem simulations for match prac to sim 
k = 0;

%% Double pendulum model
mp1 = 0.13
mp2 = mp - mp1 % Choose mp2 so that total payload maas same as single payload mass
if mp2 < 0
    error('mp2 must be positive')
end

l2 = 0.5
l1 = (l*(mp1 + mp2)  - l2*mp2)/(mp1 + mp2) % Choose l2 so that effective pendulum length same as single pendulum length

l_eff = (l1*mp1 + (l1 + l2)*mp2)/(mp1 + mp2) % Effective single pendulum length
m_total = mp1 + mp2

c1 = 0.003;
c2 = 0.003;


