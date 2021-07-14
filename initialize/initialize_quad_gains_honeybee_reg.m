%% GRIFFIN Control Gains

%% Body Rates
Ts_angular_rate_control = 1/1000; % Hz
Ts_angle_control = 1/250; % Hz


body_rates_dterm_cutoff = 40; %Hz

[body_rates_filter_num, body_rates_filter_denom] = discrete_lpf_filter(body_rates_dterm_cutoff, sim_freq);

% *************************************************************************
% Pitch
% *************************************************************************

% Pitch Rate
K_qp = 0.06;
K_qi = 0.2;
K_qd = 0.0017;

% Pitch rate limit
q_max = 220 * pi/180; %rad

% Integrator limit for anti-windup
q_int_lim = 0.3;

% *************************************************************************
% Roll
% *************************************************************************

% Roll Rate
K_pp = K_qp;
K_pi = K_qi;
K_pd = K_qd;

% Roll rate limit
p_max = 220 * pi/180; %rad

% Integrator limit for anti-windup
p_int_lim = 0.3;

% *************************************************************************
% Yaw
% *************************************************************************

% Yaw Rate
K_rp = 0.15;
K_ri = 0.2;
K_rd = 0;

% Yaw rate limit
r_max = 200 * pi/180; %rad

% Integrator limit
r_int_lim = 0.3;

%% Attitude

max_tilt = 45; %deg

% *************************************************************************
% Pitch
% *************************************************************************

% Pitch Angle Controller
% K_theta = 2.2;
K_theta = 10;

% *************************************************************************
% Roll
% *************************************************************************

% Roll Angle Controller
K_phi = K_theta;

% *************************************************************************
% Yaw
% *************************************************************************

% Yaw Angle Controller
K_psi = 1;

%% Thrust (Velocity outputs inertial thrust which is converted to an attitude)
 %velocity controller outputs inertial force which is converted to attitude

thr_max = 1.0;
thr_min = 0.02;

%% Velocity

% vel_dterm_cutoff = 5; %Hz
vel_dterm_cutoff = 40; %Hz

[vel_filt_num, vel_filt_denom] = discrete_lpf_filter(vel_dterm_cutoff, sim_freq);

% max_vel_xy = 8.0;
% max_vel_z_up = 8.0;
% max_vel_z_down = 2.0;
max_vel_xy = 10;
max_vel_z_up = 10;
max_vel_z_down = 10;

% *************************************************************************
% X
% *************************************************************************

% Longitudinal Velocity Controller
% Original gains:
% K_up = 0.09;
% K_ui = 0.02;
% K_ud = 0.01;


% Scaled gains:
% NEW = OLD*g/hover_init;
% K_up = 3.7351; % MPC_XY_VEL_P_ACC
% K_ui = 0.8300;
% K_ud = 0.4150;

% From Reg's controller_gains.m
K_up = 0.05*g/hover_init;
K_ui = 0.025*g/hover_init;
K_ud = 0.01*g/hover_init;
 
if enable_payload
    % 2kg
%     K_up = 0.04;
%     K_ui = 0.006;
%     K_ud = 0.0133;
    
    % 1kg
%     K_up = 0.035;
%     K_ui = 0.006;
%     K_ud = 0.015;
end

% *************************************************************************
% Y
% *************************************************************************

% Lateral Velocity Controller
K_vp = K_up; % MPC_XY_VEL_P_ACC
K_vi = K_ui;
K_vd = K_ud;

% *************************************************************************
% Z
% *************************************************************************

% Vertical Velocity Controller

% Original gains:
% K_wp = 0.2;
% K_wi = 0.02;
% K_wd = 0;

% Scaled gains:
% NEW = OLD*g/hover_init;
K_wp = 8.3002; % MPC_Z_VEL_P_ACC
K_wi = 0.8300;
K_wd = 0;

%% Position

% *************************************************************************
% X
% *************************************************************************

% Longitudinal Position Controller
% K_np = 0.95;
K_np = 0.18;

if enable_payload
%    K_np = 0.25;
end

% *************************************************************************
% Y
% *************************************************************************

% Lateral Position Controller
K_ep = K_np;

% *************************************************************************
% Z
% *************************************************************************

% Vertical Position Controller
% K_dp = 1.0;
K_dp = 0.5;

% Low Pass Filter to decrease jump of position step input
% vel_ref_LPF = ;

%% PID
function [p, i, d] = pid_control(k, z1, z2)
    i = k;
    p = (z1+z2)*i;
    d = (z1*z2)*i;
end

function [p, i, d] = pi_control(k, z)
    i = k;
    p = z*i;
    d = 0;
end

%% Discrete-Time Filter
function [num, denom] = discrete_lpf_filter(cutoff_freq, sim_freq)
    C = tan(pi*cutoff_freq/sim_freq);
    D = 1 + sqrt(2)*C + C^2;
    b0 = (C^2)/D;
    b1 = 2*b0;
    b2 = b0;
    a1 = 2*(C^2 - 1)/D;
    a2 = (1 - sqrt(2)*C + C^2)/D;
    num = [b0 b1 b2];
    denom = [1 a1 a2];
end

%% Euler / Quaternions
function q = eul2quat(phi, theta, psi)
    q = [cos(phi/2)*cos(theta/2)*cos(psi/2) + sin(phi/2)*sin(theta/2)*sin(psi/2) ; sin(phi/2)*cos(theta/2)*cos(psi/2) - cos(phi/2)*sin(theta/2)*sin(psi/2) ; cos(phi/2)*sin(theta/2)*cos(psi/2) + sin(phi/2)*cos(theta/2)*sin(psi/2) ; cos(phi/2)*cos(theta/2)*sin(psi/2) - sin(phi/2)*sin(theta/2)*cos(psi/2)];
end

function eul = quat2eul(q)
    eul(:,1) = atan2(2.*(q(:,1).*q(:,2)+q(:,3).*q(:,4)), 1-2.*(q(:,2).^2+q(:,3).^2));
    eul(:,2) = asin(2.*(q(:,1).*q(:,3)-q(:,4).*q(:,2)));
    eul(:,3) = atan2(2.*(q(:,1).*q(:,4)+q(:,2).*q(:,3)), 1-2.*(q(:,3).^2+q(:,4).^2));
end