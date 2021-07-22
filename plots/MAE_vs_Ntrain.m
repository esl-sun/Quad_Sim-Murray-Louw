%% Plot Best MAE for each length of training data used
% first run system_id_setup.m to setup variables for this script

csv_matrix = NaN*zeros(length(unique(results.N_train)), 4); % Empty matrix to for writing to csv [N_train, MAE_mean, MAE_1, MAE_2]
empty_row = 1;
for N_train = unique(results.N_train)'
    
    results_Ntrain             = results((       results.N_train  == N_train),                      :);
    results_Ntrain_best = results_Ntrain((results_Ntrain.MAE_mean == min(results_Ntrain.MAE_mean)), :);
    MAE_mean    = results_Ntrain_best.MAE_mean;
    MAE_1       = results_Ntrain_best.MAE_1;
    MAE_2       = results_Ntrain_best.MAE_2;

    
    csv_matrix(empty_row, :) = [double(N_train*Ts), MAE_mean, MAE_1, MAE_2];
    empty_row = empty_row+1;
end

%% Plot
figure

x_limits = [0,      250];
y_limits = [0.01, 0.05];

subplot(1,3,1)
% plot(csv_matrix(:,1), csv_matrix(:,2), 'k.', 'MarkerSize', 10)
plot(csv_matrix(:,1), csv_matrix(:,2))
ylabel('MAE_mean')
xlabel('T_train [s]')
xlim(x_limits)
ylim(y_limits)

subplot(1,3,2)
plot(csv_matrix(:,1), csv_matrix(:,3))

hold on
plot(t_train-t_train(1), y_train(1,:) .* ( y_limits(2) - y_limits(1) ) ./ ( max(y_train(1,:)) - min(y_train(1,:)) ) + mean(y_limits) );

ylabel('MAE_1')
xlabel('T_train [s]')
xlim(x_limits)
ylim(y_limits)

subplot(1,3,3)
plot(csv_matrix(:,1), csv_matrix(:,4))
ylabel('MAE_mean')
xlabel('T_train [s]')
xlim(x_limits)
ylim(y_limits)

%% write to csv
csv_filename = ['/home/esl/Masters/Thesis/system_id/csv/', sim_type, '_MAE_vs_Ntrain_', simulation_data_file, '_', algorithm, '.csv'];
csv_filename

VariableTypes = {'double',  'double',   'double', 'double'};
VariableNames = {'T_train', 'MAE_mean', 'MAE_1',  'MAE_2'};
csv_table = table('Size',size(csv_matrix),'VariableTypes',VariableTypes,'VariableNames',VariableNames);
csv_table(:,:) = array2table(csv_matrix);

writetable(csv_table,csv_filename)








