%% Initialise mpc for quad simulation.
% (ensure havok or dmd models have been loaded before this script)

% Internal plant model
% model_file = [uav_folder, '/models/havok_model_', simulation_data_file, '_q', num2str(q), '_p', num2str(p), '.mat'];
choose_model = 1
if choose_model
    if use_sitl_data
        start_folder = [pwd, '/system_id/SITL/*.mat'];
    else
        start_folder = [pwd, '/system_id/Simulink/*.mat'];
    end
    [model_file_name, model_parent_dir] = uigetfile(start_folder, '[init_mpc.m] Choose MODEL .mat file to use for mpc')
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
        A = [A_top; A_bottom]; % A matrix for MPC
        
        B = [ B_dmd(:, ((q-1)*ny+1):end); zeros((q-1)*ny, nu)]; % B matrix for MPC

    case 'havok'
        A = A_havok;
        B = B_havok;
end

%% Add payload angular velocity for MPC
A_mpc = [zeros( num_axis, size(A,2) ); A]; % Add top row zeros
A_mpc = [zeros( size(A_mpc,1), num_axis ), A_mpc]; % Add left column zeros
B_mpc = [zeros( num_axis, size(B,2) ); B]; % Add top row zeros

% Numeric differentiation: dtheta(k+1) approx.= dtheta(k) = 1/Ts*theta(k) - 1/Ts*theta(k-1)
A_mpc(1:num_axis, 2*num_axis+(1:num_axis)) =  1/Ts*eye(num_axis); % 1/Ts*theta(k)
A_mpc(1:num_axis, 4*num_axis+(1:num_axis)) = -1/Ts*eye(num_axis); % - 1/Ts*theta(k-1)
%  A_mpc(1:num_axis, 3*num_axis+(1:num_axis)) =  1/Ts*eye(num_axis); % 1/Ts*theta(k)
%  A_mpc(1:num_axis, 5*num_axis+(1:num_axis)) = -1/Ts*eye(num_axis); % - 1/Ts*theta(k-1)

Ts_mpc = Ts;

% State vector = [dtheta(k), v(k), theta(k), v(k-1), theta(k-1), ...]

% Add Unmeasured Input Disturbance
B_mpc = [B_mpc, zeros(size(B_mpc,1), 1)];
B_mpc(2,2) = 1e-2; % Unmeasured Disturbance only affects v(k)

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

% mpc_sys.OutputGroup.MO = (1:q*ny); % Measured Output

% Use dtheta as unmeasured output
mpc_sys.OutputGroup.UO = 1:num_axis; % Unmeasured payload anglular velocity
mpc_sys.OutputGroup.MO = num_axis + 1:(q*ny); % Measured Output

mpc_sys.InputGroup.MV = 1:nu; % Munipulated Variable indices
mpc_sys.InputGroup.UD = 2; % Unmeasured disturbance at channel 2

tuning_weight = 1; % Tuning weight for mv and mv rate together. Smaller = robust, Larger = aggressive
mo_weight = 1; % Scale all MV

vel_weight = 1.5; % Velocity tracking weight
theta_weight = 0; % Payload swing angle. Larger = less swing angle, Smaller = more swing
dtheta_weight = 15; % Derivative of Payload swing angle

mv_weight = 0.1; % Tuning weight for manipulated variables only (Smaller = aggressive, Larger = robust)
mvrate_weight = 10; % Tuning weight for rate of manipulated variables (Smaller = aggressive, Larger = robust)

mpc_vel = mpc(mpc_sys,Ts_mpc);

% Manually set covariance
x_mpc = mpcstate(mpc_vel); % Initial state
% covariance = zeros(size(x_mpc.Covariance));
% covariance(1:ny, 1:ny) = diag([1e-3, 1e-3, 1e-3, 1e-4, 1e-4]); % Manually tune uncertainty of each state                                               pos   vel    theta
% covariance(1:ny+2*num_axis, 1:ny+2*num_axis) = diag([1e-1, 1e-1, 1e-5, 1e-5]); % Uncertainty of each measured state
% x_mpc = mpcstate(mpc_vel, [], [], [], [], covariance);

Ty = 8; % Prediction period, For guidance, minimum desired settling time (s)
Tu = 4; % Control period, desired control settling time
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

mpc_vel.PredictionHorizon  = PH; % t_s/Ts_mpc; % Prediction horizon (samples), initial guess according to MATLAB: Choose Sample Time and Horizons
mpc_vel.ControlHorizon     = CH; % Control horizon (samples)

% mpc_vel.Weights.OutputVariables        = [1, 1, 1, 10, 10, zeros(1, (q-1)*ny)]*tuning_weight;

mpc_vel.Weights.OutputVariables = mo_weight*tuning_weight*  [ ...  
                                        dtheta_weight* ones(1,num_axis), ...
                                        vel_weight*    ones(1,num_axis), ...
                                        theta_weight*  ones(1, (ny-nu) ), ...
                                                       zeros(1, (q-1)*ny) ...
                                                            ];

% mpc_vel.Weights.ManipulatedVariables   = mv_weight*[1, 1, 1]*tuning_weight;
mpc_vel.Weights.ManipulatedVariables   = mv_weight*ones(1,nu)*tuning_weight;

% mpc_vel.Weights.ManipulatedVariablesRate     = mvrate_weight*[1, 1, 1]/tuning_weight;
mpc_vel.Weights.ManipulatedVariablesRate     = mvrate_weight*ones(1,nu)/tuning_weight;

% Constraints
% mpc_vel.OV(2).Max = 5.2;

% mpc_vel.MV(1).RateMin = -6;
% mpc_vel.MV(1).RateMax = 6;

% adjust input disturbance model gains
% alpha = 0.302;
% setindist(mpc_vel, 'model', getindist(mpc_vel)*alpha);

% Trajectory generation variables
step_size = 5; % Pos step size for trajectory generation
traj_stop_time = 4; % Time to zero velocity in step response
% max_vel = 20; % Max x acceleration allowed
% max_acc = 20; % Max x velocity allowed
% jerk_time = 3; % Jerk time allowed (time to deccelleration on s-trajectory)
num_refs = size(A_mpc,1); % Number of reference rows required. 2 extras references (dtheta, pos) for each controlled axis

% [traj_Y,traj_T] = GenTraj(max_acc, max_vel, step_size, jerk_time, Ts_mpc); % pre-generate new traj, becuase not supported by code generation
% pos_traj = traj_Y(3,2:end); % Remove first entry because setpoint starts from future time step  

pos_traj_time = 0:Ts_mpc:traj_stop_time;
pos_traj_xyz = min_jerk(0, step_size, pos_traj_time); % Outputs minimum jerk trajectory for x,y,z as columns
pos_traj = pos_traj_xyz(:,1)'; % Only x step trajectory

% Fill or cut trajectory to have constant length
if length(pos_traj) < PH % Append entries
    fill_traj = pos_traj(:,end)*ones(1, PH - length(pos_traj)); % Fill length of traj with last value
    pos_traj = [pos_traj, fill_traj]; % Add end of traj
end
pre_generated_traj = pos_traj; % Generate pos x trajectory for single step size

disp('RUNNING SIM FROM init_mpc.')
tic
out = sim('quad_simulation_with_payload.slx')
toc
