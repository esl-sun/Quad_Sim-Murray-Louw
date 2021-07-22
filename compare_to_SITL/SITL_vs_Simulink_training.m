%% Plot results from SITL
disp('start')

%% Extract data
Ts = 0.03
init_use_sitl_data = use_sitl_data;

% Simulink data
use_sitl_data = 0;
reload_data = 1;
extract_data
simulink.y_train = y_train;
simulink.u_train = u_train;  
simulink.pos_sp_data = pos_sp_data;  
simulink.t_train = t_train;

% figure
% plot(simulink.t_train, simulink.y_train);
% title('Simulink')

% SITL data
use_sitl_data = 1;
reload_data = 1;
extract_data
sitl.y_train = y_train;
sitl.u_train = u_train;  
sitl.pos_sp_data = pos_sp_data;  
sitl.t_train = t_train;

% figure
% plot(sitl.t_train, sitl.y_train);
% title('SITL')

use_sitl_data = init_use_sitl_data; % Reset value to before

%% Shift Allign SITl and MATLAB plots

compare_index = 1:2000;

figure
plot(simulink.t_train(compare_index), simulink.vel_sp_train(compare_index));
hold on
grid on
plot(sitl.t_train(compare_index),     sitl.vel_sp_train(compare_index));
title('To allign x axis, click on Simulink then SITL plots on one x-grid-line')
legend('Simulink', 'SITL')
hold off

[allign_x,~] = ginput(2); % Get start of responce from user click

time_shift = allign_x(2) - allign_x(1);
sitl.t_train = sitl.t_train - time_shift;

%% Replot shifted SITl vs MATLAB graphs
figure
plot(simulink.t_train, simulink.u_train);
hold on
grid on
plot(sitl.t_train, sitl.u_train);
title('u_train')
legend('Simulink', 'SITL')
hold off

figure
plot(simulink.t_train, simulink.y_train(1,:));
hold on
grid on
plot(sitl.t_train, sitl.y_train(1,:));
title('y train(1)')
legend('Simulink', 'SITL')
hold off

figure
plot(simulink.t_train, simulink.y_train(2,:));
hold on
grid on
plot(sitl.t_train, sitl.y_train(2,:));
title('y train(2)')
legend('Simulink', 'SITL')
hold off

figure
plot(simulink.t_train, simulink.pos_sp_train);
hold on
grid on
plot(sitl.t_train, sitl.pos_sp_train);
title('pos-sp training waypoints')
legend('Simulink', 'SITL')
hold off




disp('Done.')

