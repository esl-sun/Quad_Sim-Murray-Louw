% dx = A*x + B*u;
% x = [integral, vn, theta, dtheta]
x0 = [0; y_run(:,1), dtheta_run(:,1)];
t_span = t_run - t_run(1); % Start at zero]
[t,X_hat] = ode45( @(t,x) LQR.A*x + LQR.B*( u_run(:,floor(t/Ts)+1) ), t_span, x0);
plot(t, X_hat)
hold on
y_hat = X_hat([2,3], :); % Extract only non-delay time series
