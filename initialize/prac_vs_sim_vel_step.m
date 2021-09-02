%% Compare prac vel step to Simulink vel step

% First run prac_vel_step_to_csv.m

disp('Start simulation.')
out = sim('quad_simulation_with_payload.slx')
disp('Simulation done.')

%% Get simulink data
sim_matrix = out.vel.Data(:,1); % vel data from simulink
sim_step = timeseries(sim_matrix, out.vel.Time);

%% Plot data over each other
figure
plot(prac_step) % Plot practical step data
hold on
plot(sim_step) % Plot practical step data
plot(sim_step_prev, 'k-') % Plot practical step data
hold off
legend('prac', 'sp', 'simulink', 'previous sim')

%% Save previous sim_data
sim_step_prev = sim_step;