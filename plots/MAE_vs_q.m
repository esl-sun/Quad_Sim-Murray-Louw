% Plot MAE vs q for hyperparameters section in thesis
% First reun param_sweep.m
figure, hold on
csv_matrix = NaN*zeros(length(unique(results.q)), 4); % Empty matrix to for writing to csv [N_train, MAE_mean, MAE_1, MAE_2]
empty_row = 1;
% T_train = unique(results.N_train)*Ts
% T_train_str = ['_Ttrain_', num2str(T_train)];
for q = unique(results.q)'
    results_q = results((results.q == q), :); % Extract only results for this q
    MAE_mean = min(results_q.MAE_mean);
    results_q_best = results_q((results_q.MAE_mean == MAE_mean), :);

    MAE_1       = results_q_best.MAE_1;
    MAE_2       = results_q_best.MAE_2;    

%     plot(q, MAE_mean, '.')
    
    csv_matrix(empty_row, :) = [double(q), MAE_mean, MAE_1, MAE_2];
    empty_row = empty_row+1;
end

plot(csv_matrix(:,1), csv_matrix(:,2), '.')
ylabel('MAE_mean')
xlabel('q')

%% write to csv
csv_filename = ['/home/esl/Masters/Thesis/system_id/csv/', 'MAE_vs_q_', sim_type, '_', simulation_data_file, '_', algorithm, payload_angle_str, '.csv'];
csv_filename

VariableTypes = {'double',  'double',   'double', 'double'};
VariableNames = {'q',       'MAE_mean', 'MAE_1',  'MAE_2'};
csv_table = table('Size',size(csv_matrix),'VariableTypes',VariableTypes,'VariableNames',VariableNames);
csv_table(:,:) = array2table(csv_matrix);

writetable(csv_table,csv_filename)
