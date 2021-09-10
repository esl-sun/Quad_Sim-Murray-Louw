%% Initialise variables for LQR velocity control for honeybee quad

% Fran states = [Int(Vn_sp - Vn), Int(Ve_sp - Ve), Vn, Ve, dphi, phi, dtheta, theta]    
% states = [Int(Vn_sp - Vn), Vn, theta, dtheta]    

% g = positive = 9.81

% Run FFT to calculate pendulum length
% frst run: estimate_pendulum_length.m
% l_est = estimated length

% same format as lqr_cartpend from Steve Brunton control bootcamp youtube
% Int(Vn_sp - Vn), Vn,      theta,                  dtheta]

% c_lqr = 0.08; % rotatioal damping
c_lqr = c; % rotatioal damping
c_linear = 0.2; % linear velocity damping
% l_est = 1.1
% l_est = 0.5
% mq_lqr = 0.796;
% mp_lqr = (mp+mq)-mq_lqr

LQR.A= [    
            0       -1          0                           0;
            0       -c_linear/mq_lqr       mp_lqr*g/mq_lqr                     c_lqr/(l_est*mq_lqr);
            0       0           0                           1;
            0       c_linear/(mq_lqr*l_est)     -1*(mp_lqr+mq_lqr)*g/(mq_lqr*l_est)     -c_lqr*(mp_lqr+mq_lqr)/(l_est^2*mq_lqr*mp_lqr)
        ];


          % Fn
LQR.B = [
            0; 
            1/mq_lqr; 
            0; 
            -1/(mq_lqr*l_est)
        ];

%Q_lqr = diag([50*0.5 50*0.5 50*1 50*1 2/100 3/100 2/100 3/100]); %50 50 /100 /100 /100
%R_lqr = 3*diag([1 1]); %3 %%5 met 100 werk ook goed
%%Q_lqr = diag([1/(15^2) 1/(15^2) 1/(12^2) 1/(12^2) 2/((180*2*pi)^2) 3/((180*2*pi)^2) 2/((180*2*pi)^2) 3/((180*2*pi)^2)]);
%%R_lqr = diag([1/(max_total_T^2) 1/(max_total_T^2)]);

% states = [Int(Vn_sp - Vn), Vn, theta, dtheta]
integrator_weight = 0.2;
LQR.Q = diag([integrator_weight 10 0 100]); % State weights
LQR.R = 13; % Input weights
LQR.K = lqr(LQR.A, LQR.B, LQR.Q, LQR.R)
%K = lqrd(Ass_aug, Bss_aug, Q_lqr, R_lqr, 1/sim_freq);

% disp('RUNNING SIM FROM init_mpc.')
% tic
% out = sim('quad_simulation_with_payload.slx')
% toc

% mpc_vs_lqr_vs_pid_to_csv





