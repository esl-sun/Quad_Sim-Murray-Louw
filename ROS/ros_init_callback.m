%% Used in InitCallback function of any Simulink model using ros to initialise connections
disp('[InitFcn] Running initialise function for ROS connections')
rosshutdown
rosinit('192.168.55.1')

Ts_sim = 0.01;
Ts_publish = 0.03; % Publishing sample time
Ts_sub = 0.01; % Subscribing sample time
Ts_pos_control = 0.01; % Position and velocity controller sample time

initialise_iris_gains;
