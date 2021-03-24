% Way points
num_waypoints = 100; % Number of waypoints included in command

waypoint_start = [0, 0, 10]; % Starting waypoint [x,y,z]
waypoints = zeros(num_waypoints,3); % Matrix of waypoints [x1, y1, z1; x2, y2, z2; ... ]
waypoints(1,:) = waypoint_start;

minmax = @(x, min_x, max_x) max(min(x,max_x),min_x); % function to restrict input x between min and max values
waypoint_max = [10, 10, 20]; % Max values in waypoint [x,y,z]
waypoint_min = [-10, -10, 10]; % Min values in waypoint [x,y,z]

step_max = [4, 0, 2]; % Max step/change in waypoint [x,y,z]
step_min = [0, 0, 0]; % Min step/change in waypoint [x,y,z]

for i = 2:num_waypoints
    waypoint_step = ((step_max - step_min).*rand(1,3) + step_min).*sign(randn(1,3)); % Step size to next waypoint [x,y,z]
    waypoints(i,:) = waypoints(i-1,:) + waypoint_step;
    waypoints(i,:) = minmax(waypoints(i,:), waypoint_min, waypoint_max);
end

plot(waypoints)
legend('x', 'y', 'z')
