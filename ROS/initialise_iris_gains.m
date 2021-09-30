%% Controller gains for iris multicopter

% North and East controller gains
MPC_XY_VEL_P_ACC = 1.8;
MPC_XY_VEL_I_ACC = 0.4;
MPC_XY_VEL_D_ACC = 0.2;

% Down controller gains
MPC_Z_VEL_P_ACC = 4;
MPC_Z_VEL_I_ACC = 2;
MPC_Z_VEL_D_ACC = 0;

% Saturation limits
max_vel_xy = 5;
max_vel_z_up = 5;
max_vel_z_down = 5;

MPC_ACC_HOR_MAX = 5; 
MPC_ACC_DOWN_MAX = 3;
MPC_ACC_UP_MAX = 4;

% D term filter
vel_dterm_cutoff = 40; %Hz
[vel_filt_num, vel_filt_denom] = discrete_lpf_filter(vel_dterm_cutoff, 1/Ts_sim);

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
