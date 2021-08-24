%% Take one of plot predictions in run_model.m and write to csv file

% First run multiple_system_id_runs.m
% Then run DMD.m
% this script is called from DMD.m > run_model.m

disp(['Plotting start_index:', num2str(start_index)])

t_run = t_run - t_run(1); % start at t=0s
% y_run(1,:) = y_run(1,:) - y_run(1,1) % start at vel=0s
csv_matrix = [t_run; u_run; y_run; y_hat]';

csv_filename = ['/home/murray/Masters/Thesis/', chapter, '/csv/', 'step_predictions_', sim_type, '_', file_name, '_', algorithm, '_', num2str(plot_index), '.csv'];
csv_filename

switch control_vel_axis
    case 'x'
        VariableTypes = {'double',  'double',   'double',   'double',   'double',   'double'};
        VariableNames = {'time',    'acc_sp',   'vel',      'theta',    'vel_hat',  'theta_hat'};
    case 'xy'
        VariableTypes = {'double',  'double',   'double',   'double',   'double',   'double',   'double',   'double',       'double',       'double',       'double'};
        VariableNames = {'time',    'acc_x_sp', 'acc_y_sp', 'vel_x',    'vel_y',    'theta_x',  'theta_y',  'vel_x_hat',    'vel_y_hat',    'theta_x_hat',  'theta_y_hat'};
end

csv_table = table('Size',size(csv_matrix),'VariableTypes',VariableTypes,'VariableNames',VariableNames);
csv_table(:,:) = array2table(csv_matrix);

writetable(csv_table,csv_filename)

