%% Starting at different points in sim data, plot what would model predicts from that point

% Initial condition (starts at index = q of training data)
y_hat_0 = zeros(q*ny,1); % Y[k] at top
for row = 0:q-1 % First column of spaced Hankel matrix
    y_hat_0(row*ny+1:(row+1)*ny, 1) = y_test(:,q-row);
end

% Add initial position to top
% y_hat_0 = [p_test(:,q); y_hat_0];
y_hat_0 = [0; y_hat_0]; % Add placeholder

% Add initial angular velocity to top
switch num_axis
    case 1 % y_test = [vx; angle_x ... delays]
        dtheta_0 = 1/Ts * y_test(2, q)  -  1/Ts * y_test(2, q-1); % initial angular velocity
    case 2 % y_test = [vx; vy; angle_x; angle_y... delays]
        dtheta_0 = 1/Ts * y_test([3 4], q)  -  1/Ts * y_test([3 4], q-1); % initial angular velocity
end
y_hat_0 = [dtheta_0; y_hat_0];

% Run model
figure
Y_hat = zeros(length(y_hat_0),N_test); % Empty estimated Y
Y_hat(:,q) = y_hat_0; % Initial condition
for k = q:N_test-1
    Y_hat(:,k+1) = A_havok*Y_hat(:,k) + B_havok*u_test(:,k);
%     plot(t_test, Y_hat(1:(ny+num_axis), :))
%     legend('pos', 'vel', 'theta')
%     pause
end

y_hat_bar = Y_hat(1:(ny+2*num_axis), :); % Extract only non-delay time series and position

% Vector of Mean Absolute Error on testing data
switch num_axis
    case 1
        MAE = sum(abs(y_hat_bar(3:end,:) - y_test), 2)./N_test % For each measured state
    case 2
        MAE = sum(abs(y_hat_bar(5:end,:) - y_test), 2)./N_test % For each measured state
end
