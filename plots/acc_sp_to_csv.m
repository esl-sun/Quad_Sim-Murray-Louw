% Remove u_bar correction from extract_data.m

selected_rows = 1:2:length(t_train); % Only save every second sample for tikz memory constraint

t_train = t_train - t_train(1); % Start at t=0s
csv_matrix = [t_train; y_train; u_train; vel_sp_train]';

csv_matrix = csv_matrix(selected_rows, :); % resample to make csv and tikz plot smaller

csv_filename = [getenv('HOME'), '/Masters/Thesis/system_id/csv/', 'acc_sp_offset_', sim_type, '_', file_name, '.csv'];
csv_filename

VariableTypes = {'double', 'double', 'double', 'double', 'double'};
VariableNames = {'time', 'vel', 'theta', 'acc_sp', 'vel_sp'};
csv_table = table('Size',size(csv_matrix),'VariableTypes',VariableTypes,'VariableNames',VariableNames);
csv_table(:,:) = array2table(csv_matrix);

writetable(csv_table,csv_filename)