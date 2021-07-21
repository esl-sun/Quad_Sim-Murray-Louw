%% Starting at different points in sim data, plot what would model predicts from that point

%% Extract data
dtheta_data = out.angle_rate.Data'; % payload angular velocity is an unmeasured state
mo_data     = out.mo.Data';
ov_data     = [dtheta_data; mo_data]; % Output Variables [UO; MO]
mv_data     = out.mv.Data';
ref_data    = out.ref.Data';
time        = out.mo.Time';
N           = length(time); % Number of data entries

Ts = Ts_mpc;

interval_size = 5; % Size of increase in starting index for each loop run

run_duration = 10; % Window in seconds that model must make prediction for
end_index_window = floor(run_duration/Ts_mpc); % Window in number of indexes that model must make prediction for

%% Get models

% start_folder = [pwd, '/system_id/SITL/*.mat'];
% [model_file_name, model_parent_dir] = uigetfile(start_folder, 'Choose SITL MODEL .mat file')
% model_file.sitl = (strcat(model_parent_dir, '/', model_file_name));
%     
% start_folder = [pwd, '/system_id/Simulink/*.mat'];
% [model_file_name, model_parent_dir] = uigetfile(start_folder, 'Choose Simulink MODEL .mat file')
% model_file.simulink = (strcat(model_parent_dir, '/', model_file_name));

for start = 100:interval_size:length(time) - index_window-1 % From different starting index each loop run
    
    %% SITL model
    load(model_file.sitl) % Load plant model from saved data

    % Run loop with model in
    run_model
    
    % Plot predictions
    figure(1)
    subplot(1,2,1)
    plot(time(index_window), Y_hat([2,3], index_window))
    hold on
    plot(time(index_window), ov_data([2,3], index_window), '--')
    plot(time(index_window), ref_data(2, index_window))
    plot(time(index_window), mv_data(:, index_window))
    hold off
    title('SITL model')
    legend( 'predicted pos', 'predicted vel', 'actual pos', 'actual vel', 'pos-sp', 'acc-sp.x')
    
    % Plot error
    figure(2)    
    plot(time(index_window), abs(ov_data([3], index_window) - Y_hat([3], index_window)))
    ylim([-0.8, 0.8])
    hold on
    title('Pos and Vel error')
    
    %% Simulink model
    load(model_file.simulink) % Load plant model from saved data

    % Run loop with model in
    run_model
    
    % Plot
    figure(1)
    subplot(1,2,2)
    plot(time(index_window), Y_hat([2,3], index_window))
    hold on
    plot(time(index_window), ov_data([2,3], index_window), '--')
    plot(time(index_window), ref_data(2, index_window))
    plot(time(index_window), mv_data(:, index_window))
    hold off
    title('Simulink model')
    legend( 'predicted pos', 'predicted vel', 'actual pos', 'actual vel', 'pos-sp', 'acc-sp.x')
    
    % Plot error
    figure(2)
    plot(time(index_window), abs(ov_data([3], index_window) - Y_hat([3], index_window)))
    title('Pos and Vel error')
    legend('sitl velocity error', 'simulink vel error')
    ylim([-0.8, 0.8])
    hold off
    pause
    
end
   
