
%% Run simulation
% disp('Start simulation.')
% tic;
% out = sim('quad_simulation_with_payload.slx')
% toc;
% disp('Simulation done.')

%% Save data
save_filename = [uav_folder, '/data/', simulation_data_file, '.mat']

% Check for overwriting file
if isfile(save_filename)
    fig = uifigure;
    selection = uiconfirm(fig, 'File exists. Do you want to overwrite it?', 'Overwrite existing data',...
                        'Icon','warning')
    if selection == 'OK'
        save(save_filename, 'out', 'mp', 'l')
        disp('Data overwrite saved')
    end
else
    save(save_filename, 'out')
    disp('Saved data')
end

        