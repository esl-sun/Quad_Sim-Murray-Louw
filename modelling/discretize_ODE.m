% Convert ODE to Difference Equation
% Can use different methods, like Tustin, Centred FD, Forward- or Backward Euler

disp("discretize_ODE")
disp("--------------")

syms x(t) th(t) u(t) % time dependant
syms s z 
syms X_z U_z % Z transform variables
syms p1 p2 p3 p4 % parameters (coef of terms)

% Define system as ODE
Ts = 0.03; % Sampling time
dx = diff(x,t); % x_dot
ddx = diff(dx, t); % x_dotdot

dth = diff(th,t); % theta_dot
ddth = diff(dth, t); % theta_dotdot

ODE_sys = ( ddx == u ); % Ordinary Diff Eq of system

% extract numerators and denomenators of both sides
[num_L, denom_L] = numden(lhs(ODE_sys)); 
[num_R, denom_R] = numden(rhs(ODE_sys));

% Flatten all fractions
ODE_sys = ( 0 == expand(num_L*denom_R - num_R*denom_L) );

% Laplace transform
L_sys = laplace(ODE_sys);
old = [laplace(x), laplace(u)];
new = [X_z,        U_z];
Z_sys = subs(L_sys, old, new); % Substitute with symbols to simplify

pretty(L_sys)

% Possible substitutions
Tustin = ((2/Ts)*(z - 1)/(z + 1));
Back_Euler = (1 - z^-1)/Ts;
Forward_Euler = (z - 1)/Ts;
Centered_FD = (z - z^-1)/(2*Ts); % Centered Finite Difference

% Convert to Z-transform
syms Dx(t) Dth(t)  % Resest symbol
old = [laplace(x), laplace(u)];
new = [X_z,        U_z];
Z_sys = subs(L_sys, old, new); % Substitute with symbols to simplify
Z_sys = subs(Z_sys, s, Tustin); % Sub 's' for 'z' expression
Z_sys = simplifyFraction(Z_sys);

pretty(Z_sys)


% extract numerators and denomenators of both sides
[num_L, denom_L] = numden(lhs(Z_sys)); 
[num_R, denom_R] = numden(rhs(Z_sys));

% Flatten all fractions
Z_sys = 0 == expand(num_L*denom_R - num_R*denom_L);

Z_sys = isolate(Z_sys, X_z*z*z);
Z_sys = expand(Z_sys);
Z_sys = collect(Z_sys, [X_z, U_z, z]);

pretty(Z_sys)

