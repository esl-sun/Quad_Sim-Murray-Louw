% Initial condition (starts at index = q of training data)
y_hat_0 = zeros(q*ny,1); % Y[k] at top
for row = 0:q-1 % First column of spaced Hankel matrix
    y_hat_0(row*ny+1:(row+1)*ny, 1) = ov_data(3:4, start-row); % Insert delays
end

% Add initial position to top
y_hat_0 = [ov_data(2,start); y_hat_0];

% Add initial angular velocity to top
dtheta_0 = ov_data(1,start); % initial angular velocity
y_hat_0 = [dtheta_0; y_hat_0];
    
% Run model
Y_hat = zeros(length(y_hat_0),N); % Empty estimated Y
Y_hat(:,start) = y_hat_0; % Initial condition
index_window = start + (0:end_index_window-1); % Indexes in prediction
for k = index_window
    Y_hat(:,k+1) = A_havok*Y_hat(:,k) + B_havok*mv_data(:,k);
%     plot(time(index_window), Y_hat(1:(ny+2*num_axis), index_window))
%     legend('dtheta', 'pos', 'vel', 'theta')
%     pause
end

% Extract only non-delay time series
y_hat_bar = Y_hat(1:(ny+2*num_axis), :); 
ov_bar = ov_data(1:(ny+2*num_axis), :);

% Vector of Mean Absolute Error on testing data
MAE = sum(abs(y_hat_bar - ov_bar), 2)./N % For each measured state
