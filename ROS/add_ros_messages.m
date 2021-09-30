% Add custom ROS messages to be used with simulink.
% Follow instructions from: https://www.mathworks.com/help/ros/ug/create-custom-messages-from-ros-package.html

catkin_src_path = '/home/murray/catkin_ws/src'; % Source directory of catkin_ws has message packages
rosgenmsg(catkin_src_path)
% addpath('C:\MATLAB\custom_msgs\packages\matlab_msg_gen_ros1\msggen')
% savepath
% clear classes
% rehash toolboxcache