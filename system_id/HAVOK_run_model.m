% Variables for running model prediction tests
% run.number = 10; % Number of runs done for test data
% run.window = 20; % [s] Prediction time window/period used per run  
% run.N = floor(run.window/Ts); % number of data samples in prediction window
% % Interval between start indexes to fit number of runs into test data
% MAE_weight = [1; 1]./max(abs(y_train),[],2); % Weighting of error of each state when calculating mean

index_interval = floor((N_test - run.N - q)/run.number); % Space need for delays at start of data (q), and last run still needs space to run to (run.N)
start_index_list = q + (1:index_interval:run.number*index_interval); % Start indexes for each prediction run

run.MAE_list = NaN*ones(ny,run.number); % Empty array for MAE of each run
run_index = 1; % Initialise
for start_index = start_index_list
    
    % Test data for this run
    y_run = y_test(:, start_index + (1:run.N) - 1);
    u_run = u_test(:, start_index + (1:run.N) - 1);
    t_run = t_test(:, start_index + (1:run.N) - 1);

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


    % Vector of Mean Absolute Error on testing data
    cur_MAE = (sum(abs(y_hat - y_run), 2)./run.N).*MAE_weight;
    run.MAE_list(:,run_index) = cur_MAE; % For each measured state
    run_index = run_index+1;
    
    % Plot this run prediction
    if plot_predictions
        figure;
        for i = 1:ny
            subplot(2,1,i)
            plot(t_run, y_run(i,:), 'b');
            hold on;
            plot(t_run, y_hat(i,:), 'r--', 'LineWidth', 1);
            hold off;
            legend('actual', 'predicted')
            title(['DMD - run: ', num2str(run_index)]);
        end
    end
end

MAE = max(run.MAE_list,[],2); % Take mean MAE of all test runs

%% Plot error vs start condition
if plot_predictions
    figure
    plot(t_test(start_index_list), run.MAE_list, '.')
    hold on
    plot(t_test, u_test*1e-2)
    hold off
    title('MAE for each run')
end