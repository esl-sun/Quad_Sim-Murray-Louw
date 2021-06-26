%% Generate standard test data for use by system ID metric

clear all; % Clear workspace
initialize_quad_simulation % Run simulation init script

% Sim constants
sim_time = 10;
sim_freq = 250;

% Set specific payload parameters
mp = 2;
l = 1;
k = 0;
c = 0.03;

% Waypoints
num_waypoints = 100; % Number of waypoints

waypoint_max = [15, 15, 35]; % Max values in waypoint [x,y,z]
waypoint_min = [-15, -15, 15]; % Min values in waypoint [x,y,z]

step_max = [5, 1, 5]; % Max step/change in waypoint [x,y,z]
step_min = [0, 0, 0]; % Min step/change in waypoint [x,y,z]

time_max = 30; % Min time between waypoints (s)
time_min = 5; % Max time between waypoints (s)

rng_seed = 1;

[waypoints, waypoints_time] = random_waypoints(num_waypoints, step_min, step_max, waypoint_min, waypoint_max, time_min, time_max, rng_seed);


% Run Simulink model
out = sim('quad_simulation_with_payload');

% Save data
comment = '';
save(['data/test_data', '_mp', num2str(mp), '_l', num2str(l), '_noise', comment], 'out')
 
