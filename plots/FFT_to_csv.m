% Write to csv FFT amplitude from estimate_pendulum_length.m
% First reun param_sweep.m
figure
plot(f,P1)
csv_matrix = [f', P1];

%% write to csv
csv_filename = [getenv('HOME'), '/Masters/Thesis/', chapter, '/csv/', 'FFT_vel_step_', sim_type, '_', simulation_data_file, '.csv'];
csv_filename

VariableTypes = {'double',  'double'};
VariableNames = {'f',       'P1'};
csv_table = table('Size',size(csv_matrix),'VariableTypes',VariableTypes,'VariableNames',VariableNames);
csv_table(:,:) = array2table(csv_matrix);

writetable(csv_table,csv_filename)
