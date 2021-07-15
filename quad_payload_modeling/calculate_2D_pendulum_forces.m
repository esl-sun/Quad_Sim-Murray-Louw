% quad with payload equations of motion to calculate inertial forces 
% experienced by UAV due to 2D payload
% Vector angles use (relative to fixed, inertial axis)

clc;
clear all;

syms l mq mp g % length of cable, mass of quad, mass of payload, gravity accelration positive
syms c % pendulum damping coef

syms xq dxq ddxq % x position, velocity and acceleration of quad
syms zq dzq ddzq
syms theta dtheta ddtheta % t = theta = pitch angle (around y)

syms fwp fwt % force of wind on payload in phi and theta direction

%% set of generalized coordinates
%X = [xq zq theta]

%% position vectors [x, z]
rq = [xq; zq];
rp = rq + [l*sin(theta); l*cos(theta)];

%% velocity vectors
vq = [dxq; dzq];
vp = dtheta*diff(rp, theta) + dxq*diff(rp, xq) + dzq*diff(rp, zq);

%% total kinetic energy
T = ( 0.5*mp*(vp(1)^2 + vp(2)^2) ) + ( 0.5*mq*(vq(1)^2 + vq(2)^2) );

%% potential energy
V = -mp*g*rp(2); % for forces and moments, only consider potential energy of payload

%% non convservative forces
qt = -c*dtheta - l*cos(theta)*fwt; % moment due to damping and force of wind on payload in x direction

Q = [0, 0, qt];

%% Lagrange
L = T - V;

%% theta payload
dL_t = simplify(diff(L, theta));
dL_dt = diff(L, dtheta);
dt_dL_dt = simplify(dtheta*diff(dL_dt, theta) + ddtheta*diff(dL_dt, dtheta)+ dxq*diff(dL_dt, xq) + ddxq*diff(dL_dt, dxq) + dzq*diff(dL_dt, zq) + ddzq*diff(dL_dt, dzq));

%% x acceleration quad
dL_xq = simplify(diff(L, xq));
dL_dxq = diff(L, dxq);
dt_dL_dxq = simplify(dtheta*diff(dL_dxq, theta) + ddtheta*diff(dL_dxq, dtheta) + dxq*diff(dL_dxq, xq) + ddxq*diff(dL_dxq, dxq) + dzq*diff(dL_dxq, zq) + ddzq*diff(dL_dxq, dzq));

%% z acceleration quad
dL_zq = simplify(diff(L, zq));
dL_dzq = diff(L, dzq);
dt_dL_dzq = simplify(dtheta*diff(dL_dzq, theta) + ddtheta*diff(dL_dzq, dtheta) + dxq*diff(dL_dzq, xq) + ddxq*diff(dL_dzq, dxq) + dzq*diff(dL_dzq, zq) + ddzq*diff(dL_dzq, dzq));

%% determining the DEs (dd vars still in all equations)
% eqnddxq =   ddxq == simplify(solve(dt_dL_dxq - dL_xq == Q(1), ddxq));
% eqnddzq =   ddzq == simplify(solve(dt_dL_dzq - dL_zq == Q(2), ddzq));
eqnddt  =   ddtheta  == simplify(solve(dt_dL_dt - dL_t == Q(3), ddtheta))

%% anton manier
m_eq = [dt_dL_dxq - dL_xq == Q(1),      dt_dL_dzq - dL_zq == Q(2),      dt_dL_dt - dL_t == Q(3)];
ddvar = [ddxq, ddzq, ddtheta];

sol = struct2array(solve(m_eq, ddvar));
sol = simplify(sol);

disp("ddxq = ");
disp(sol(1))
disp("ddzq = ");
disp(sol(2))
% disp("ddtq = ");
% disp(sol(3))




