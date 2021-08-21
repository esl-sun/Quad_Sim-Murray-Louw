% Plot MAE vs Ts for hyperparameters section in thesis
% First reun Ts_param_sweep.m

figure, hold on
csv_matrix = NaN*zeros(length(unique(results.q)), 4); % Empty matrix to for writing to csv [N_train, MAE_mean, MAE_1, MAE_2]
empty_row = 1;
T_train = unique(results.N_train)*Ts
for Ts = unique(results.Ts)'
    results_Ts = results((results.Ts == Ts), :); % Extract only results for this Ts
    MAE_mean = min(results_Ts.MAE_mean);
    results_Ts_best = results_Ts((results_Ts.MAE_mean == MAE_mean), :);

    MAE_1       = results_Ts_best.MAE_1;
    MAE_2       = results_Ts_best.MAE_2;    

    plot(Ts, MAE_mean, '.')
    
    csv_matrix(empty_row, :) = [double(Ts), MAE_mean, MAE_1, MAE_2];
    empty_row = empty_row+1;
end

plot(csv_matrix(:,1), csv_matrix(:,2), '.')
ylabel('MAE_mean')
xlabel('Ts')

%% write to csv
csv_filename = ['/home/murray/Masters/Thesis/system_id/csv/', 'MAE_vs_Ts_', sim_type, '_', simulation_data_file, '_', algorithm, payload_angle_str, '.csv'];
csv_filename

VariableTypes = {'double',  'double',   'double', 'double'};
VariableNames = {'Ts',      'MAE_mean', 'MAE_1',  'MAE_2'};
csv_table = table('Size',size(csv_matrix),'VariableTypes',VariableTypes,'VariableNames',VariableNames);
csv_table(:,:) = array2table(csv_matrix);

writetable(csv_table,csv_filename)
