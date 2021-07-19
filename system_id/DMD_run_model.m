
run.MAE_list = NaN*ones(ny,run.number); % Empty array for MAE of each run
run_index = 1; % Initialise
for start_index = start_index_list
    
    % Test data for this run
    y_run = y_test(:, start_index + (1:run.N) - 1);
    u_run = u_test(:, start_index + (1:run.N) - 1);
    t_run = t_test(:, start_index + (1:run.N) - 1);
    
    % Initial condition
    y_hat_0 = y_run(:,1);

    % Initial delay coordinates
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

    % Vector of Mean Absolute Error on testing data
    run.MAE_list(:,run_index) = sum(abs(y_hat - y_run), 2)./run.N; % For each measured state
    run_index = run_index+1;
    
    % Plot this run prediction
%     figure;
%     for i = 1:ny
%         subplot(2,1,i)
%         plot(t_run, y_run(i,:), 'b');
%         hold on;
%         plot(t_run, y_hat(i,:), 'r--', 'LineWidth', 1);
%         hold off;
%         legend('actual', 'predicted')
%         title(['DMD - run: ', num2str(run_index)]);
%     end
end

MAE = mean(run.MAE_list,2); % Take mean MAE of all test runs

%% Plot error vs start condition
% figure
% plot(t_test(start_index_list), run.MAE_list, '.')
% hold on
% plot(t_test, u_test*1e-2)
% hold off
% title('MAE for each run')