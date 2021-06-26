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