function [waypoints, waypoints_time] = random_waypoints(num_waypoints, step_min, step_max, waypoint_min, waypoint_max, time_min, time_max, rng_seed)
%% Returns matrix with a random waypoints per row, and random time intervals between waypoints

% num_waypoints = Number of waypoints

% waypoint_max = Max values in waypoint [x,y,z]
% waypoint_min = Min values in waypoint [x,y,z]
% 
% step_max = Max step/change in waypoint [x,y,z]
% step_min = Min step/change in waypoint [x,y,z]
% 
% time_max = Min time between waypoints (s)
% time_min = Max time between waypoints (s)

    minmax = @(x, min_x, max_x) max(min(x,max_x),min_x); % anonymous function to restrict input x between min and max values

    rng(rng_seed); % Initialise random number generator for repeatability
    
    waypoints = zeros(num_waypoints,3); % Initialize empty matrix
    waypoints_time = zeros(num_waypoints,1); % Vector of time between waypoints. If time < 0: wait till reach threshhold before next waypoint

    waypoint_start = [0, 0, 10]; % Starting waypoint [x,y,z] (z is up positive for now)
    waypoints(1,:) = waypoint_start;
    
    for i = 2:num_waypoints % Populate waypoint matrix
        waypoint_step = ((step_max - step_min).*rand(1,3) + step_min).*sign(randn(1,3)); % Step size to next waypoint [x,y,z]
        waypoints(i,:) = waypoints(i-1,:) + waypoint_step; % Generate next waypoint
        waypoints(i,:) = minmax(waypoints(i,:), waypoint_min, waypoint_max); % Limit waypoints to within min and max range
        waypoints_time(i) = max([floor(time_max.*rand()), time_min]); % Time interval between waypoints
    end

    waypoints(:,3) = -waypoints(:,3); % Convert z to down-positive
    
end
