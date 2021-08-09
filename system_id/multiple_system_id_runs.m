use_sitl_data = 1;
reload_data = 1; % Re-choose csv data file for SITL data
plot_results = 1;
write_csv = 0; % Output results to csv for thesis
use_MAE_diff = 0; % Use MAE metric of diff of predicitons and signal

use_angular_rate = 0;
algorithm = 'havok'; % 'dmd' or 'havok'
system_id_setup;

% % Create csv file of results;
% if write_csv
%     MAE_vs_Ntrain;
% end
% 
% reload_data = 0; % Re-choose csv data file for SITL data
% 
% use_angular_rate = 1;
% algorithm = 'havok'; % 'dmd' or 'havok'
% system_id_setup;
% 
% % Create csv file of results;
% if write_csv
%     MAE_vs_Ntrain;
% end

% use_angular_rate = 0;
% algorithm = 'dmd'; % 'dmd' or 'havok'
% system_id_setup;
% MAE_vs_q

% use_angular_rate = 1;
% algorithm = 'havok'; % 'dmd' or 'havok'
% system_id_setup;
% 
% use_angular_rate = 1;
% algorithm = 'dmd'; % 'dmd' or 'havok'
% system_id_setup;

