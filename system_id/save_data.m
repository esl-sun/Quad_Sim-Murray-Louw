simulation_data_file = 'PID_XYZ_smoothed_no_noise_1_no_payload';
save_filename = ['system_id/', uav_name, '/data/', simulation_data_file, '.mat']

% Check for overwriting file
if isfile(save_filename)
    fig = uifigure;
    selection = uiconfirm(fig, 'File exists. Do you want to overwrite it?', 'Overwrite existing data',...
                        'Icon','warning')
    if selection == 'OK'
        save(save_filename, 'out')
        disp('Data overwrite saved')
    end
else
    save(save_filename, 'out')
    disp('Saved data')
end

        