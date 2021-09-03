%% Compare prac vel step to Simulink vel step

% First run prac_vel_step_to_csv.m

write_csv = 1;
chapter = 'modelling'

%% Run simulation
disp('Start simulation.')
out = sim('quad_simulation_with_payload.slx')
disp('Simulation done.')

%% Get simulink data
sim_matrix = out.vel.Data(:,1); % vel data from simulink
sim_step = timeseries(sim_matrix, out.vel.Time);
sim_step = resample(sim_step, prac_step.Time)

%% Plot data over each other
figure(1)
plot(prac_step) % Plot practical step data
hold on
plot(sim_step) % Plot practical step data
plot(sim_step_prev, 'k-') % Plot practical step data
hold off
legend('prac', 'sp', 'simulink', 'previous sim')

%% Save previous sim_data
sim_step_prev = sim_step;

%% Get data for CSV
selected_rows = 1:2:length(prac_step.Time); % Only save every second sample for tikz memory constraint

csv_matrix = [prac_step.Time, prac_step.Data, sim_step.Data(:,1)]; % Only vel and vel_sp data
csv_matrix = csv_matrix(selected_rows, :); % resample to make csv and tikz plot smaller

%% write to csv
if write_csv
  
    csv_filename = [getenv('HOME'), '/Masters/Thesis/', chapter, '/csv/', 'prac_vs_sim_vel_step_', sim_type, '_', file_name, '.csv'];
    csv_filename

    VariableTypes = {'double',  'double',   'double',    'double'};
    VariableNames = {'time',    'vel_sp',   'vel.prac',  'vel.sim'};
    csv_table = table('Size',size(csv_matrix),'VariableTypes',VariableTypes,'VariableNames',VariableNames);
    csv_table(:,:) = array2table(csv_matrix);

    writetable(csv_table,csv_filename)
end
