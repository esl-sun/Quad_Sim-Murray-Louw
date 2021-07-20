%% Convert waypoints and time used in MATLAB sim to form to copy over to 
%% waypoints_scheduler.py to use for SITL

disp('waypoints = [')
for i = 1:size(waypoints,1)
    disp(['                [', num2str(waypoints(i,1)), ', ', num2str(waypoints(i,2)), ', ', num2str(waypoints(i,3)), ', 0],'])
end
disp('            ]')
disp('')
disp('waypoints_time = [')
for i = 1:size(waypoints,1)
    disp(['                ', num2str(waypoints_time(i)), ','])
end
disp(']')

%%
disp('    vel_setpoints = [')
for i = 1:size(vel_setpoints,1)
    disp(['            [', num2str(vel_setpoints(i,1)), ', ', num2str(vel_setpoints(i,2)), ', ', num2str(vel_setpoints(i,3)), '],'])
end
disp('        ]')
disp('')
disp('    vel_setpoints_time = [')
for i = 1:size(vel_setpoints_time,1)
    disp(['            ', num2str(vel_setpoints_time(i)), ','])
end
disp('        ]')

