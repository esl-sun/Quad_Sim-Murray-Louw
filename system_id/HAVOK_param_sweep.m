%% Implentation of Hankel Alternative View Of Koopman for 3D Quad_Sim
% Grid search of parameters
% Saves all the results for different parameter combinations

reload_data = 1; % Re-choose csv data file for SITL data
plot_results = 1;

Ts = 0.03; % Desired sample time
Ts_havok = Ts;

% close all;
total_timer = tic; % Start timer for this script

% Search space
q_min = 2; % Min value of q in grid search
q_max = 30; % Max value of q in grid search
q_increment = 1; % Increment value of q in grid search

p_min = 2; % Min value of p in grid search
p_max = q_max*4; % Max value of p in grid search
p_increment = 1; % Increment value of p in grid search

q_search = q_min:q_increment:q_max; % List of q parameters to search in
% p_search defined before p for loop

% Extract data
extract_data;

% Data dimentions
ny = size(y_train,1); % number of states
nu = size(u_train,1); % number of inputs  

% Weighting of error of each state when calculating mean
switch control_vel_axis
    case 'x' % [dx angle_y]
        MAE_weight = [1; 0]; % Pendulum states are not controlled, therefore not important for tracking
    case 'xy' % [dx, dy, angle_x, angle_y]
        MAE_weight = [1; 1;  0; 0];
end
MAE_weight = MAE_weight./sum(MAE_weight);

% Create empty results table
VariableTypes = {'double', 'int16',   'int16', 'int16', 'double'}; % id, q, p, MAE
VariableNames = {'Ts',     'N_train', 'q',     'p',     'MAE_mean'};
for i = 1:ny % Mae column for each measured state
    VariableNames = [VariableNames, strcat('MAE_', num2str(i))];
    VariableTypes = [VariableTypes, 'double'];
end
Size = [length(q_search)*length(p_min:p_increment:p_max), length(VariableTypes)];

% Read previous results
results_file = [uav_folder, '/results/havok_results_', simulation_data_file, '.mat'];
try
    load(results_file)
    results(~results.q,:) = []; % remove empty rows
    results = [results; table('Size',Size,'VariableTypes',VariableTypes,'VariableNames',VariableNames)];
    
catch
    disp('No saved results file')  
    
    results = table('Size',Size,'VariableTypes',VariableTypes,'VariableNames',VariableNames);
    emptry_row = 1; % Keep track of next empty row to insert results 
end

% Grid search
format compact % display more compact
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
            
                HAVOK_part_1

            end
            
            HAVOK_part_2
            
            % Compare to testing data
            % Initial condition (last entries of training data)
            y_hat_0 = zeros(q*ny,1); % Y[k] at top
            for row = 0:q-1 % First column of spaced Hankel matrix
                y_hat_0(row*ny+1:(row+1)*ny, 1) = y_test(:,q-row);
            end

            % Run model
            Y_hat = zeros(length(y_hat_0),N_test); % Empty estimated Y
            Y_hat(:,q) = y_hat_0; % Initial condition
            for k = q:N_test-1
                Y_hat(:,k+1) = A*Y_hat(:,k) + B*u_test(:,k);
            end

            y_hat = Y_hat(1:ny, :); % Extract only non-delay time series

            % Vector of Mean Absolute Error on testing data
            MAE = sum(abs(y_hat - y_test), 2)./N_test; % For each measured state
            
            % Save results
            results(emptry_row,:) = [{Ts, N_train, q, p, sum(MAE.*MAE_weight)}, num2cell(MAE')]; % add to table of results
            emptry_row = emptry_row + 1; 
            
        end % p
        
        save(results_file, 'results', 'emptry_row')
        toc;
end % q
format short % back to default/short display

% Save results
results(~results.q,:) = []; % remove empty rows
save(results_file, 'results', 'emptry_row')

best_results_overall = results((results.MAE_mean == min(results.MAE_mean)),:)

% % Only for this Ts:
% results_Ts = results((results.Ts == Ts),:);
% best_results_Ts = results_Ts((results_Ts.MAE_mean == min(results_Ts.MAE_mean)),:)
% 
% total_time = toc(total_timer); % Display total time taken
% 
% % For one q:
% results_q = results((results.q == 5),:);
% figure
% semilogy(results_q.p, results_q.MAE_1, 'r.')
% hold on
% semilogy(results_q.p, results_q.MAE_mean, 'k.')
% hold off

%% Plot results
if plot_results
    figure
    semilogy(results.q, results.MAE_mean, '.')
    grid on
    ylabel('MAE of prediction');
    xlabel('Number of delays in model, q');
    y_limits = [1e-2, 1e0];
    ylim(y_limits)
%     xlim([18 50])
    title(['HAVOK, best q = ', num2str(best_results_overall.q)])
end


