%% Bare bones of extract_data.m for use with Ts_param_sweep.m

% Test/Train split
T_test = 100; % [s] Time length of training data
test_time = time_offset + (0:Ts:T_test)';

data_end_time = y_data.Time(end) - 20; % Max length of data available. clip last bit.
train_time = (test_time(end):Ts:data_end_time)';

% Training data
y_train = resample(y_data, train_time );% Resample time series to desired sample time and training period  
u_train = resample(u_data, train_time );  
vel_sp_train = resample(vel_sp_data, train_time );  % For us in SITL_vs_Simulink_training.m
t_train = y_train.Time';
N_train = length(t_train);

y_train = y_train.Data';
u_train = u_train.Data';
vel_sp_train = vel_sp_train.Data(:,1)';

% Testing data
y_test = resample(y_data, test_time );  
u_test = resample(u_data, test_time );  
t_test = y_test.Time';
N_test = length(t_test); % Num of data samples for testing

y_test = y_test.Data';
u_test = u_test.Data';

% Remove offset / Centre input around zero
u_bar = mean(u_train, 2)
u_train = u_train - u_bar;

% Re-calculate u_bar for test data, because acc_sp offset drifts
u_bar_test = mean(u_test, 2)
u_test = u_test - u_bar_test;

% Dimentions
ny = size(y_train,1);
nu = size(u_train,1);

% Save u_bar differently for SITL and Simulink
if use_sitl_data
    u_bar_sitl = u_bar
else
    u_bar_simulink = u_bar
end

%% Plot 
% figure
% plot(t_train, y_train)
% hold on
% plot(t_train, u_train)
% hold off
% title('Training data')
% legend('vel x', 'angle E', 'acc sp x')
% 
% figure
% plot(t_test, y_test)
% hold on
% plot(t_test, u_test)
% hold off
% title('Testing data')
% legend('vel x', 'angle E', 'acc sp x')








