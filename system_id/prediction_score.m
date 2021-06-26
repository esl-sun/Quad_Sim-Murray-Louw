% Compare to testing data
% Initial condition (last entries of training data)
y_hat_0 = zeros(q*ny,1); % Y[k] at top
for row = 0:q-1 % First column of spaced Hankel matrix
    y_hat_0(row*ny+1:(row+1)*ny, 1) = y_test(:,q-row);
end

% Run model
Y_hat = zeros(length(y_hat_0),N_test); % Empty estimated Y
Y_hat(:,q) = y_hat_0; % Initial condition
for k = q:N_test-1
    Y_hat(:,k+1) = A*Y_hat(:,k) + B*u_test(:,k);
end

y_hat = Y_hat(1:ny, :); % Extract only non-delay time series

% Vector of Mean Absolute Error on testing data
MAE = sum(abs(y_hat - y_test), 2)./N_test; % For each measured state

