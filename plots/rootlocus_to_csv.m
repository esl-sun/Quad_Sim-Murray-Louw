%% Convert rootlocus data to csv for tikz in Thesis
% first run specific section in rootlocus.m

% Transfer functions
s = tf('s');
G = G_vn_ol;
D = D_vn;

[G_NUM, G_DENOM] = tfdata(G, 'v');

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

Gol = G*D;

% Root locus data
[r_plant, gain_plant] = rlocus(G); % Poles and zeros of open loop system
[r, gain] = rlocus(Gol); % Poles and zeros of closed loop system
[Z, K] = zero(Gol); % Gain K
stop
% Obtain real and imaginary parts
% Plant
rl_plant = zeros(length(r_plant), 2*min(size(r_plant)));
for i=1:min(size(r_plant))
   rl_plant(:,2*i-1) = (real(r_plant(i,:))).';
   rl_plant(:,2*i) = (imag(r_plant(i,:))).'; 
end
% Open loop
rl_ol = zeros(length(r), 4*min(size(r))); % Will include closed loop poles
for i=1:min(size(r))
   rl_ol(:,2*i-1) = (real(r(i,:))).';
   rl_ol(:,2*i) = (imag(r(i,:))).'; 
end

% Obtain closed loop poles
[r_cl, k_cl] = rlocus(Gol, 1);

for i=1:length(r_cl)
   rl_ol(:,2*(min(size(r))+i)-1) = real(r_cl(i));
   rl_ol(:,2*(min(size(r))+i)) = imag(r_cl(i)); 
end

% Write to CSV file with column names
% Plant
rl_names = strings(1, 2*min(size(r_plant)));
for i=1:min(size(r_plant))
   rl_names(2*i-1) = "pr" + i;
   rl_names(2*i) = "pi" + i;
end
% Open loop
rl_names_cl = strings(1, 4*min(size(r))); % Includes closed loop poles
for i=1:min(size(r))
   rl_names_cl(2*i-1) = "pr" + i;
   rl_names_cl(2*i) = "pi" + i;
end
% Closed loop poles
for i=1:min(size(r))
    rl_names_cl(2*(min(size(r))+i)-1) = "clr" + i;
    rl_names_cl(2*(min(size(r))+i)) = "cli" + i; 
end

filename_plant = "controller_design/rlocus_plant.csv";
filename_design = "controller_design/rlocus_design.csv";
writematrix([rl_names; rl_plant], filename_plant);
writematrix([rl_names_cl; rl_ol], filename_design);

% Step response
step_sim_time = 5*15;
step_sim_freq = 250;
step_time = 1;

disturb = 0;
disturb_time = 8;
disturb_val = 0.01;

log_start_time = 0.1;
log = step_time*step_sim_freq - log_start_time*step_sim_freq;

ctrl = sim("controller_design/controller_design_step.slx");

dwn_smple = 15;
filename_step = "controller_design/rstep.csv";
writematrix(["time", "input", "p", "pi", "pid"; downsample(ctrl.ctrl.time(log:end), dwn_smple), downsample(ctrl.ctrl.data(log:end,1), dwn_smple), downsample(ctrl.ctrl.data(log:end,2), dwn_smple), downsample(ctrl.ctrl.data(log:end,3), dwn_smple), downsample(ctrl.ctrl.data(log:end,4), dwn_smple)], filename_step);
