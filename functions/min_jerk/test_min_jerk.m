
t = 0:0.03:4;
xi = 0; % [0 0 0]
xf = 5; % [5 0 0]
traj = min_jerk(xi, xf, t);

plot(t,traj(:,1))

% subplot(3,1,1);
% plot(t, out(:,1));
% xlabel('t');
% ylabel('x');
% 
% subplot(3,1,2);
% plot(t, out(:,2));
% xlabel('t');
% ylabel('y');[0 0 0]
% 
% subplot(3,1,3);
% plot(t, out(:,3));
% xlabel('t');
% ylabel('z');