% clear all
close all
% clc

% mp = 1;
% mq = 5;
% l = 2;
% g = 9.81;
% d = 0; % x velocity damping

% s = -1; % pendulum up (s = 1), pend down (s = -1)
% states = [x, dx, theta, dtheta]
A = [
    0      -1       0                   0;
    0       0       mp*g/mq             0;
    0       0       0                   1;
    0       0       -1*(mp+mq)*g/(mq*l)  0
    ];

B = [
    0; 
    1/mq; 
    0; 
    -1/(mq*l)
    ];

eig(A)

Q = diag([1 1 10 10]); % State weights
R = 3; % Input weights

%%
det(ctrb(A,B))

%%
K = lqr(A,B,Q,R);

tspan = 0:.001:20;

y0 = [0; 0; 0; 0]; % theta = 0 is down
r = [0; 1; 0; 0]; % Reference x
[t,y] = ode45(@(t,y)cartpend(y,mp,mq,l,g,d,-K*(y-r),r),tspan,y0);

% for k=1:100:length(t)
%     drawcartpend_bw(y(k,:),mp,mq,l);
% end

acc = -K*(y'-r) * (1/max_total_T) * (g/hover_init); % convert force to acceleration

figure
plot(t,y)
hold on
plot(t',acc)
hold off
legend('Int(V_sp - V)', 'V', 'theta', 'dtheta', 'acc')

% function dy = pendcart(y,m,M,L,g,d,u)










