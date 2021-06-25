%% Initialise mpc for quad simulation.
% (ensure havok or dmd models have been loaded before this script)

% Internal plant model
model_file = [uav_folder, '/models/havok_model_', simulation_data_file, '_q', num2str(q), '_p', num2str(p), '.mat'];
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

% Add Unmeasured Disturbance
% B_mpc = [B_mpc, zeros(size(B_mpc,1), 1)];
% B_mpc(1,2) = 1e-2; % Unmeasured Disturbance only affects position

% Other state matrices
C_mpc = eye(size(A_mpc,1));
D_mpc = zeros(size(A_mpc,1), size(B_mpc,2));

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

switch control_vel_axis
    case 'x'
        not_controlled_sp = zeros(1,2); % Velocity and Payload angle setpoint (which are not controlled) to add to reference vector for MPC
    case 'xy'
        not_controlled_sp = zeros(1,4); % 2 x Velocity  and  2 x Payload angle setpoint (which are not controlled) to add to reference vector for MPC
end

% MPC object
old_status = mpcverbosity('off'); % No display messages
mpc_sys.OutputGroup.UO = 1:num_axis; % Measured Output. Top row of matrix is unmeasured angular velocity
mpc_sys.OutputGroup.MO = num_axis + (1:q*ny); % Measured Output

mpc_sys.InputGroup.MV = 1:nu; % Munipulated Variable indices
% mpc_sys.InputGroup.UD = 2; % Unmeasured disturbance at channel 2

tuning_weight = 1; % Tuning weight for mv and mv rate together. Smaller = robust, Larger = aggressive
mo_weight = 1; % Scale all MV

pos_weight = 1; % Position tracking weight
vel_weight = 0; % Velocity tracking weight
theta_weight = 0; % Payload swing angle. Larger = less swing angle, Smaller = more swing
dtheta_weight = 0; % Derivative of Payload swing angle

mv_weight = 1e-5; % Tuning weight for manipulated variables only (Smaller = aggressive, Larger = robust)
mvrate_weight = 1e-3; % Tuning weight for rate of manipulated variables (Smaller = aggressive, Larger = robust)

mpc_vel = mpc(mpc_sys,Ts_mpc);

% Manually set covariance
x_mpc = mpcstate(mpc_vel); % Initial state
% covariance = zeros(size(x_mpc.Covariance));
% % covariance(1:ny, 1:ny) = diag([1e-3, 1e-3, 1e-3, 1e-4, 1e-4]); % Manually tune uncertainty of each state                                               pos   vel    theta
% covariance(1:ny+num_axis, 1:ny+num_axis) = diag([1e2, 1e-4, 1e-4]); % Uncertainty of each measured state
% x_mpc = mpcstate(mpc_vel, [], [], [], [], covariance);

Ty = 5; % Prediction period, For guidance, minimum desired settling time (s)
Tu = 5; % Control period, desired control settling time
mpc_vel.PredictionHorizon  = floor(Ty/Ts_mpc); % t_s/Ts_mpc; % Prediction horizon (samples), initial guess according to MATLAB: Choose Sample Time and Horizons
mpc_vel.ControlHorizon     = floor(Tu/Ts_mpc); % Control horizon (samples)

% mpc_vel.Weights.OutputVariables        = [1, 1, 1, 10, 10, zeros(1, (q-1)*ny)]*tuning_weight;

mpc_vel.Weights.OutputVariables = mo_weight*tuning_weight*  [ ...  
                                        dtheta_weight*ones(1,num_axis), 
                                        pos_weight*   ones(1, num_axis), 
                                        pos_weight*   ones(1,num_axis), 
                                        theta_weight* ones(1, (ny-nu) ), 
                                        zeros(1, (q-1)*ny)
                                                            ];

% mpc_vel.Weights.ManipulatedVariables   = mv_weight*[1, 1, 1]*tuning_weight;
mpc_vel.Weights.ManipulatedVariables   = mv_weight*ones(1,nu)*tuning_weight;

% mpc_vel.Weights.ManipulatedVariablesRate     = mvrate_weight*[1, 1, 1]/tuning_weight;
mpc_vel.Weights.ManipulatedVariablesRate     = mvrate_weight*ones(1,nu)/tuning_weight;

% adjust input disturbance model gains
% alpha = 0.302;
% setindist(mpc_vel, 'model', getindist(mpc_vel)*alpha);

% disp('RUNNING SIM FROM init_mpc.')
% out = sim('quad_simulation_with_payload.slx')
