simulation_data_file = ['PID_X_payload', '_mp', num2str(mp), '_l', num2str(l)];
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

        