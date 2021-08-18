%% Velocity single step input
vel_step_time = 2; % Time when vel step applied
vel_step_N = 1; % Size of North velocity step input
vel_step_E = 0; 
vel_step_D = 0;

%% Velocity training input
rng_seed = 0;
num_sps = 100; % Number of setpoints to produce
vel_max = [0.6, 0, 0];  % Maximum velocity [vx, vy, vz]
time_max = 25; % Max time between setpoints (s)
time_min = 15; % Min time between setpoints (s)
rng_seed = 0; % Random seed for reproducability
    
[vel_setpoints, vel_setpoints_time] = random_vel_setpoints(num_sps, vel_max, time_min, time_max, rng_seed);
% [vel_setpoints, vel_setpoints_time] = max_min_vel_setpoints(num_sps, vel_max, time_min, time_max, rng_seed);

% Manual vel setpoints: [x, y, z] = [N, E, D]   
% vel_setpoints = [
%     0, 0, 0;
%     1, 0, 0;
%     0, 0, 0;
%     ];
% 
% vel_setpoints_time = 10 * ones(size(vel_setpoints,1),1); % equal waypoints time for each

% figure(1)
% plot(cumsum(waypoints_time),waypoints) % Plot waypoints to visualise it
% title('waypoints')
% legend('x', 'y', 'z');

%% Position waypoints
threshold = 1e-3; % Threshold to reach waypoint, for threshold mode
num_waypoints = 100; % Number of waypoints

waypoint_max = [15, 15, 20]; % Max values in waypoint [x,y,z]
waypoint_min = [-15, -15, 10]; % Min values in waypoint [x,y,z]

step_max = [5, 0, 0]; % Max step/change in waypoint [x,y,z]
step_min = [0, 0, 0]; % Min step/change in waypoint [x,y,z]

time_max = 20; % Max time between waypoints (s)
time_min = 6; % Min time between waypoints (s)

if enable_random_waypoints
    rng_seed = 0;
    [waypoints, waypoints_time] = random_waypoints(num_waypoints, step_min, step_max, waypoint_min, waypoint_max, time_min, time_max, rng_seed);
else
    % Manual waypoints: [x, y, z] = [N, E, Up]
    
% Waypoints to write ESL:
    waypoints = [
                1, 0, 2;
                16, 0, 2;
                16, 12, 2;
                16, 0, 2;
                8, 0, 2;
                8, 8, 2;
                8, 0, 2;
                0, 0, 2;

                0, 22, 2;

                4, 26, 2;
                8, 22, 2;
                8, 18, 2;
                12, 14, 2;
                16, 18, 2;

                16, 30, 2;

                0, 30, 2;
                0, 42, 2
            ];
    
    waypoints = [
        0, 0, 2.5;
        5, 0, 2.5;
        ];

    waypoints_time = 2.05 * ones(size(waypoints,1),1); % equal waypoints time for each

end

% figure(1)
% plot(cumsum(waypoints_time),waypoints) % Plot waypoints to visualise it
% title('waypoints')
% legend('x', 'y', 'z');


