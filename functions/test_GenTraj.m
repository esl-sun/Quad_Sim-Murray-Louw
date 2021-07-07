

%%
wp = 2 + [0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 ]

% Init
previous_wp = NaN
previous_traj = 0*(1:4);

for k = 1:length(wp)
    % Inputs
    current_wp = wp(k)
    
    % function
    traj = generate_trajectory(current_wp, previous_wp, previous_traj)
    
    plot(traj)
    
    % memory
    previous_wp = wp(k);
    previous_traj = traj;
    
end

function traj = generate_trajectory(current_wp, previous_wp, previous_traj)
P = current_wp - previous_wp % Distance to travel
V = 20; % max velocity
A = 20; % max acceleration
Tj = 1; % Jerk time

if abs(current_wp - previous_wp) > 1e-2 % Step occured if threshold breached
    [Y,T] = GenTraj(A,V,P,Tj);
    traj = previous_wp + Y(3,:); % generate new traj
    
elseif size(previous_traj,2) == 1 % Constant ref at current position
    traj = previous_traj; % feed through
    
else % Complete current trajectory
    traj = [previous_traj(:, 2:end), previous_traj(:, end)]; % delete timestep that passed and duplicate last one
end

end