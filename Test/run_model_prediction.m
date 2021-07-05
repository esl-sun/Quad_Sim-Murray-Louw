%% Starting at different points in sim data, plot what would model predicts from that point

%% Extract data
dtheta_data = out.angle_rate.Data'; % payload angular velocity is an unmeasured state
mo_data     = out.mo.Data';
ov_data     = [dtheta_data; mo_data]; % Output Variables [UO; MO]
mv_data     = out.mv.Data';
ref_data    = out.ref.Data';
time        = out.mo.Time';
N           = length(time); % Number of data entries

interval_size = 5; % Size of increase in starting index for each loop run

run_duration = 10; % Window in seconds that model must make prediction for
end_index_window = floor(run_duration/Ts_mpc); % Window in number of indexes that model must make prediction for

for start = 100:interval_size:length(time) - index_window-1 % From different starting index each loop run

    %% Initial condition (starts at index = q of training data)
    y_hat_0 = ov_data(:,start); % Init condition of prediction

    % Run model
    Y_hat = zeros(length(y_hat_0),N); % Empty estimated Y
    Y_hat(:,start) = y_hat_0; % Initial condition
    index_window = start + (1:end_index_window) - 1; % Indexes in prediction
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

    % Plot
    figure(1)
    subplot(1,2,1)
    plot(time(index_window), Y_hat([2,3], index_window))
    hold on
    plot(time(index_window), ov_data([2,3], index_window), '--')
    plot(time(index_window), ref_data(2, index_window))
    plot(time(index_window), mv_data(:, index_window))
    hold off
    legend( 'predicted pos', 'predicted vel', 'actual pos', 'actual vel', 'pos-sp', 'acc-sp.x')
%     legend('dtheta', 'pos', 'vel', 'theta', 'pos-sp', 'acc-sp.x')
    
    pause
    
end
