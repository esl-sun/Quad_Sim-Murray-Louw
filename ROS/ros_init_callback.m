%% Used in InitCallback function of any Simulink model using ros to initialise connections
disp('[InitFcn] Running initialise function for ROS connections')
rosshutdown
rosinit

Ts_publish = 0.03; % Publishing rate