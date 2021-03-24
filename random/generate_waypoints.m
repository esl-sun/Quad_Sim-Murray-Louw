% Way points
num_waypoints = 5; % Number of waypoints included in command

waypoint_start = [0, 0, 10]; % Starting waypoint [x,y,z]

waypoint_max = [10, 10, 18]; % Max values in waypoint [x,y,z]
waypoint_min = [-10, -10, 10]; % Min values in waypoint [x,y,z]

step_max = [4, 0, 2]; % Max step/change in waypoint [x,y,z]
step_min = [0, 0, 0]; % Min step/change in waypoint [x,y,z]

waypoints = zeros(num_waypoints,3);
waypoints(1,:) = waypoint_start;

for i = 2:num_waypoints
    waypoint_step = ((step_max - step_min).*rand(1,3) + step_min).*sign(randn(1,3)); % Step size to next waypoint [x,y,z]
    waypoints(i,:) = waypoints(i-1,:) + waypoint_step;
end

waypoints

%%


clear table
waypoints = table('Size', [(num_waypoints+1)*2, 3], 'VariableTypes', ["double", "double", "double"]);
waypoints.Properties.VariableNames = {'point_time', 'x_coord', 'z_coord'};

waypoint_opt = 'random xz'; % waypoint option
switch waypoint_opt
    case 'random xz'
        x_coord = 0;
        z_coord = 0;
        waypoints(1,:) = table(0,                   x_coord, z_coord); % Initial point

        x_min   = 0.5;     x_max   = 1.5; % (m) minimum and maximum step size for waypoints
        z_min   = 0.5;     z_max   = 1.5;
        interval_min = 4;       interval_max = 10;  % (s) minimum and maximum TIME interval between commands

        rng(0); % Initialise random number generator for repeatability
        point_time = 0; % Currently at time zero
        next_point = 1; % Index of next point
        for i = 1:num_waypoints
            % Step x only
            time_interval = (interval_max - interval_min).*rand() + interval_min; % (s) random time interval between commands
            point_time = point_time + time_interval;

            waypoints(next_point,  :) = table(point_time, x_coord, z_coord); % Previous point    
            next_point = next_point + 1;
            x_step = ((x_max - x_min).*rand() + x_min)*sign(randn()); % x step of next waypoint (size)*(direction)
            x_coord = x_coord + x_step;
            waypoints(next_point,:) = table(point_time, x_coord, z_coord); % Next point
            next_point = next_point + 1; 
            
            % Step z only
            time_interval = (interval_max - interval_min).*rand() + interval_min; % (s) random time interval between commands
            point_time = point_time + time_interval;

            waypoints(next_point,  :) = table(point_time, x_coord, z_coord); % Previous point    
            next_point = next_point + 1;
            z_step = ((z_max - z_min).*rand() + z_min)*sign(randn()); % z step of next waypoint (size)*(direction)
            z_coord = z_coord + z_step;
            waypoints(next_point,:) = table(point_time, x_coord, z_coord); % Next point
            next_point = next_point + 1;            
        end
        i = i+1;
        waypoints(2*i,  :) = table(point_time+interval_max, x_coord, z_coord); % Add time to reach final point

    case 'random x'
        x_coord = 0;
        z_coord = 0; % constant z
        waypoints(1,:) = table(0, x_coord, z_coord); % Initial point

        x_min        = -5;     x_max         = 5; % (m) minimum and maximum coordinates for waypoints
        interval_min = 2;     interval_max = 5;  % (s) minimum and maximum TIME interval between commands

        point_time = 0;
        rng(0); % Initialise random number generator for repeatability
        for i = 1:num_waypoints
            time_interval = (interval_max - interval_min).*rand() + interval_min; % (s) random time interval between commands
            point_time = point_time + time_interval;
            if i == 1 % set first interval
                point_time = 5;
            end
            waypoints(2*i,  :) = table(point_time, x_coord, z_coord); % Previous point    
            x_coord    = (x_max - x_min).*rand() + x_min; % x coordinate of next waypoint
            waypoints(2*i+1,:) = table(point_time, x_coord, z_coord); % Next point
        end
        i = i+1;
        waypoints(2*i,  :) = table(point_time+interval_max, x_coord, z_coord); % Add time to reach final point
        
    case 'regular x'
        time_interval = 4; % (s) interval between commands
        step_size = 2;
        x_coord = step_size;
        z_coord = 0;
        point_time = 0;
        waypoints(1,:) = table(0, x_coord, z_coord); % Initial point
        for i = 1:num_waypoints
        
            point_time = point_time + time_interval;
        
            waypoints(2*i,  :) = table(point_time, x_coord, z_coord); % Previous point    
            x_coord    = x_coord + step_size; % x coordinate of next waypoint
            z_coord    = 0; % z coordinate of next waypoint   
            waypoints(2*i+1,:) = table(point_time, x_coord, z_coord); % Next point
        end
        waypoints(end,:) = table(200, x_coord, z_coord); % Final point
        
     otherwise
        error("Unknown waypoint option")
end

waypoints_ts = timeseries([waypoints.x_coord, waypoints.z_coord], waypoints.point_time); % timeseries object for From Workspace block
% plot(waypoints_ts.Time, waypoints_ts.Data)
