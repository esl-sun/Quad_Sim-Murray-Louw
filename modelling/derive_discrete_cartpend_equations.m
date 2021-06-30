%% Derive DISCRETE system equations for 2D drone with suspended payload
% Point mass for uav
% Input is a accleration setpoint left or right
% only moves in x axis
% Pendulum free to swing in x-z plane
% North East Down axis system. Therefore z is down
clear all

% Still try discrete lagrangian:
% from: Swing-up Control of the Cart-Pendulum System based on Discrete Mechanics
% Tatsuya Kai and Kensuke Bito

% from: https://ctms.engin.umich.edu/CTMS/index.php?example=InvertedPendulum&section=ControlDigital

Ts = 0.03;

M = 0.66; % Mass of quad
m = 0.2; % mass of payload
l = 0.5; % length of pendulum
b = 0; % friction damping coefficient of cart

I = m*l^2;
g = 9.81; % Positive

%% Continuos system
p = I*(M+m) + M*m*l^2; % denominator for the A and B matrices

A = [0      1              0           0;
     0 -(I+m*l^2)*b/p  (m^2*g*l^2)/p   0;
     0      0              0           1;
     0 -(m*l*b)/p      m*g*l*(M+m)/p   0];
B = [     0;
     (I+m*l^2)/p;
          0;
        m*l/p];
C = [1 0 0 0;
     0 0 1 0];
D = [0;
     0];

states = {'x' 'x_dot' 'phi' 'phi_dot'};
inputs = {'u'};
outputs = {'x'; 'phi'};

sys_ss = ss(A,B,C,D,'statename',states,'inputname',inputs,'outputname',outputs); % Continuous state space

%% Discrete system
sys_d = c2d(sys_ss,Ts,'zoh')




















