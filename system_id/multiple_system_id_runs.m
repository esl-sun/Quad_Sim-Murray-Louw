use_sitl_data = 1;
reload_data = 1; % Re-choose csv data file for SITL data
plot_results = 0;
write_csv = 1; % Output results to csv for thesis
use_MAE_diff = 0; % Use MAE metric of diff of predicitons and signal

use_angular_rate = 0;
algorithm = 'havok'; % 'dmd' or 'havok'
system_id_setup;

reload_data = 0; % Re-choose csv data file for SITL data

% use_angular_rate = 0;
% algorithm = 'dmd'; % 'dmd' or 'havok'
% system_id_setup;

% use_angular_rate = 1;
% algorithm = 'havok'; % 'dmd' or 'havok'
% system_id_setup;
% 
% use_angular_rate = 1;
% algorithm = 'dmd'; % 'dmd' or 'havok'
% system_id_setup;
