%% Derive system equations for 2D drone with suspended payload
% Two vertical forces at distance, r, from COM represent the rotor forces
% North East Down axis system. Therefore z is down
clear all

% Symbolic variables
syms g % Acceleration due to gravity (always negative)
syms t % Time

syms mq % Mass of quadrotor (at fulcrum)
syms mp % Mass of payload
syms l % Length of pendulum
syms cbeta % Damping coef of cable

syms x(t) % x position of drone
syms beta(t) % Suspended angle of payload cable (vertical down = 0 rad)

syms dx % dx/dt of drone 
syms dbeta % dbeta/dt of payload cable

% Inputs
syms acc_sp % Acceleration setpoint in x direction
F_x = acc_sp*(mp+mq); % Assume inner controllers appear instant to velocity control
% PX4 uses hover estimation in thr2att conversion, therefore Force produced
% is proportional to (mp+mq)

states = [x; beta]; % non-rate states
n = 4; % number of states (position and velocity)
X = sym('X', [n, 1]); % State vector [x; beta; dx; dbeta]

% Rates
dx        = diff(x, t);
dbeta     = diff(beta, t);

% Drone body equations
KE_q = 0.5*mq*(dx^2); % Kinetic energy of drone body (linear + rotational)
PE_q = 0; % Potential energy of drone body

% Payload equations
x_p = x + l*sin(beta); % x position of payload
z_p = 0 + l*cos(beta); % z position of payload

KE_p = 0.5*mp*( diff(x_p,t)^2 + diff(z_p,t)^2 ); % Kinetic energy of payload
PE_p = mp*g*z_p; % Potential energy of payload

% Lagrangian
L = (KE_q + KE_p) - (PE_q + PE_p);
L = simplify(L);

% Non-conservative Forces
Qx = F_x; % Assume neglible drag

% Non-conservative Torques
Qbeta  = -cbeta*dbeta; % Damping torque on cable
% Qbeta = 0; % try no damping

% Lagrangian equations
eq_x     = euler_lag(L, x, Qx, t); 
eq_beta  = euler_lag(L, beta,  Qbeta, t);

% Clear symbol connections
syms dx  dbeta
syms ddx ddbeta
dstates  = [dx;  dbeta];
ddstates = [ddx;  ddbeta];

eqns = [eq_x; eq_beta]; % Equations to solve with

% Substitute symbols into derivatives
old = [diff(states,t); diff(states,t,t)];
new = [dstates;        ddstates];
eqns = subs(eqns, old, new);

% Solve
solution = solve(eqns, ddstates);
ddstates = struct2cell(solution); % Convert to cell from struct
ddstates = [ddstates{:}]; % Convert to normal syms array from cell

% Simplify
ddstates = simplify(ddstates);
ddstates = simplifyFraction(ddstates);

% Substitute state variables with y
old = [states; dstates];
new = X;
ddstates = subs(ddstates, old, new);

%% Display to copy into script
for i = 1:n/2
    fprintf('dx(%d,1) = %s;\n',(i + n/2),ddstates(i))
end

%% Display pretty equations
disp('Pretty')
disp('------')
for i = 1:n/2
    disp(i + n/2)
    pretty(ddstates(i))
    disp("-------------------------------")
end

