%% create MPC controller object with sample time
mpc_vel = mpc(mpc_sys, 0.03);
%% specify prediction horizon
mpc_vel.PredictionHorizon = 166;
%% specify control horizon
mpc_vel.ControlHorizon = 166;
%% specify nominal values for inputs and outputs
mpc_vel.Model.Nominal.U = [0;0];
mpc_vel.Model.Nominal.Y = [0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0];
%% specify weights
mpc_vel.Weights.MV = 1.5e-08;
mpc_vel.Weights.MVRate = 0.333333333333333;
mpc_vel.Weights.OV = [1.5 0 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
mpc_vel.Weights.ECR = 100000;
%% specify overall adjustment factor applied to estimation model gains
alpha = 0.302;
%% adjust default input disturbance model gains
setindist(mpc_vel, 'model', getindist(mpc_vel)*alpha);
%% adjust default output disturbance model gains
setoutdist(mpc_vel, 'model', getoutdist(mpc_vel)*alpha);
%% adjust default measurement noise model gains
mpc_vel.Model.Noise = mpc_vel.Model.Noise/alpha;
%% specify simulation options
options = mpcsimopt();
options.RefLookAhead = 'off';
options.MDLookAhead = 'off';
options.Constraints = 'on';
options.OpenLoop = 'off';
%% run simulation
% sim(mpc_vel, 334, mpc_vel_RefSignal, mpc_vel_MDSignal, options);
