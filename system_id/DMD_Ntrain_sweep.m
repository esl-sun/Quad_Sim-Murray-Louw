%% Implentation of DMD
% Grid search of parameters
% Saves all the results for different parameter combinations

reload_data = 1; % Re-choose csv data file for SITL data
plot_results = 1;

Ts = 0.03; % Desired sample time
Ts_dmd = Ts;

% Extract data
extract_data;

% close all;
total_timer = tic; % Start timer for this script

% % Search space
T_train_min = 20; % [s] Min value of training period in grid search
T_train_max = 180; % Max value of training period in grid search
T_train_increment = 40; % Increment value of training period in grid search

q_min = 15; % Min value of q in grid search
q_max = 30; % Max value of q in grid search
q_increment = 1; % Increment value of q in grid search

p_min = 2; % Min value of p in grid search
p_max = q_max*4; % Max value of p in grid search
p_increment = 1; % Increment value of p in grid search

T_train_search = T_train_max:-T_train_increment:T_train_min; % Start at max go to min
N_train_search = floor(T_train_search./Ts); % Convert time period to number of data samples
q_search = q_min:q_increment:q_max; % List of q parameters to search in
% % p_search defined before p for loop

% Variables for running model prediction tests
run.number = 10; % Number of runs done for test data
run.window = 20; % [s] Prediction time window/period used per run  
run.N = floor(run.window/Ts); % number of data samples in prediction window
% Interval between start indexes to fit number of runs into test data
MAE_weight = [1; 1]./sqrt(max(abs(y_train),[],2)); % Weighting of error of each state when calculating mean
plot_predictions = 0; % Always set to 0 when looping DMD_run_model.m otherwiee opens many plots

% Create empty results table
VariableTypes = {'double', 'int16',   'int16', 'int16', 'double'}; % id, q, p, MAE
VariableNames = {'Ts',     'N_train', 'q',     'p',     'MAE_mean'};
for i = 1:ny % Mae column for each measured state
    VariableNames = [VariableNames, strcat('MAE_', num2str(i))];
    VariableTypes = [VariableTypes, 'double'];
end
Size = [length(q_search)*length(p_min:p_increment:p_max), length(VariableTypes)];

% Read previous results
results_file = [uav_folder, '/results/dmd_results_', simulation_data_file, '.mat'];

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
for N_train = N_train_search
    
    % Starting a max value, cut data to correct length
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

                    DMD_part_1;
                end

                DMD_part_2;

                DMD_run_model;

                % Save results
%                 results(emptry_row,:) = [{Ts, N_train, q, p, mean(MAE.*MAE_weight)}, num2cell(MAE')]; % add to table of results
                results(emptry_row,:) = [{Ts, N_train, q, p, mean(MAE)}, num2cell(MAE')]; % add to table of results
                emptry_row = emptry_row + 1; 

            end % p

            save(results_file, 'results', 'emptry_row')
            toc;
    end % q
end % N_train
format short % back to default/short display

% Save results
results(~results.q,:) = []; % remove empty rows
save(results_file, 'results', 'emptry_row')

best_mean_results = results((results.MAE_mean == min(results.MAE_mean)),:)

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

%% Plot results

% figure
% semilogy(results.q, results.MAE_mean, '.')
% grid on
% ylabel('MAE of prediction');
% xlabel('Number of delays in model, q');
% y_limits = [1e-2, 1e-1];
% ylim(y_limits)
% title(['DMD, best q = ', num2str(best_mean_results.q)])

%%
figure
subplot(1,3,1)
semilogy(results.N_train, results.MAE_mean, '.')
grid on
ylabel('MAE_mean');
xlabel('N_train');
y_limits = [1e-2, 1e-1];
ylim(y_limits)
title(['DMD, best q = ', num2str(best_mean_results.q)])

subplot(1,3,2)
semilogy(results.N_train, results.MAE_1, '.')
grid on
ylabel('MAE 1');
xlabel('N_train');
y_limits = [1e-2, 1e-1];
ylim(y_limits)
title(['DMD, best q = ', num2str(best_mean_results.q)])

subplot(1,3,3)
semilogy(results.N_train, results.MAE_2, '.')
grid on
ylabel('MAE 2');
xlabel('N_train');
y_limits = [1e-2, 1e-1];
ylim(y_limits)
title(['DMD, best q = ', num2str(best_mean_results.q)])
