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

VariableTypes = {'double',  'double',   'double',   'double',   'double',   'double'};
VariableNames = {'time',    'acc_sp',   'vel',      'theta',    'vel_hat',  'theta_hat'};
csv_table = table('Size',size(csv_matrix),'VariableTypes',VariableTypes,'VariableNames',VariableNames);
csv_table(:,:) = array2table(csv_matrix);

writetable(csv_table,csv_filename)

