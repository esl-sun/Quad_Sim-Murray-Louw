chapter = 'results' % or 'system_id'
reload_data = 0;
write_csv = 0;
algorithm = 'dmd'; % or 'white' for lqr white-box model
Ts = 0.03;

if reload_data
    [single.file_name, single.parent_dir] = uigetfile('/home/esl/Masters/Developer/MATLAB/Quad_Sim_Murray/system_id/SITL/*.csv', 'Choose SINGLE STEP SITL log DATA csv file (from logger.y)')
    single.data_path = strcat(single.parent_dir, single.file_name);
    single.data = readmatrix(single.data_path);
end

time = single.data(:,1);
time = (time-time(1)); % Time in seconds

vel.x = single.data(:,5); % Local NED x velocity
vel_sp.x = single.data(:,11); % Local NED x velocity setpoint
acc_sp.x = single.data(:,14); % Local NED x acceleration setpoint
angle.y = single.data(:,18);
angle_rate.y = single.data(:,21);

y_data_noise = [vel.x, angle.y]; % Data still noisy
u_data_noise = [acc_sp.x];
dtheta_data_noise = angle_rate.y;

% Smooth data (Tune window size till data still represented well)
y_data_smooth = smoothdata(y_data_noise, 'loess', 20);
u_data_smooth = smoothdata(u_data_noise, 'gaussian', 8); % Smooth u differently because of non-differentialable spikes
dtheta_data_smooth = smoothdata(dtheta_data_noise, 'loess', 20);

%% Plot smooth
% figure
% plot(time, y_data_smooth)
% hold on
% plot(time, y_data_noise)
% 
% figure
% plot(time, u_data_smooth)
% hold on
% plot(time, u_data_noise)

% Create timeseries 
y_data = timeseries(y_data_smooth, time);
u_data = timeseries(u_data_smooth, time);
dtheta_data = timeseries(dtheta_data_smooth, time);

% Testing data
time_start = 52;
time_end = time_start + 42;
test_time = time_start:Ts:time_end;
y_test = resample(y_data, test_time );  
u_test = resample(u_data, test_time );
dtheta_test = resample(dtheta_data, test_time );
t_test = y_test.Time';
N_test = length(t_test); % Num of data samples for testing

y_test = y_test.Data';
u_test = u_test.Data';

figure
plot(t_test, y_test)
title('Test y data')

%% Get offset of input data
figure
plot(u_test)
title('Test input data')
disp('Click start then stop index to calculate u_bar:')
% [u_bar_index,~] = ginput(2)
% u_bar = mean(u_test(:, u_bar_index(1):u_bar_index(2)), 2); % Use user selected indexes to determine offset
u_bar = mean(u_test,2);
u_test = u_test - u_bar;

plot(t_test, u_test)
title('Test input data')

disp('u_bar calculated.')

dtheta_test = dtheta_test.Data';

%% Run model prediction
start_index = q+1;

% Test data for this run
y_run = y_test(:, start_index:end);
u_run = u_test(:, start_index:end);
t_run = t_test(:, start_index:end);
run.N = length(t_run);

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
        y_hat(1,:) = y_hat(1,:) - y_hat(1,1); % Start vel at 0

        dmd.y_hat = y_hat;

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
        y_hat(1,:) = y_hat(1,:) - y_hat(1,1); % Start vel at 0

        havok.y_hat = y_hat;
        
    case 'white'
        dtheta_run = dtheta_test(:, start_index:end);

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
        
        y_hat(1,:) = y_hat(1,:) - y_hat(1,1); % Start vel at 0

        white.y_hat = y_hat;
end

%% Plot
y_run(1,:) = y_run(1,:) - y_run(1,1); % Start vel at 0
t_run = t_run - t_run(1); % Start at t=0s

figure
plot(t_run, y_run)
hold on
plot(t_run, y_hat, 'k--')

%% write to csv
if write_csv
    
    csv_matrix = [t_run; u_run; y_run; havok.y_hat; dmd.y_hat; white.y_hat]';

    csv_filename = ['/home/esl/Masters/Thesis/', chapter, '/csv/', 'single_step_predictions_', sim_type, '_', single.file_name, '.csv'];
    csv_filename

    VariableTypes = {'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double'};
    VariableNames = {'time', 'acc_sp', 'vel', 'theta', 'vel_havok', 'theta_havok', 'vel_dmd', 'theta_dmd', 'vel_white', 'theta_white'};
    csv_table = table('Size',size(csv_matrix),'VariableTypes',VariableTypes,'VariableNames',VariableNames);
    csv_table(:,:) = array2table(csv_matrix);

    writetable(csv_table,csv_filename)
end
