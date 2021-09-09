% Choose script to run param sweep
% use_sitl_data = 1;
% reload_data = 1; % Re-choose csv data file for SITL data
% plot_results = 0;
% write_csv = 1; % Output results to csv for thesis
% use_MAE_diff = 0; % Use MAE metric of diff of predicitons and signal
% 
% use_angular_rate = 0;
% algorithm = 'havok'; % 'dmd' or 'havok'

Ts = 0.03; % Desired sample time

% Extract data
extract_data;

% close all;
total_timer = tic; % Start timer for this script

% Search space
T_train_min = 80; % [s] Min value of training period in grid search
T_train_max = 80; % Max value of training period in grid search
T_train_increment = 5; % Increment value of training period in grid search

q_min = 50; % Min value of q in grid search
q_max = 70; % Max value of q in grid search
q_increment = 5; % Increment value of q in grid search

p_min = 2; % Min value of p in grid search
p_max = q_max; % Max value of p in grid search
p_increment = 1; % Increment value of p in grid search

T_train_search = T_train_max:-T_train_increment:T_train_min; % Start at max go to min
N_train_search = floor(T_train_search./Ts); % Convert time period to number of data samples
q_search = q_min:q_increment:q_max; % List of q parameters to search in

% Variables for running model prediction tests
run.number = 10; % Number of runs done for test data
run.window = 20; % [s] Prediction time window/period used per run  
run.N = floor(run.window/Ts); % number of data samples in prediction window
MAE_weight      = 1./(max(y_train,[],2) - min(y_train,[],2)); % Weighting of error of each state when calculating mean
MAE_diff_weight = 1./(max(diff(y_train,1,2),[],2) - min(diff(y_train,1,2),[],2)); % Weighting of error of derivative each state when calculating mean
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

% Run parameter sweep script:
param_sweep;

