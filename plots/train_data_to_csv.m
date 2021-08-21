
reload_data = 1; % Re-choose csv data file for SITL data
extract_data;
write_csv = 1;

plot(t_train, y_train)

selected_rows = 1:2:length(t_train); % Only save every second sample for tikz memory constraint

%% write to csv
if write_csv
    t_train = t_train - t_train(1); % Start at t=0s
    csv_matrix = [t_train; y_train; u_train; vel_sp_train]';
    
    csv_matrix = csv_matrix(selected_rows, :); % resample to make csv and tikz plot smaller
    
    csv_filename = ['/home/murray/Masters/Thesis/system_id/csv/', 'training_data_', sim_type, '_', file_name, '.csv'];
    csv_filename

    VariableTypes = {'double', 'double', 'double', 'double', 'double'};
    VariableNames = {'time', 'vel', 'theta', 'acc_sp', 'vel_sp'};
    csv_table = table('Size',size(csv_matrix),'VariableTypes',VariableTypes,'VariableNames',VariableNames);
    csv_table(:,:) = array2table(csv_matrix);

    writetable(csv_table,csv_filename)
end
