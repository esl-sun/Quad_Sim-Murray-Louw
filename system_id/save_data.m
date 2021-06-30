
save_filename = [uav_folder, '/data/', simulation_data_file, '.mat']
% save_filename = [uav_folder, '/data/', 'PID_x_payload_mp0.2_l0.5_added_pos_sp', '.mat']

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

        