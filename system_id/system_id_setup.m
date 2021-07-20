
reload_data = 0; % Re-choose csv data file for SITL data
plot_results = 1;

Ts = 0.03; % Desired sample time
Ts_dmd = Ts;

% Extract data
extract_data;

% close all;
total_timer = tic; % Start timer for this script

% Search space
T_train_min = 280; % [s] Min value of training period in grid search
T_train_max = 280; % Max value of training period in grid search
T_train_increment = 40; % Increment value of training period in grid search

q_min = 10; % Min value of q in grid search
q_max = 30; % Max value of q in grid search
q_increment = 1; % Increment value of q in grid search

p_min = 5; % Min value of p in grid search
p_max = q_max*4; % Max value of p in grid search
p_increment = 1; % Increment value of p in grid search

T_train_search = T_train_max:-T_train_increment:T_train_min; % Start at max go to min
N_train_search = floor(T_train_search./Ts); % Convert time period to number of data samples
q_search = q_min:q_increment:q_max; % List of q parameters to search in
% % p_search defined before p for loop

% Variables for running model prediction tests
run.number = 10; % Number of runs done for test data
run.window = 10; % [s] Prediction time window/period used per run  
run.N = floor(run.window/Ts); % number of data samples in prediction window
% Interval between start indexes to fit number of runs into test data
MAE_weight = [1; 1]./sqrt(max(abs(y_train),[],2)); % Weighting of error of each state when calculating mean
plot_predictions = 0; % Always set to 0 when looping DMD_run_model.m otherwiee opens many plots

% Run script:
DMD_Ntrain_sweep;
