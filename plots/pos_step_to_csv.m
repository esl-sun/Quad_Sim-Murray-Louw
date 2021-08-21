use_sitl_data = 1;
reload_data = 1; % Re-choose csv data file for SITL data
% extract_data;
write_csv = 1;

time = y_data.Time - y_data.Time(1) - 8; % Start at t=0s
theta = y_data.Data(:,2);

plot(time, theta)

selected_rows = 1:2:length(time); % Only save every second sample for tikz memory constraint

%% write to csv
if write_csv

    csv_matrix = [time, angle];
    
    csv_matrix = csv_matrix(selected_rows, :); % resample to make csv and tikz plot smaller
    
    csv_filename = ['/home/murray/Masters/Thesis/system_id/csv/', 'pos_step_', sim_type, '_', file_name, '.csv'];
    csv_filename

    VariableTypes = {'double', 'double'};
    VariableNames = {'time', 'theta'};
    csv_table = table('Size',size(csv_matrix),'VariableTypes',VariableTypes,'VariableNames',VariableNames);
    csv_table(:,:) = array2table(csv_matrix);

    writetable(csv_table,csv_filename)
end
