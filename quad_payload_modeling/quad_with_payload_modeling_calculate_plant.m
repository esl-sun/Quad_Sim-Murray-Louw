%%%%%%%%%%%%% quad with payload equations of motion for plant, (Euler 2-1 dynamics)
%%% angles defined relative to quad body frame 
%% for EKF

%variables

clc;
clear all;

syms t dt ddt l mp g  % t = pitch angle (around y)
syms p dp ddp % p = roll angle (around x)
syms mq xq yq zq dxq dyq dzq ddxq ddyq ddzq
syms F_N F_E F_D k c % forces of quad actuators in inertial frame



%% position vectors [x, y, z]
rq = [xq; yq; zq];
rp = rq + [l*cos(p)*sin(t); l*sin(p); l*cos(p)*cos(t)];


%% velocity vectors
vq = [dxq; dyq; dzq];
vp = dp*diff(rp, p) + dt*diff(rp, t) + dxq*diff(rp, xq) + dyq*diff(rp, yq) + dzq*diff(rp, zq);

%% total kinetic energy
T = (0.5*mp*(vp(1)^2 + vp(2)^2 + vp(3)^2)) + (0.5*mq*(vq(1)^2 + vq(2)^2 + vq(3)^2));


%% potential energy
V = -mp*g*rp(3) - mq*g*rq(3);

%% non-conservative forces
Q = [F_N; F_E; F_D; 0*(-k*p-c*dp); 0*(-k*t-c*dt)];

%% Lagrange
L = T - V;

%% phi payload
dL_p = simplify(diff(L, p));
dL_dp = diff(L, dp);
dt_dL_dp = simplify(dt*diff(dL_dp, t) + ddt*diff(dL_dp, dt) + dp*diff(dL_dp, p) + ddp*diff(dL_dp, dp) + dxq*diff(dL_dp, xq) + ddxq*diff(dL_dp, dxq) + dyq*diff(dL_dp, yq) + ddyq*diff(dL_dp, dyq) + dzq*diff(dL_dp, zq) + ddzq*diff(dL_dp, dzq));

%% theta payload
dL_t = simplify(diff(L, t));
dL_dt = diff(L, dt);
dt_dL_dt = simplify(dt*diff(dL_dt, t) + ddt*diff(dL_dt, dt) + dp*diff(dL_dt, p) + ddp*diff(dL_dt, dp) + dxq*diff(dL_dt, xq) + ddxq*diff(dL_dt, dxq) + dyq*diff(dL_dt, yq) + ddyq*diff(dL_dt, dyq) + dzq*diff(dL_dt, zq) + ddzq*diff(dL_dt, dzq));

%% x acceleration quad
dL_xq = simplify(diff(L, xq));
dL_dxq = diff(L, dxq);
dt_dL_dxq = simplify(dt*diff(dL_dxq, t) + ddt*diff(dL_dxq, dt) + dp*diff(dL_dxq, p) + ddp*diff(dL_dxq, dp) + dxq*diff(dL_dxq, xq) + ddxq*diff(dL_dxq, dxq) + dyq*diff(dL_dxq, yq) + ddyq*diff(dL_dxq, dyq) + dzq*diff(dL_dxq, zq) + ddzq*diff(dL_dxq, dzq));
            
%% y acceleration quad
dL_yq = simplify(diff(L, yq));
dL_dyq = diff(L, dyq);
dt_dL_dyq = simplify(dt*diff(dL_dyq, t) + ddt*diff(dL_dyq, dt) + dp*diff(dL_dyq, p) + ddp*diff(dL_dyq, dp) + dxq*diff(dL_dyq, xq) + ddxq*diff(dL_dyq, dxq) + dyq*diff(dL_dyq, yq) + ddyq*diff(dL_dyq, dyq) + dzq*diff(dL_dyq, zq) + ddzq*diff(dL_dyq, dzq));

%% z acceleration quad
dL_zq = simplify(diff(L, zq));
dL_dzq = diff(L, dzq);
dt_dL_dzq = simplify(dt*diff(dL_dzq, t) + ddt*diff(dL_dzq, dt) + dp*diff(dL_dzq, p) + ddp*diff(dL_dzq, dp) + dxq*diff(dL_dzq, xq) + ddxq*diff(dL_dzq, dxq) + dyq*diff(dL_dzq, yq) + ddyq*diff(dL_dzq, dyq) + dzq*diff(dL_dzq, zq) + ddzq*diff(dL_dzq, dzq));



%% determining the DEs

% eqnddxq = ddxq == simplify(solve(dt_dL_dxq - dL_xq == Q(1), ddxq))
% eqnddyq = ddyq == simplify(solve(dt_dL_dyq - dL_yq == Q(2), ddyq))
% eqnddzq = ddzq == simplify(solve(dt_dL_dzq - dL_zq == Q(3), ddzq))
% eqnddp = ddp == simplify(solve(dt_dL_dp - dL_p == Q(4), ddp)) 
% eqnddt = ddt == simplify(solve(dt_dL_dt - dL_t == Q(5), ddt))

%% anton manier
m_eq = [dt_dL_dxq - dL_xq == Q(1), dt_dL_dyq - dL_yq == Q(2), dt_dL_dzq - dL_zq == Q(3), dt_dL_dp - dL_p == Q(4), dt_dL_dt - dL_t == Q(5)];
ddvar = [ddxq, ddyq, ddzq, ddp, ddt];

sol = struct2array(solve(m_eq, ddvar));
sol = simplify(sol);
fprintf("ddxq = ");
%pretty(sol(1))
sol(1)
fprintf("ddyq = ");
%pretty(sol(2))
sol(2)
fprintf("ddzq = ");
%pretty(sol(3))
sol(3)
fprintf("ddp = ");
%pretty(sol(4))
sol(4)
fprintf("ddt = ");
%pretty(sol(5))
sol(5)


%(F_D*mp + F_D*mq + g*mq^2 + g*mp*mq - F_D*mp*cos(p)^2*cos(t)^2 - F_N*mp*cos(p)^2*cos(t)*sin(t) - F_E*mp*cos(p)*cos(t)*sin(p) + dp^2*l*mp*mq*cos(p)*cos(t) + dt^2*l*mp*mq*cos(p)^3*cos(t))/(mq*(mp + mq));
 


