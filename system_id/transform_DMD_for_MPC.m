%% Chnage format of DMDc model for use in MPC

sim_type = 'Simulink'
reload_data = 0
choose_model = 0

use_angular_rate = 0;
use_MAE_diff = 0;
plot_predictions = 1;

extract_data

if choose_model
    start_folder = [pwd, '/system_id/Simulink/*.mat'];
    [model_file_name, model_parent_dir] = uigetfile(start_folder, '[init_mpc.m] Choose MODEL .mat file to use for mpc')
    model_file = (strcat(model_parent_dir, '/', model_file_name));
    load(model_file) % Load plant model from saved data
end

algorithm = 'havok'

A_d = B_dmd(:, 1:(q-1)*ny); % Delay state matrix as per thesis discription

A_top    = [A_dmd, A_d]; % First ny rows of state matrix for MPC
A_bottom = [eye( (q-1)*ny ), zeros( (q-1)*ny, ny )]; % Bottom rows of matrix to propogate delay coordinates to new position
A = [A_top; A_bottom];

B = [ B_dmd(:, ((q-1)*ny+1):end); zeros((q-1)*ny, nu)];

run_model