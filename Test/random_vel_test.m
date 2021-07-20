num_sps = 20; % Number of setpoints to produce
vel_max = [3, 0, 0];  % Maximum velocity [vx, vy, vz]
time_max = 15;
time_min = 5;
rng_seed = 0;
    
[vel_sps, sps_time] = random_vel_setpoints(num_sps, vel_max, time_min, time_max, rng_seed)