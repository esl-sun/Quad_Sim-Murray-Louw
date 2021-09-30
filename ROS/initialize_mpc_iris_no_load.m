%% Initialise mpc for quad simulation.
% (ensure havok or dmd models have been loaded before this script)

% Internal plant model
% model_file = [uav_folder, '/models/havok_model_', simulation_data_file, '_q', num2str(q), '_p', num2str(p), '.mat'];
choose_model = 1
if choose_model
    start_folder = [pwd, '/system_id/HITL/iris/models/*.mat'];
    [model_file_name, model_parent_dir] = uigetfile(start_folder, '[init_mpc_iris_no_load.m] Choose MODEL .mat file to use for mpc')
    model_file = (strcat(model_parent_dir, '/', model_file_name));
    load(model_file) % Load plant model from saved data
end

if strcmp(model_file_name(1:3), 'dmd') % Check what type of algorithm is model
    algorithm = 'dmd'
else
    algorithm = 'havok'
end

switch algorithm
    case 'dmd'
        
        %% Convert to form with state vector including delays like HAVOK model
        A_d = B_dmd(:, 1:(q-1)*ny); % Delay state matrix as per thesis discription
        
        A_top    = [A_dmd, A_d]; % First ny rows of state matrix for MPC
        A_bottom = [eye( (q-1)*ny ), zeros( (q-1)*ny, ny )]; % Bottom rows of matrix to propogate delay coordinates to new position
        A_mpc = [A_top; A_bottom]; % A matrix for MPC
        
        B_mpc = [ B_dmd(:, ((q-1)*ny+1):end); zeros((q-1)*ny, nu)]; % B matrix for MPC

    case 'havok'
        A_mpc = A_havok;
        B_mpc = B_havok;
end

Ts_mpc = Ts;

% %% Add payload angular velocity for MPC
% A_mpc = [zeros( num_axis, size(A_mpc,2) ); A_mpc]; % Add top row zeros
% A_mpc = [zeros( size(A_mpc,1), num_axis ), A_mpc]; % Add left column zeros
% B_mpc = [zeros( num_axis, size(B_mpc,2) ); B_mpc]; % Add top row zeros

% Numeric differentiation: dtheta(k+1) approx.= dtheta(k) = 1/Ts*theta(k) - 1/Ts*theta(k-1)
% A_mpc(1:num_axis, 2*num_axis+(1:num_axis)) =  1/Ts*eye(num_axis); % 1/Ts*theta(k)
% A_mpc(1:num_axis, 4*num_axis+(1:num_axis)) = -1/Ts*eye(num_axis); % - 1/Ts*theta(k-1)

% State vector = [dtheta(k), v(k), theta(k), v(k-1), theta(k-1), ...]

% Add Unmeasured Input Disturbance
B_mpc = [B_mpc, zeros(size(B_mpc,1), 1)];
B_mpc(2,2) = 1; % Unmeasured Disturbance only affects v(k)

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

% Use dtheta as unmeasured output
mpc_sys.OutputGroup.UO = 1:num_axis; % Unmeasured payload anglular velocity
mpc_sys.OutputGroup.MO = num_axis + 1:(q*ny); % Measured Output

mpc_sys.InputGroup.MV = 1:nu; % Munipulated Variable indices
mpc_sys.InputGroup.UD = 2; % Unmeasured disturbance at channel 2

mo_weight = 1; % Scale all MO variables

vel_weight = 2; % Velocity tracking weight
% theta_weight = 0; % Payload swing angle. Larger = less swing angle, Smaller = more swing
% dtheta_weight = 10; % Derivative of Payload swing angle

tuning_weight = 1; % Tune relationship between inputs and outputs simueltaneously
mv_weight = 0.1; % Tuning weight for manipulated variables only (Smaller = aggressive, Larger = robust)
mvrate_weight = 10; % Tuning weight for rate of manipulated variables (Smaller = aggressive, Larger = robust)

mpc_iris_no_load = mpc(mpc_sys,Ts_mpc);

% Manually set covariance
x_mpc = mpcstate(mpc_iris_no_load); % Initial state
% covariance = zeros(size(x_mpc.Covariance));
% covariance(1:ny, 1:ny) = diag([1e-3, 1e-3, 1e-3, 1e-4, 1e-4]); % Manually tune uncertainty of each state                                               pos   vel    theta
% covariance(1:ny+2*num_axis, 1:ny+2*num_axis) = diag([1e-1, 1e-1, 1e-5, 1e-5]); % Uncertainty of each measured state
% x_mpc = mpcstate(mpc_vel, [], [], [], [], covariance);

Ty = 5; % Prediction period, For guidance, minimum desired settling time (s)
Tu = 3.5; % Control period, desired control settling time
PH = floor(Ty/Ts_mpc); % Prediction horizon
CH = floor(Tu/Ts_mpc); % Control Horizon

% Must meet this codition: PH - CH > (q-1) (P - M > T in review(mpc_vel) report)
if (PH - CH <= (q-1))
    PH
    CH
    q
    'Warning: Should meet this condition: PH - CH > (q-1)'
%     error('Should meet this condition: PH - CH > (q-1)')
end

mpc_iris_no_load.PredictionHorizon  = PH; % t_s/Ts_mpc; % Prediction horizon (samples), initial guess according to MATLAB: Choose Sample Time and Horizons
mpc_iris_no_load.ControlHorizon     = CH; % Control horizon (samples)
%%
mpc_iris_no_load.Weights.OutputVariables = mo_weight*tuning_weight*  [ ...  
                                        vel_weight*    ones(1,num_axis), ...
                                                       zeros(1, (q-1)*ny) ...
                                                            ];

mpc_iris_no_load.Weights.ManipulatedVariables   = mv_weight*ones(1,nu)*tuning_weight;
mpc_iris_no_load.Weights.ManipulatedVariablesRate     = mvrate_weight*ones(1,nu)/tuning_weight;

