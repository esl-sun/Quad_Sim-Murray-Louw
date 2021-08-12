%% Run algorithm compared to test data with different starting conditions

% Interval between start indexes to fit number of runs into test data:
index_interval = floor((N_test - run.N - q)/run.number); % Space need for delays at start of data (q), and last run still needs space to run to (run.N)
start_index_list = q + (1:index_interval:run.number*index_interval); % Start indexes for each prediction run

run.MAE_list = NaN*ones(ny,run.number); % Empty array for MAE of each run
run_index = 1; % Initialise

for start_index = start_index_list
    
    % Test data for this run
    y_run = y_test(:, start_index + (1:run.N) - 1);
    u_run = u_test(:, start_index + (1:run.N) - 1);
    t_run = t_test(:, start_index + (1:run.N) - 1);
    
    switch algorithm
        case 'dmd'
            % Initial condition of state vector
            y_hat_0 = y_run(:,1);
    
            % Initial condition of delay coordinates
            y_delays = zeros((q-1)*ny,1);
            k = start_index; % index of y_data
            for i = 1:ny:ny*(q-1) % index of y_delays
                k = k - 1; % previos index of y_data
                y_delays(i:(i+ny-1)) = y_test(:,k); % starting at y(k-1) first delay
            end

            % Run model
            y_hat = zeros(ny,run.N); % Empty estimated Y
            y_hat(:,1) = y_hat_0; % Initial condition
            for k = 1:run.N-1
                upsilon = [y_delays; u_run(:,k)]; % Concat delays and control for use with B
                y_hat(:,k+1) = A_dmd*y_hat(:,k) + B_dmd*upsilon;
                if q ~= 1
                    y_delays = [y_hat(:,k); y_delays(1:(end-ny),:)]; % Add y(k) to y_delay for next step [y(k); y(k-1); ...]
                end
            end

        case 'havok'            
            % Initial condition of augented state including delays
            y_hat_0 = zeros(q*ny,1); % Y[k] at top
            for row = 0:q-1 % First column of spaced Hankel matrix
                y_hat_0(row*ny+1:(row+1)*ny, 1) = y_test(:,start_index - row);
            end

            % Run model
            Y_hat = zeros(length(y_hat_0),run.N); % Empty estimated Y
            Y_hat(:,1) = y_hat_0; % Initial condition
            for k = 1:run.N-1
                Y_hat(:,k+1) = A*Y_hat(:,k) + B*u_run(:,k);
            end

            y_hat = Y_hat(1:ny, :); % Extract only non-delay time series
        case 'white'
            dtheta_run = dtheta_test(:, start_index + (1:run.N) - 1);
    
            % dx = A*x + B*u;
            % x = [integral, vn, theta, dtheta]
            x0 = [0; y_run(:,1); dtheta_run(:,1)];
            t_span = t_run - t_run(1); % Start at zero]
            [t,X_hat] = ode45( @(t,x) LQR.A*x + LQR.B*( u_run(:,floor(t/Ts)+1) ), t_span, x0);
            y_hat = X_hat(:,[2,3])'; % Extract only non-delay time series

            % Use finer resolution in ode
%             x0 = [0; y_run(:,1); dtheta_run(:,1)];
%             Ts_ode = 0.001;
%             t_span = 0:Ts_ode:(t_run(end)-t_run(1)+Ts_ode);
%             [t,X_hat] = ode45( @(t,x) LQR.A*x + LQR.B*( u_run(:,floor(t/Ts)+1) ), t_span, x0);
% %             plot(t, X_hat)
%             X_hat_ts = timeseries(X_hat, t+t_run(1));
%             X_hat_ts = resample(X_hat_ts, t_run);
%             X_hat = X_hat_ts.Data;
%             y_hat = X_hat(:,[2,3])'; % Extract only non-delay time series
    
    end

    % Vector of Mean Absolute Error on testing data
%     baseline_MAE = sum(abs(y_run(:,1) - y_run), 2)./run.N; % Error if model = initial condition
%     cur_MAE = (sum(abs(y_hat - y_run), 2)./run.N)./baseline_MAE;
    
    if use_MAE_diff
        cur_MAE = (sum(abs(diff(y_hat,1,2) - diff(y_run,1,2)), 2) ./ (run.N-1)).*MAE_diff_weight;
        % cur_MAE = (cur_MAE + cur_MAE_diff)./2;
        % cur_MAE_diff2 = (sum(abs(diff(y_hat,2,2) - diff(y_run,2,2)), 2) ./ (run.N-2));
        % cur_MAE = cur_MAE_diff2;
    else
        cur_MAE      = (sum(abs(     y_hat      -      y_run     ), 2) ./  run.N   ).*MAE_weight;
    end

    run.MAE_list(:,run_index) = cur_MAE; % For each measured state
    run_index = run_index+1;
    
    % Plot this run prediction
    if plot_predictions
        figure;
        for i = 1:ny
            subplot(ny,1,i)
            if use_MAE_diff % Use MAE metric of diff of predicition
                plot(t_run(3:end), diff(y_run(i,:),2,2), 'b');
                hold on;
                plot(t_run(3:end), diff(y_hat(i,:),2,2), 'r--', 'LineWidth', 1);
                hold off;
            else
                plot(t_run, y_run(i,:), 'b');
                hold on;
                plot(t_run, y_hat(i,:), 'r--', 'LineWidth', 1);
                hold off;
            end
            
            legend('actual', 'predicted')
            title(['MAE 1: ', num2str(cur_MAE(1)), ' MAE 2: ', num2str(cur_MAE(2)), ' run index: ', num2str(run_index)]);
        end
    end
end

MAE = mean(run.MAE_list,2); % Take worst MAE of all test runs

%% Plot error vs start condition
if plot_predictions
    figure
    plot(t_test(start_index_list), run.MAE_list, '.')
    hold on
    plot(t_test, u_test*1e-2)
    hold off
    title('MAE for each run')
end