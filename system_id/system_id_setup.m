% Choose script to run param sweep
algorithm = 'havok'; % 'dmd' or 'havok'
% algorithm = 'havok';

reload_data = 1; % Re-choose csv data file for SITL data
plot_results = 1;
use_anglular_rate = 1;
use_sitl_data = 1;

Ts = 0.03; % Desired sample time

% Extract data
extract_data;

% close all;
total_timer = tic; % Start timer for this script

% Search space
T_train_min = 10; % [s] Min value of training period in grid search
T_train_max = 250; % Max value of training period in grid search
T_train_increment = 10; % Increment value of training period in grid search

q_min = 5; % Min value of q in grid search
q_max = 30; % Max value of q in grid search
q_increment = 2; % Increment value of q in grid search

p_min = 10; % Min value of p in grid search
p_max = q_max*4; % Max value of p in grid search
p_increment = 1; % Increment value of p in grid search

T_train_search = T_train_max:-T_train_increment:T_train_min; % Start at max go to min
N_train_search = floor(T_train_search./Ts); % Convert time period to number of data samples
q_search = q_min:q_increment:q_max; % List of q parameters to search in

% Variables for running model prediction tests
run.number = 10; % Number of runs done for test data
run.window = 10; % [s] Prediction time window/period used per run  
run.N = floor(run.window/Ts); % number of data samples in prediction window
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
results_file = [uav_folder, '/results/', algorithm, '_results_', simulation_data_file, '.mat'];
try
    load(results_file);
    results(~results.q,:) = []; % remove empty rows
    results = [results; table('Size',Size,'VariableTypes',VariableTypes,'VariableNames',VariableNames)];
    
catch
    disp('No saved results file')  
    
    results = table('Size',Size,'VariableTypes',VariableTypes,'VariableNames',VariableNames);
    emptry_row = 1; % Keep track of next empty row to insert results 
end

% String for saved model filename
if use_angular_rate
    payload_angle_str = '_anglular_rate'
else
    payload_angle_str = '_angle';
end

% Run parameter sweep script:
param_sweep        

