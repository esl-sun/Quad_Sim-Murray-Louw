

%%
wp = 2+[0 0 0 0 0 0 5*ones(1, 60) ];

% Init
Ty = 8; % prediction horizon period
PH = floor(Ty/Ts_mpc); % Prediction Horizon
prev_pos_sp = NaN;
previous_traj = wp(1)*ones(1,PH);

% Limits
V = 20; % max velocity
A = 20; % max acceleration
Tj = 1; % Jerk time

for k = 1:20
    % Inputs
    pos_sp = wp(k);
    
    % function
    [ref, traj] = generate_trajectory(pos_sp, prev_pos_sp, previous_traj, V, A, Tj, Ts_mpc, PH, num_refs);

    figure(1)
    plot(traj)
%     xlim([0 52])
    ylim([0 8])
    pause
    
    % memory
    prev_pos_sp = wp(k);
    previous_traj = traj;
    
end

function [ref, pos_traj] = generate_trajectory(pos_sp, prev_pos_sp, prev_traj, V, A, Tj, Ts_mpc, PH, num_refs)
%% Genrate jerk, acceleration and velocity limited position trajectory for MPC block in Simulink

% pos_traj = X position trajectory limited by jerk time, max acceleration and max velocity
% ref  = Reference signal for MPC. Each row represents a state, each next entry in the row
%        is the setpoint for that state at progressive time-steps

% pos_sp        = X position setpoint
% prev_pos_sp   = Previous timestep X position setpoint
% prev_traj     = previous timestep x position trajectory
% V             = max velocity
% A             = max acceleration
% Tj            = jerk time (time to start of decelleration on s curve)
% Ts_mpc        = Sample time of MPC
% PH            = prediction horizon of MPC
% num_refs      = number of reference rows required by MPC

% num_refs = Number of references needed by MPC

% Check for conditions not suported yet
if length(pos_sp) ~= 1
    error("Still need to add support for traj gen with more than one axis")
end

P = pos_sp - prev_pos_sp; % Step distance to travel

if abs(pos_sp - prev_pos_sp) > 1e-2 % Step occured if threshold breached

    % [Y,T] = GenTraj(A,V,P,Tj,Ts_mpc); % generate new traj
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% GenTraj.m
    
    % force Tj to multiple of Ts_mpc
    Tj = floor(Tj/Ts_mpc)*Ts_mpc;

    % Verification of the acceleration and velocity constraints  
    Ta = V/A; % Acceleration time
    Tv = (P - A*Ta^2) / (V); % Constant velocity time
    if P <= Ta*V % Triangular velocity profile
        Tv = 0;
        Ta = sqrt(P/A);
    end
    Tf = 2*Ta + Tv + Tj; % Mouvement time

    % Elaboration of the limited acceleration profile 
    T = 0:Ts_mpc:Tf;

    % Pre-allocate memory
    t = zeros(1,4); 
    s = zeros(1,4);
    law = zeros(4,length(T));
    Y = zeros(3,length(T));

    t(1)=0; t(2)=Ta; t(3)=Ta+Tv; t(4)=2*Ta+Tv;
    s(1)=1; s(2)=-1; s(3)=-1; s(4)=1;

    % P=zeros(3,length(T));
    % Ech=zeros(4);
    for k = 1:3
        u = zeros(1,k+1);
        u(1,1) = 1;
        for i = 1:4
            Ech = tf(1, u,'inputdelay',t(i));
            law(i,:) = impulse(s(i)*A*(Ech),T);
        end
        Y(k,:) = sum(law);
    end

    % Average Filter for Jerk limitation
    a = 1;      % Filter coefficients
    b = (1/(Tj/Ts_mpc))*ones(1,(Tj/Ts_mpc)); % Filter duration equal to jerk time
    Y(3,:) = filter(b,a,Y(3,:)); % Acceleration
    Y(2,1:length(T)-1) = diff(Y(3,:),1)/Ts_mpc; % Velocity
    Y(1,1:length(T)-1) = diff(Y(2,:),1)/Ts_mpc; % Position
    
    %%%%%%%%%%%%%%%%%%%%%%%%%

    if T(end) > Ts_mpc*PH % Check if full traj fits in PH
        error("Add support: End of trajectory will be cut off because S-trajectory not complete within Prediction Horizon")
    end
    pos_traj = prev_pos_sp + Y(3, 2:end); % previous position + step trajectory sp. Remove first entry because setpoint starts from future time step
    
elseif size(prev_traj,2) == 1 % Constant ref at current position
    pos_traj = prev_traj; % feed through
    
else % Complete current trajectory
    pos_traj = prev_traj(:, 2:end); % delete timestep that passed
end

% Fill or cut trajectory to have constant length
if length(pos_traj) < PH % Append entries
    fill_traj = pos_traj(:,end)*ones(1, PH - length(pos_traj)); % Fill length of traj with last value
    pos_traj = [pos_traj, fill_traj]; % Add end of traj
% TODO: Fix this. If PH is shorter than generated traj, a cutoff traj is propogated
    % else % Remove excess entries
%     length_diff = length(traj) - PH;
%     traj = traj(:, 1:(end - length_diff));
end

% Add zeros for references/setpoints of other states and fill rows of MPC
% matrix signal
% ref(:,1) = [dtheta_sp(k+1), pos_sp(k+1), vel_sp(k+1), theta_sp(k+1), delay states...]
ref = zeros(num_refs, PH); % Matrix signal always same size
ref(2,:) = pos_traj; % Assign pos row to traj

end