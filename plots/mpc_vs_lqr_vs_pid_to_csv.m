%% Compare vel step. MPC vs LQR vs PID vs PID no_load (Simulink) 

% First run extract_data.m to get file_name for reference to training data 

run_sim = 0;
write_csv = 1;
chapter = 'control'
added_comment = '_enter_at_6';
% added_comment = ['_intg_weight_', num2str(integrator_weight)];
 
%% Run simulation
if run_sim
    disp('Start simulation.')
    out = sim('quad_simulation_with_payload.slx')
    disp('Simulation done.')
end

%% Get simulink data
theta_deg = out.theta.Data * 180/pi; % Convert theta data from radians to degrees


%% Get data for CSV
selected_rows = 1:2:length(out.vel.Time); % Only save every second sample for tikz memory constraint

csv_matrix = [ ...
    out.vel.Time, ...
    out.vel_sp.Data(:,1), ...
    out.vel.Data(:,1), ...
    theta_deg, ...
    out.acc_sp_mpc.Data(:,1), ...
    out.acc.Data(:,1)    ]; % Data to write to csv

VariableNames = {'time',    'vel_sp',   'vel',      'theta',    'acc_sp',   'acc'};
VariableTypes = {'double',  'double',   'double',   'double',   'double',   'double'};

csv_matrix = csv_matrix(selected_rows, :); % resample to make csv and tikz plot smaller

%% write to csv
if write_csv
  
    csv_filename = [getenv('HOME'), '/Masters/Thesis/', chapter, '/csv/',...
                    'compare_control_', control_type, '_', sim_type, '_', simulation_data_file, added_comment, '.csv'];
    csv_filename

    csv_table = table('Size',size(csv_matrix),'VariableTypes',VariableTypes,'VariableNames',VariableNames);
    csv_table(:,:) = array2table(csv_matrix);

    writetable(csv_table,csv_filename)
end
