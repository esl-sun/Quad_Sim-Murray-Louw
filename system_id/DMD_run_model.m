% Initial condition
y_hat_0 = y_test(:,q);

% Initial delay coordinates
y_delays = zeros((q-1)*ny,1);
k = q; % index of y_data
for i = 1:ny:ny*(q-1) % index of y_delays
    k = k - 1; % previos index of y_data
    y_delays(i:(i+ny-1)) = y_test(:,k);
end

% Run model
y_hat = zeros(ny,N_test); % Empty estimated Y
y_hat(:,1) = y_hat_0; % Initial condition
for k = 1:N_test-1
    upsilon = [y_delays; u_test(:,k)]; % Concat delays and control for use with B
    y_hat(:,k+1) = A_dmd*y_hat(:,k) + B_dmd*upsilon;
    if q ~= 1
        y_delays = [y_hat(:,k); y_delays(1:(end-ny),:)]; % Add y(k) to y_delay for next step [y(k); y(k-1); ...]
    end
end

% Vector of Mean Absolute Error on testing data
MAE = sum(abs(y_hat - y_test), 2)./N_test; % For each measured state
