%% Plot results from flight
disp('start')

%% Extract data
Ts = 0.03

% smooth data
disp('Select SMOOTH (QGC) waypoint data')
use_sitl_data = 1;
reload_data = 1;
extract_data
smooth.pos.x = pos.x;
smooth.vel.x = vel.x;
smooth.angle.y = angle.y;
smooth.acc_sp.x = acc_sp.x;  
smooth.pos_sp.x = pos_sp.x;  
smooth.time = time;

% figure
% plot(smooth.time, smooth.pos.x);
% title('smooth')

% step data
disp('Select STEP waypoint data')
use_sitl_data = 1;
reload_data = 1;
extract_data
step.pos.x = pos.x;
step.vel.x = vel.x;
step.angle.y = angle.y;
step.acc_sp.x = acc_sp.x;  
step.pos_sp.x = pos_sp.x;  
step.time = time;

% figure
% plot(step.time, step.pos.x);
% title('step')

%% Shift Allign x axis

figure
plot(smooth.time, smooth.acc_sp.x);
hold on
grid on
plot(step.time,     step.acc_sp.x);
title('To allign x axis, click on SMOOTH then STEP plots on one x-grid-line')
legend('smooth', 'step')
hold off

[allign_x,~] = ginput(2); % Get start of responce from user click

time_shift = allign_x(2) - allign_x(1);
step.time = step.time - time_shift;

%% Replot shifted step vs MATLAB graphs
figure
plot(smooth.time, smooth.acc_sp.x);
hold on
grid on
plot(step.time, step.acc_sp.x);
title('acc_sp.x')
legend('smooth', 'step')
hold off

figure
plot(smooth.time, smooth.pos.x);
hold on
grid on
plot(step.time, step.pos.x);
title('pos')
legend('smooth', 'step')
hold off

figure
plot(smooth.time, smooth.vel.x);
hold on
grid on
plot(step.time, step.vel.x);
title('vel')
legend('smooth', 'step')
hold off

figure
plot(smooth.time, smooth.angle.y);
hold on
grid on
plot(step.time, step.angle.y);
title('angle')
legend('smooth', 'step')
hold off

figure
plot(smooth.time, smooth.pos_sp.x);
hold on
grid on
plot(step.time, step.pos_sp.x);
title('pos_sp.x')
legend('smooth', 'step')
hold off




disp('Done.')

