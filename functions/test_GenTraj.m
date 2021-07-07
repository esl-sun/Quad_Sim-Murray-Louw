

%%
wp = 2+[0 0 0 0 0 0 0, 5*ones(1, 60) ]
TT = 0.03:0.03:floor(Ty/Ts_mpc)*Ts_mpc

% Init
Ty = 2; % prediction orizon period
PH = floor(Ty/Ts_mpc); % Prediction Horizon
prev_pos_sp = NaN
previous_traj = wp(1)*ones(1,PH);

% Limits
V = 20; % max velocity
A = 20; % max acceleration
Tj = 1; % Jerk time

for k = 1:length(wp)
    % Inputs
    pos_sp = wp(k)
    
    % function
    [ref, traj] = generate_trajectory(pos_sp, prev_pos_sp, previous_traj, V, A, Tj, PH, num_refs);
    
    figure(1)
    plot(TT,traj)
    xlim([0 52])
    ylim([0 8])
    TT = TT + Ts_mpc;
    pause
    
    % memory
    prev_pos_sp = wp(k);
    previous_traj = traj;
    
end

function [ref, traj] = generate_trajectory(pos_sp, prev_pos_sp, previous_traj, V, A, Tj, PH, num_refs)

% traj = X position trajectory limited by jerk time, max acceleration and max velocity
% ref  = Reference signal for MPC. Each row represents a state, each next entry in the row
%        is the setpoint for that state at progressive time-steps
% num_refs = Number of references needed by MPC

% Check for conditions not suported yet
if length(pos_sp) ~= 1
    error("Still need to add support for traj gen with more than one axis")
end

P = pos_sp - prev_pos_sp; % Step distance to travel
T = NaN
if abs(pos_sp - prev_pos_sp) > 1e-2 % Step occured if threshold breached
    [Y,T] = GenTraj(A,V,P,Tj); % generate new traj
    if T(end) > PH % Check if full traj fits in PH
        error("Add support: End of trajectory will be cut off because S-trajectory not complete within Prediction Horizon")
    end
    traj = prev_pos_sp + Y(3, 2:end); % previous position + step trajectory sp. Remove first entry because setpoint starts from future time step
    
elseif size(previous_traj,2) == 1 % Constant ref at current position
    traj = previous_traj; % feed through
    
else % Complete current trajectory
    traj = previous_traj(:, 2:end); % delete timestep that passed
end

% Fill or cut trajectory to have constant length
if length(traj) < PH % Append entries
    fill_traj = traj(:,end)*ones(1, PH - length(traj)); % Fill length of traj with last value
    traj = [traj, fill_traj]; % Add end of traj
% TODO: Fix this. If PH is shorter than generated traj, a cutoff traj is propogated
    % else % Remove excess entries
%     length_diff = length(traj) - PH;
%     traj = traj(:, 1:(end - length_diff));
end

% Add zeros for references/setpoints of other states and fill rows of MPC
% matrix signal
% ref(:,1) = [dtheta_sp(k+1), pos_sp(k+1), vel_sp(k+1), theta_sp(k+1), delay states...]
ref = zeros(num_refs, PH); % Matrix signal always same size
ref(2,:) = traj; % Assign pos row to traj

end