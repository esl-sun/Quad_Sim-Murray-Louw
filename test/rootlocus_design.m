%% Generate root locus plot data
enable_payload = 1;

%% Anton variables
% g = 9.81;        %m/s^2
% mq = 4.5;        %kg
% mpr = 2;          %kg
% lr = 0.5;           %l
% Ixx = 0.23;      %
% Iyy = 0.235;     %
% Izz = 0.328;     %
% tau = 0.07;      %s
% Rn = 0.0237;     %m
% d = 0.49;        %m
% Tmax = 31.392;   %N

% Honeybee

% Mass and inertia
g = 9.81;        % m/s^2
mq = 0.796;
mpr = 0.1;        % kg
lr = 1;           % m
Ixx = 9.305e-4;
Iyy = 1.326e-3;
Izz = 1.95e-3;
tau = 0.015; % motor time constant HB
Tmax = 6.85; % [N] Max thrust per motor

% Geometry
d = 0.11; % [m] quad arm length
Rn = 7.997e-3; % [m] virtual yaw moment arm


% motor coefficients
% motor_coeff_1 = [-0.0000000397959403 0.0001996456801152 -0.2773896905520106 118.7667175238575652];
% motor_coeff_2 = [-0.0000000413595098 0.0002069219596305 -0.2858221900173662 121.2675504198610383];
% motor_coeff_3 = [-0.0000000406769540 0.0002028435504012 -0.2787807080476987 117.7570545685150876];
% motor_coeff_4 = [-0.0000000386173758 0.0001927613593388 -0.2630242287303664 109.8400430499503813];

%% Step response
step_sim_time = 1*10;
step_sim_freq = 250;
step_time = 0;

disturb = 1;
disturb_time = 20;
disturb_val = 0.01;




%%%%%% ------------------ longitudinal controllers ---------------- %%%%%%%
%% pitch rate (Q):
s = tf('s');

% Gains pitch rate
Kp_pr = 0.086;
Ki_pr = 0.02;
Kd_pr = 0.003;

% linear plant
G_pitch_rate_ol = 2*Tmax*(d/(tau*Iyy))/(s*(s+1/tau));
%rltool(G_pitch_rate)

% PID controller
D_pitch_rate = Kp_pr+Ki_pr/s+Kd_pr*s;
%rltool(D_pitch_rate*G_pitch_rate)

G_pitch_rate_cl = D_pitch_rate*G_pitch_rate_ol/(1+D_pitch_rate*G_pitch_rate_ol);

% bandwidth with controller
fb_pitch_rate = bandwidth(G_pitch_rate_cl)

% bandwidth without controller
aaaa = bandwidth(G_pitch_rate_ol/(1+G_pitch_rate_ol))



%% pitch angle

% Gain pitch angle
Kp_pa = 3;

% linear plant
G_pitch_angle_ol = (G_pitch_rate_cl)*(1/s);
[num_pitch_angle, den_pitch_angle] = tfdata(G_pitch_angle_ol, 'v');

%rltool(Kp_pa*G_pitch_angle_ol)

G_pitch_angle_cl = Kp_pa*G_pitch_angle_ol/(1+Kp_pa*G_pitch_angle_ol);

% bandwidth
fb_pitch_angle = bandwidth(G_pitch_angle_cl)

% bandwidth without controller
bbbbb = bandwidth(G_pitch_angle_ol/(1+G_pitch_angle_ol))


%% linear velocity north (Vn)

% gains linear velocity north
Kp_vn = 0.048;
Ki_vn = 0.008;
Kd_vn = 0.002;


% linear plant
G_vn_ol = (4*Tmax)*(1/(2*mq*g))*(G_pitch_angle_cl)*(2*mq*g)*(1/mq)*(1/s);
enable_payload = 0;
if enable_payload
   G_pln = 4*Tmax*(1/(mq*s) - (g*mpr)/(mq*(lr*mq*s^3 + g*mpr*s + g*mq*s)));
   G_vn_ol = G_pitch_angle_cl * G_pln; 
end

%rltool(G_vn_ol)

% PID controller
D_vn = Kp_vn+Ki_vn/s+Kd_vn*s;
%rltool(D_vn*G_vn_ol)

G_vn_cl = D_vn*G_vn_ol/(1+D_vn*G_vn_ol);



% bandwidth
fb_vn = bandwidth(G_vn_cl)

% bandwidth without controller
cccc = bandwidth(G_vn_ol/(1+G_vn_ol))
%% inertial position north (N)

% gain position north
Kp_xn = 0.35*0.75; % Anton
Kp_xn = 0.35*0.75*1.3374; % Adjusted to match thesis

% linear plant
G_xn_ol = G_vn_cl*(1/s);
%rltool(G_xn_ol)

G_xn_cl = Kp_xn*G_xn_ol/(1+Kp_xn*G_xn_ol);
%rltool(Kp_xn*G_xn_ol)

% bandwidth
fb_xn = bandwidth(G_xn_cl)

% bandwidth without controller
ddd = bandwidth(G_xn_ol/(1+G_xn_ol))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% ------------------ lateral controllers ---------------- %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% roll rate (P):
s = tf('s');

% Gains pitch rate
Kp_rr = 0.0842;
Ki_rr = 0.0196;
Kd_rr = 0.0029;

% linear plant
G_roll_rate_ol = 2*Tmax*(d/(tau*Ixx))/(s*(s+1/tau));
%rltool(G_roll_rate)

% PID controller
D_roll_rate = Kp_rr+Ki_rr/s+Kd_rr*s;
%rltool(D_roll_rate*G_roll_rate)

G_roll_rate_cl = D_roll_rate*G_roll_rate_ol/(1+D_roll_rate*G_roll_rate_ol);

% bandwidth 
fb_roll_rate = bandwidth(G_roll_rate_cl)



%% roll angle

% Gain pitch angle
Kp_ra = 3;

% linear plant
G_roll_angle_ol = (G_roll_rate_cl)*(1/s);
[num_roll_angle, den_roll_angle] = tfdata(G_roll_angle_ol, 'v');

%rltool(Kp_ra*G_roll_angle_ol)

G_roll_angle_cl = Kp_ra*G_roll_angle_ol/(1+Kp_ra*G_roll_angle_ol);

% bandwidth
fb_roll_angle = bandwidth(G_roll_angle_cl)




%% linear velocity east (Ve)

% gains linear velocity east
Kp_ve = 0.048;
Ki_ve = 0.008;
Kd_ve = 0.002;

% linear plant
G_ve_ol = -(4*Tmax)*(1/(2*mq*g))*(G_roll_angle_cl)*(2*mq*g)*(1/mq)*(1/s);
%rltool(G_ve_ol)

% PID controller
D_ve = Kp_ve+Ki_ve/s+Kd_ve*s;
%rltool(D_ve*G_ve_ol)

G_ve_cl = D_ve*G_ve_ol/(1+D_ve*G_ve_ol);

% bandwidth
fb_vn = bandwidth(G_ve_cl)


%% inertial position east (E)

% gain position east
Kp_xe = 0.35;

% linear plant
G_xe_ol = G_ve_cl*(1/s);
%rltool(G_xe_ol)

G_xe_cl = Kp_xe*G_xe_ol/(1+Kp_xe*G_xe_ol);
%rltool(Kp_xe*G_xe_ol)

% bandwidth
fb_xe = bandwidth(G_xe_cl)








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% ----------- directional/heading controllers ----------- %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% yaw rate (R):
s = tf('s');

% Gains yaw rate
Kp_yr = 0.35;
Ki_yr = 0.03;
Kd_yr = 0;

% linear plant
G_yaw_rate_ol = 4*Tmax*(Rn/(tau*Izz))/(s*(s+1/tau));
%rltool(G_yaw_rate_ol)

% PID controller
D_yaw_rate = Kp_yr+Ki_yr/s+Kd_yr*s;
%rltool(D_yaw_rate*G_yaw_rate_ol)

G_yaw_rate_cl = D_yaw_rate*G_yaw_rate_ol/(1+D_yaw_rate*G_yaw_rate_ol);

% bandwidth 
fb_yaw_rate = bandwidth(G_yaw_rate_cl)



%% yaw angle

% Gain pitch angle
Kp_ya = 1.2;

% linear plant
G_yaw_angle_ol = (G_yaw_rate_cl)*(1/s);
%[num_yaw_angle, den_yaw_angle] = tfdata(G_yaw_angle_ol, 'v');

%rltool(Kp_ya*G_yaw_angle_ol)

G_yaw_angle_cl = Kp_ya*G_yaw_angle_ol/(1+Kp_ya*G_yaw_angle_ol);

% bandwidth
fb_yaw_angle = bandwidth(G_yaw_angle_cl)







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% ------------------ heave controllers ------------------ %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% down velocity (D (W)):
s = tf('s');

% Gains down velocity
Kp_vd = 0.1;
Ki_vd = 0.01;
Kd_vd = 0;

% linear plant
G_vd_ol = 4*Tmax*(1/(tau*mq))/(s*(s+1/tau));
%rltool(G_vd_ol)

% PID controller
D_vd = Kp_vd+Ki_vd/s+Kd_vd*s;
%rltool(D_vd*G_vd_ol)

G_vd_cl = D_vd*G_vd_ol/(1+D_vd*G_vd_ol);

% bandwidth 
fb_vd = bandwidth(G_vd_cl)

vel_down_performance = stepinfo(G_vd_cl);

%% altitude
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% maak klaar
% Gain altitude
Kp_xd = 0.9;

% linear plant
G_xd_ol = (G_vd_cl)*(1/s);

%rltool(Kp_xd*G_xd_ol)

G_xd_cl = Kp_xd*G_xd_ol/(1+Kp_xd*G_xd_ol);

% bandwidth
fb_xd = bandwidth(G_xd_cl)

altitude_performance = stepinfo(G_xd_cl);

%%




























%%

% 
% % Transfer functions
% s = tf('s');
% G = G_VN_OL;
% D = D_VN;
% 
% [G_NUM, G_DENOM] = tfdata(G, 'v');
% 
% clear zero;
% clear zeros; % Clear any zero variables masking the function
% [ctrl_zeros, ctrl_gain] = zero(D*s^0);
% p_gain = 0;
% i_gain = 0;
% d_gain = 0;
% if isempty(ctrl_zeros)
%     p_gain =  ctrl_gain;
% elseif length(ctrl_zeros) == 1
%     p_gain = ctrl_gain;
%     i_gain = p_gain * abs(ctrl_zeros(1));
% elseif length(ctrl_zeros) == 2
%     d_gain = ctrl_gain;
%     p_gain = d_gain*(abs(ctrl_zeros(1)) + abs(ctrl_zeros(2)));
%     i_gain = d_gain*abs(ctrl_zeros(1))*abs(ctrl_zeros(2));
% end
% 
% Gol = G*D;
% 
% 
% 
% 
% 
% 
% 
% % Root locus data
% [r_plant, gain_plant] = rlocus(G); % Poles and zeros of open loop system
% [r, gain] = rlocus(Gol); % Poles and zeros of closed loop system
% [Z, K] = zero(Gol); % Gain K
% 
% % Obtain real and imaginary parts
% % Plant
% rl_plant = zeros(length(r_plant), 2*min(size(r_plant)));
% for i=1:min(size(r_plant))
%    rl_plant(:,2*i-1) = (real(r_plant(i,:))).';
%    rl_plant(:,2*i) = (imag(r_plant(i,:))).'; 
% end
% % Open loop
% rl_ol = zeros(length(r), 4*min(size(r))); % Will include closed loop poles
% for i=1:min(size(r))
%    rl_ol(:,2*i-1) = (real(r(i,:))).';
%    rl_ol(:,2*i) = (imag(r(i,:))).'; 
% end
% 
% % Obtain closed loop poles
% [r_cl, k_cl] = rlocus(Gol, 1);
% 
% for i=1:length(r_cl)
%    rl_ol(:,2*(min(size(r))+i)-1) = real(r_cl(i));
%    rl_ol(:,2*(min(size(r))+i)) = imag(r_cl(i)); 
% end
% 
% % Write to CSV file with column names
% % Plant
% rl_names = strings(1, 2*min(size(r_plant)));
% for i=1:min(size(r_plant))
%    rl_names(2*i-1) = "pr" + i;
%    rl_names(2*i) = "pi" + i;
% end
% % Open loop
% rl_names_cl = strings(1, 4*min(size(r))); % Includes closed loop poles
% for i=1:min(size(r))
%    rl_names_cl(2*i-1) = "pr" + i;
%    rl_names_cl(2*i) = "pi" + i;
% end
% % Closed loop poles
% for i=1:min(size(r))
%     rl_names_cl(2*(min(size(r))+i)-1) = "clr" + i;
%     rl_names_cl(2*(min(size(r))+i)) = "cli" + i; 
% end
% 
% filename_plant = "controller_design/rlocus_plant.csv";
% filename_design = "controller_design/rlocus_design.csv";
% writematrix([rl_names; rl_plant], filename_plant);
% writematrix([rl_names_cl; rl_ol], filename_design);
% 
% % Step response
% step_sim_time = 5*15;
% step_sim_freq = 250;
% step_time = 1;
% 
% disturb = 0;
% disturb_time = 8;
% disturb_val = 0.01;
% 
% log_start_time = 0.1;
% log = step_time*step_sim_freq - log_start_time*step_sim_freq;
% 
% ctrl = sim("controller_design/controller_design_step.slx");
% 
% dwn_smple = 15;
% filename_step = "controller_design/rstep.csv";
% writematrix(["time", "input", "p", "pi", "pid"; downsample(ctrl.ctrl.time(log:end), dwn_smple), downsample(ctrl.ctrl.data(log:end,1), dwn_smple), downsample(ctrl.ctrl.data(log:end,2), dwn_smple), downsample(ctrl.ctrl.data(log:end,3), dwn_smple), downsample(ctrl.ctrl.data(log:end,4), dwn_smple)], filename_step);
