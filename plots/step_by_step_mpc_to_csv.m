%% Take data from step_by_step_mpc.m an convert to CSV for plot in thesis
% Run stepby_step_mpc.m
% Press enter until plot is generated that you want
% Press Cntrl + C to kill script
% Run this script to generate CSV

write_csv = 1;
chapter = 'control';
added_comment = '';


time = info.Topt + t(k);

vel_sp = ref_data(2,(0:PH)+k)';
prediction.vel = info.Yopt(:,2);
actual.vel = ov_data(2,(0:PH)+k)';

prediction.theta = info.Yopt(:,3) * 180/pi; % [deg]
actual.theta = ov_data(3,(0:PH)+k)' * 180/pi; % [deg]

prediction.vel = prediction.vel - (prediction.vel(1) - actual.vel(1)); % Start at same y

prediction.acc_sp = info.Uopt; % prediction setpoint
actual.acc_sp = mv_data(:,(0:PH)+k)'; % actual setpoint

%% plot velocity
figure(1)
plot(time, prediction.vel);
hold on;
plot(time, vel_sp)
plot(time, actual.vel, ':', 'LineWidth', 2)

legend('prediction', 'ref', 'actual')
hold off;

%% plot theta
figure(2)
plot(time, prediction.theta);
hold on;
plot(time, actual.theta, ':', 'LineWidth', 2)

legend('prediction', 'actual')
hold off;

%% plot acc_sp

figure(3)
plot(time, prediction.acc_sp)
hold on;
plot(time, actual.acc_sp, ':', 'LineWidth', 2) % Actual input given
hold off;
legend('optimised', 'actual')
title('Input given')

%% Get data for CSV
selected_rows = 1:2:length(time); % Only save every second sample for tikz memory constraint

csv_matrix = [ ...
    time, ...
    prediction.vel, ...
    actual.vel, ...
    vel_sp, ...
    prediction.theta, ...
    actual.theta  ]; % Data to write to csv

VariableNames = {'time',    'prediction.vel',   'actual.vel',   'vel_sp',   'prediction.theta',  'actual.theta'};
VariableTypes = {'double',  'double',           'double',       'double',   'double',            'double'};

csv_matrix = csv_matrix(selected_rows, :); % resample to make csv and tikz plot smaller

%% write to csv
if write_csv
  
    csv_filename = [getenv('HOME'), '/Masters/Thesis/', chapter, '/csv/',...
                    'mpc_prediction_vs_actual_', sim_type, '_', simulation_data_file, added_comment, '.csv'];
    csv_filename

    csv_table = table('Size',size(csv_matrix),'VariableTypes',VariableTypes,'VariableNames',VariableNames);
    csv_table(:,:) = array2table(csv_matrix);

    writetable(csv_table,csv_filename)
end
