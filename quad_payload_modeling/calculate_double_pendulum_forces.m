% Quadrotor with payload 
% equations of motion to calculate inertial forces 
% experienced by UAV due to DOUBLE PENDULUM payload
% Angles are vector angles (relative to fixed, inertial axis)

clc;
clear all;

syms l1 % length of cable to first payload mass
syms l2 % length between payload masses 1 and 2

syms mq % mass of quad
syms mp1 % mass of payload 1
syms mp2 % mass of payload 2

syms g % gravity accelration POSITIVE
syms c1 % damping coef between quad and joint 1
syms c2 % damping coef between joint 1 and joint 2

syms xq dxq ddxq % x position, velocity and acceleration of quad
syms zq dzq ddzq
syms theta1 dtheta1 ddtheta1 % theta1 = pitch angle (around y)
syms theta2 dtheta2 ddtheta2 % theta2 = pitch angle of second mass (around y)

syms fwt1 fwt2 % force of wind on payload theta direction

%% set of generalized coordinates
%X = [xq zq theta1 theta2]

%% position vectors [x, z]
rq  = [xq; zq];
rp1 = rq  + [l1*sin(theta1); l1*cos(theta1)]; % Position vecotr of payload 1
rp2 = rp1 + [l2*sin(theta2); l2*cos(theta2)]; % Position vecotr of payload 2

%% velocity vectors
vq = [dxq; dzq];
vp1 = dxq*diff(rp1, xq) + dzq*diff(rp1, zq) + dtheta1*diff(rp1, theta1); % Time derivative. vp depends on xq, zq, theta
vp2 = dxq*diff(rp2, xq) + dzq*diff(rp2, zq) + dtheta1*diff(rp2, theta1) + dtheta2*diff(rp2, theta2); % Time derivative. vp2 depends on xq, zq, theta, theta2

%% Kinetic energy
Tq  = 0.5*mq *(vq(1)^2  + vq(2)^2); % Kinetic energy of quad
Tp1 = 0.5*mp1*(vp1(1)^2 + vp1(2)^2); % Kinetic energy of payload mass 1
Tp2 = 0.5*mp2*(vp2(1)^2 + vp2(2)^2); % Kinetic energy of payload mass 2

T = Tq + Tp1 + Tp2; % Total kinetic energy

%% Potential energy
Vp1 = -mp1*g*rp1(2); % for forces and moments, only consider potential energy of payload
Vp2 = -mp2*g*rp2(2); % potential energy of payload mass 2

V = Vp1 + Vp2;

%% Non convservative forces
qt1 = -c1*dtheta1             - l1*cos(theta1)*fwt1; % moment due to damping on quad joint    and     force of wind on payload in x direction
qt2 = -c2*(dtheta2 - dtheta1) - l2*cos(theta2)*fwt2; % moment due to damping on relative rotaion between cable and mass 2   + wind force on mass 2
Q = [0, 0, qt1, qt2];

%% Lagrange
L = T - V;

%% theta payload
dL_theta1 = simplify(diff(L, theta1));
dL_dtheta1 = diff(L, dtheta1);
dt_dL_dtheta1 = simplify(...
    dtheta1*diff(dL_dtheta1, theta1) + ddtheta1*diff(dL_dtheta1, dtheta1) + ...
    dtheta2*diff(dL_dtheta1, theta2) + ddtheta2*diff(dL_dtheta1, dtheta2) + ...
    dxq    *diff(dL_dtheta1, xq)     + ddxq    *diff(dL_dtheta1, dxq) + ...
    dzq    *diff(dL_dtheta1, zq)     + ddzq    *diff(dL_dtheta1, dzq) ...
    );

%% theta2 payload
dL_theta2 = simplify(diff(L, theta2));
dL_dtheta2 = diff(L, dtheta2);
dt_dL_dtheta2 = simplify(...
    dtheta1*diff(dL_dtheta2, theta1) + ddtheta1*diff(dL_dtheta2, dtheta1) + ...
    dtheta2*diff(dL_dtheta2, theta2) + ddtheta2*diff(dL_dtheta2, dtheta2) + ...
    dxq    *diff(dL_dtheta2, xq)     + ddxq    *diff(dL_dtheta2, dxq) + ...
    dzq    *diff(dL_dtheta2, zq)     + ddzq    *diff(dL_dtheta2, dzq) ...
    );

%% x acceleration quad
dL_xq = simplify(diff(L, xq));
dL_dxq = diff(L, dxq);
dt_dL_dxq = simplify( ...
    dtheta1*diff(dL_dxq, theta1) + ddtheta1*diff(dL_dxq, dtheta1) + ...
    dtheta2*diff(dL_dxq, theta2) + ddtheta2*diff(dL_dxq, dtheta2) + ...
    dxq*    diff(dL_dxq, xq)     + ddxq    *diff(dL_dxq, dxq) + ...
    dzq*    diff(dL_dxq, zq)     + ddzq    *diff(dL_dxq, dzq) ...
    );

%% z acceleration quad
dL_zq = simplify(diff(L, zq));
dL_dzq = diff(L, dzq);
dt_dL_dzq = simplify(...
    dtheta1*diff(dL_dzq, theta1) + ddtheta1*diff(dL_dzq, dtheta1) + ...
    dtheta2*diff(dL_dzq, theta2) + ddtheta2*diff(dL_dzq, dtheta2) + ...    
    dxq    *diff(dL_dzq, xq)     + ddxq    *diff(dL_dzq, dxq) + ...
    dzq    *diff(dL_dzq, zq)     + ddzq    *diff(dL_dzq, dzq) ...
    );

%% Quad acceleration    due to    actual payload angle and angular rate
eqns = [ % Lagragian equations
        dt_dL_dxq - dL_xq == Q(1);
        dt_dL_dzq - dL_zq == Q(2);
        dt_dL_dtheta1 - dL_theta1 == Q(3);
        dt_dL_dtheta2 - dL_theta2 == Q(4)
       ];
ddvar = [ % Acceleration variables to solve for
        ddxq; 
        ddzq; 
        ddtheta1; 
        ddtheta2
        ];

sol = struct2array(solve(eqns, ddvar));
sol = simplify(sol);

fprintf('ax = %s;\n', char(sol(1)))
fprintf('az = %s;\n', char(sol(2)))

%% Payload angular acceleration,     due to    actual quad acceleration 
% Solve with xq and zq states as unknowns
eqns = [ % Lagragian equations
        dt_dL_dtheta1 - dL_theta1 == Q(3);
        dt_dL_dtheta2 - dL_theta2 == Q(4)
       ];
ddvar = [ % Acceleration variables to solve for
        ddtheta1; 
        ddtheta2
        ];

sol = struct2array(solve(eqns, ddvar));
sol = simplify(sol);

fprintf('ddtheta1 = %s;\n', char(sol(1)))
fprintf('ddtheta2 = %s;\n', char(sol(2)))

