function [vel_sps, sps_time] = random_vel_setpoints(num_sps, vel_max, time_min, time_max, rng_seed)
%% Returns matrix with a schedule of random velocity setpoints per row, 
%  and random time intervals between setpoints

    rng(rng_seed); % Initialise random number generator for repeatability
    
    vel_sps = zeros(num_sps,3); % Velocity setpoints [vx,vy,vz]. Initialize empty matrix
    sps_time = zeros(num_sps,1); % Vector of time between waypoints. If time < 0: wait till reach threshhold before next waypoint

    sp_start = [0, 0, 0]; % Starting waypoint [x,y,z] (z is up positive for now)
    vel_sps(1,:) = sp_start;
    sps_time(1,:) = 5; % initial interval
    
    vel_max = abs(vel_max); % Ensure it is positive
    
    for i = 2:num_sps % Populate setpoint matrix
        vel_sps(i,:) = (2*vel_max).*rand(1,3) - vel_max; % Uniformly random vel within range [vx,vy,vz]
        
        if mod(i,3) == 0 % Only for x
            displacement = sum(vel_sps.*sps_time); % Calculate distance travel so far.
            vel_sps(i,:) = abs(vel_sps(i,:)).*sign(displacement).*(-1); % Opposite direction of velocity as distance travelled
            % Calculate time needed to return to zero, given random
            % velocity magnitude:
            sps_time(i) = abs(displacement(1)./vel_sps(i,1)); % Based on zeroing x vel
            sps_time(i)
            if(sps_time(i) > time_max) % Ensure that does not cause long time step
                vel_sps(i,:) = vel_max.*sign(displacement).*(-1); % Set to max vel
                sps_time(i) = abs(displacement(1)./vel_sps(i,1)); % Based on zeroing x vel
            end
            
        else
            sps_time(i) = floor(((time_max - time_min).*rand() + time_min)); % Time interval between setpoints
        end
        
    end   
end
