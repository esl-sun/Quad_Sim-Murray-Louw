%% Initialise mpc for quad simulation.
% (ensure havok or dmd models have been loaded before this script)

% Internal plant model
model_file = ['system_id/', uav_name, '/models/havok_model_', simulation_data_file, '_q', num2str(q), '_p', num2str(p), '.mat'];
load(model_file) % Load plant model from saved data

model = 'havok'; % Choose which model to use for MPC
switch model
    case 'dmd'
        
    case 'havok'
%         load('Data/havoc_model_5.mat')
        A_mpc  = A_havok;
        B_mpc  = B_havok;
        Ts_mpc = Ts_havok;
end

% Can add UD and CO if needed

C_mpc = eye(q*ny);
D_mpc = zeros(q*ny, nu);

mpc_sys = ss(A_mpc,B_mpc,C_mpc,D_mpc,Ts_mpc); % LTI system

% Initital conditions for extended measurment vector for MPC
% All delay states are also at y0
y0 = zeros(ny,1);
y_ext_0 = zeros(q*ny, 1); % Allocate space
for row = 0:q-1 % First column of spaced Hankel matrix
        y_ext_0(row*ny+1:(row+1)*ny, 1) = y0;
end

delays_0 = []; % Initial delay vector
for i = 1:q-1
    delays_0 = [delays_0; y0];
end

payload_angle_ref = zeros(1,2); % Payload angle setpoint to add to reference vector for MPC

% MPC object
old_status = mpcverbosity('off'); % No display messages
mpc_sys.OutputGroup.MO = 1:q*ny; % Measured Output

mpc_sys.InputGroup.MV = 1:nu; % Munipulated Variable indices

tuning_weight = 1e-1; % Tuning weight for mv and mv rate together. Smaller = robust, Larger = aggressive
mv_weight = 1e-0; % Tuning weight for manipulated variables only
mvrate_weight = 1e-0; % Tuning weight for rate of manipulated variables only
mpc_vel = mpc(mpc_sys,Ts_mpc);

% Manually set covariance
x_mpc = mpcstate(mpc_vel); % Initial state
% covariance = zeros(size(x_mpc.Covariance));
% covariance(1:ny, 1:ny) = diag([1e-3, 1e-3, 1e-3, 1e-4, 1e-4]); % Manually tune uncertainty of each state
% covariance(1:ny, 1:ny) = diag(1e-3*ones(1,ny)); % Uncertainty of each measured state
% x_mpc = mpcstate(mpc_vel, [], [], [], [], covariance);

Ty = 6; % Prediction period, For guidance, minimum desired settling time (s)
Tu = 3; % Control period, desired control settling time
mpc_vel.PredictionHorizon  = floor(Ty/Ts_mpc); % t_s/Ts_mpc; % Prediction horizon (samples), initial guess according to MATLAB: Choose Sample Time and Horizons
mpc_vel.ControlHorizon     = floor(Tu/Ts_mpc); % Control horizon (samples)

% mpc_vel.Weights.OutputVariables        = [1, 1, 1, 10, 10, zeros(1, (q-1)*ny)]*tuning_weight;
mpc_vel.Weights.OutputVariables        = [ones(1,nu), zeros(1, (q-1)*ny)]*tuning_weight;

% mpc_vel.Weights.ManipulatedVariables   = mv_weight*[1, 1, 1]*tuning_weight;
mpc_vel.Weights.ManipulatedVariables   = mv_weight*ones(1,nu)*tuning_weight;

% mpc_vel.Weights.ManipulatedVariablesRate     = mvrate_weight*[1, 1, 1]/tuning_weight;
mpc_vel.Weights.ManipulatedVariablesRate     = mvrate_weight*ones(1,nu)/tuning_weight;
