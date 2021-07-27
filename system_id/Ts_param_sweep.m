%% Sample time Parameter sweep of DMD or HAVOK
% Grid search of parameters, N_train, q, and p
% Saves all the results for different parameter combinations

% Choose script to run param sweep
use_sitl_data = 1;
reload_data = 1; % Re-choose csv data file for SITL data
plot_results = 0;
use_MAE_diff = 0; % Use MAE metric of diff of predicitons and signal

use_angular_rate = 0;
algorithm = 'dmd'; % 'dmd' or 'havok'

% Extract data
Ts = 0.03; % dummy unused Ts
extract_data;
reload_data = 0;

% close all;
total_timer = tic; % Start timer for this script

% Max Min settings
Ts_max = 0.05;
Ts_min = 0.005;
Ts_increment = 0.005;

N_train_min = 1500; % [s] Min value of training period in grid search
N_train_max = 4000; % Max value of training period in grid search
N_train_increment = 500; % Increment value of training period in grid search

q_min = 6; % Min value of q in grid search
q_max = 26; % Max value of q in grid search
q_increment = 2; % Increment value of q in grid search

p_min = 2; % Min value of p in grid search
p_max = q_max*4; % Max value of p in grid search
p_increment = 2; % Increment value of p in grid search

% Search space
Ts_search = Ts_min:Ts_increment:Ts_max;
T_train_search = T_train_max:-T_train_increment:T_train_min; % Start at max go to min
q_search = q_min:q_increment:q_max; % List of q parameters to search in

% Variables for running model prediction tests
run.number = 10; % Number of runs done for test data
run.window = 20; % [s] Prediction time window/period used per run  
run.N = floor(run.window/Ts); % number of data samples in prediction window
MAE_weight      = 1./sqrt(max(abs(     y_train     ),[],2)); % Weighting of error of each state when calculating mean
MAE_diff_weight = 1./sqrt(max(abs(diff(y_train,1,2)),[],2)); % Weighting of error of derivative each state when calculating mean
plot_predictions = 0; % Always set to 0 when looping DMD_run_model.m otherwiee opens many plots

% String for saved model filename
if use_angular_rate
    payload_angle_str = '_angular_rate';
else
    payload_angle_str = '_angle';
end

% Create empty results table
VariableTypes = {'double', 'int16',   'int16', 'int16', 'double'}; % id, q, p, MAE
VariableNames = {'Ts',     'N_train', 'q',     'p',     'MAE_mean'};
for i = 1:ny % Mae column for each measured state
    VariableNames = [VariableNames, strcat('MAE_', num2str(i))];
    VariableTypes = [VariableTypes, 'double'];
end
Size = [length(q_search)*length(p_min:p_increment:p_max), length(VariableTypes)];

% Simulator type
if use_sitl_data
    sim_type = 'SITL'; % Choose source of data: SITL or Simulink
else
    sim_type = 'Simulink'; % Choose source of data: SITL or Simulink
end
uav_folder = ['system_id/', sim_type, '/', uav_name]; % Base folder for this uav

% Read previous results
results_file = [uav_folder, '/results/', simulation_data_file, '_', algorithm, payload_angle_str, '.mat'];
try
    load(results_file);
    results(~results.q,:) = []; % remove empty rows
    results = [results; table('Size',Size,'VariableTypes',VariableTypes,'VariableNames',VariableNames)];
    
catch
    disp('No saved results file')  
    
    results = table('Size',Size,'VariableTypes',VariableTypes,'VariableNames',VariableNames);
    emptry_row = 1; % Keep track of next empty row to insert results 
end

% Grid search
format compact % display more compact
for Ts = Ts_search
    Ts
 
    run.N = floor(run.window/Ts); % number of data samples in prediction window
    MAE_weight      = 1./sqrt(max(abs(     y_train     ),[],2)); % Weighting of error of each state when calculating mean
    MAE_diff_weight = 1./sqrt(max(abs(diff(y_train,1,2)),[],2)); % Weighting of error of derivative each state when calculating mean
    
    Ts_extract_data; % Resample training and testing data
    
    for N_train = N_train_search
        disp('-------------------------------')

        % Starting at max value, cut data to correct length
        y_train = y_train(:, 1:N_train);
        u_train = u_train(:, 1:N_train);
        t_train = t_train(:, 1:N_train);

        for q = q_search
                q_is_new = 1; % 1 = first time using this q this session
                q
                tic;

                p_max_new = min([p_max, q*ny]); % Max p to avoid out of bounds 
                p_search = p_min:p_increment:p_max_new; % List of p to search, for every q
                for p = p_search
                    p_is_new = 1; % 1 = first time using this p this session

                    if ~isempty(find(results.q == q & results.p == p & results.Ts == Ts & results.N_train == N_train, 1)) 
                        continue % continue to next p if this combo has been searched before
                    end

                    if q_is_new % Do this only when q is seen first time
                        q_is_new = 0; % q is no longer new

                        switch algorithm
                            case 'dmd'                       
                                DMD_part_1;
                            case 'havok'
                                HAVOK_part_1;
                        end
                    end

                    switch algorithm
                        case 'dmd'                       
                            DMD_part_2;                        
                        case 'havok'
                            HAVOK_part_2;                        
                    end

                    run_model;

                    % Save results
                    results(emptry_row,:) = [{Ts, N_train, q, p, mean(MAE)}, num2cell(MAE')]; % add to table of results
                    emptry_row = emptry_row + 1; 

                end % p

                save(results_file, 'results', 'emptry_row')
                toc;
        end % q
    end % N_train
end

% Save results
results(~results.q,:) = []; % remove empty rows
save(results_file, 'results', 'emptry_row')

best_mean_results = results((results.MAE_mean == min(results.MAE_mean)),:)

% Write csv
MAE_vs_Ts;

%% Plot results

y_limits = [2e-3, 1e0];

figure
semilogy(results.q, results.MAE_mean, '.')
grid on
ylabel('MAE of prediction');
xlabel('Number of delays in model, q');
ylim(y_limits)
title(['DMD, best q = ', num2str(best_mean_results.q)])


figure
subplot(1,3,1)
semilogy(results.N_train.*Ts, results.MAE_mean, '.')
grid on
ylabel('MAE_mean');
xlabel('T_train');
ylim(y_limits)
title(['DMD, best q = ', num2str(best_mean_results.q)])

subplot(1,3,2)
semilogy(results.N_train.*Ts, results.MAE_1, '.')
grid on
ylabel('MAE 1');
xlabel('T_train');
ylim(y_limits)
title(['DMD, best q = ', num2str(best_mean_results.q)])

subplot(1,3,3)
semilogy(results.N_train.*Ts, results.MAE_2, '.')
grid on
ylabel('MAE 2');
xlabel('T_train');
ylim(y_limits)
title(['DMD, best q = ', num2str(best_mean_results.q)])

%% plot Ts
figure
semilogy(results.Ts, results.MAE_mean, '.')
grid on
ylabel('MAE_mean');
xlabel('Ts');
ylim(y_limits)
title(['Ts'])

% %% plot q
% figure
% semilogy(results.q, results.MAE_mean, '.')
% grid on
% ylabel('MAE_mean');
% xlabel('p');
% ylim(y_limits)
% title(['Checkout effect of Q'])

% %% Only for this Ts:
% results_Ts = results((results.Ts == Ts),:);
% best_results_Ts = results_Ts((results_Ts.MAE_mean == min(results_Ts.MAE_mean)),:)
% 
% total_time = toc(total_timer); % Display total time taken
% 
% %% For one q:
% results_q = results((results.q == best_mean_results.q),:);
% figure
% % semilogy(results_q.p, results_q.MAE_1, 'r.')
% % hold on
% semilogy(results_q.p, results_q.MAE_mean, 'k.')
% % hold off
