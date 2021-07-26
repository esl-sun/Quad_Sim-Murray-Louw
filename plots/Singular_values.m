% Plot MAE vs q for hyperparameters section in thesis
% First run HAVOK.m or DMD.m

figure
semilogy(diag(S1), 'x'), hold on;
title('Singular values of Omega, showing p truncation')
plot(p, S1(p,p), 'ro'), hold off;

S = S1(1:p, 1:p);
csv_matrix = [double(1:size(S,1))', diag(S)];

S = S1( (p+1):end, (p+1):end ); % Truncated singular values
csv_matrix_trunc = [double(p + (1:size(S,1)))', diag(S)];

figure
semilogy(csv_matrix(:,1),       csv_matrix(:,2),       'kx'), hold on;
semilogy(csv_matrix_trunc(:,1), csv_matrix_trunc(:,2), 'rx'), hold off;

hyper_str = ['_q', num2str(q), '_p', num2str(p)];

%% Non-truncated
csv_filename = ['/home/esl/Masters/Thesis/system_id/csv/', 'Singular_values_', sim_type, '_', simulation_data_file, '_', algorithm, payload_angle_str, T_train_str, hyper_str '.csv'];
csv_filename

VariableTypes = {'double',  'double'};
VariableNames = {'index',   'S'};
csv_table = table('Size',size(csv_matrix),'VariableTypes',VariableTypes,'VariableNames',VariableNames);
csv_table(:,:) = array2table(csv_matrix);

writetable(csv_table,csv_filename)

%% Truncated
csv_filename_trunc = ['/home/esl/Masters/Thesis/system_id/csv/', 'Singular_values_', sim_type, '_', simulation_data_file, '_', algorithm, payload_angle_str, T_train_str, hyper_str, '_trunc', '.csv'];

VariableTypes = {'double',  'double'};
VariableNames = {'index',   'S'};
csv_table_trunc = table('Size',size(csv_matrix_trunc),'VariableTypes',VariableTypes,'VariableNames',VariableNames);
csv_table_trunc(:,:) = array2table(csv_matrix_trunc);

writetable(csv_table_trunc,csv_filename_trunc)
