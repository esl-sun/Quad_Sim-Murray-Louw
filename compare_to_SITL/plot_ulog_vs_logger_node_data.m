%% Logger data
message = 'Choose csv file with data from logger.py';
[file_name,parent_dir] = uigetfile('/home/esl/Masters/Developer/MATLAB/Quad_Sim_Murray/system_id/SITL/honeybee_payload/data/*.csv', message);
logger.data = readmatrix(strcat(parent_dir, '/', file_name));

logger.time = logger.data(:,1);
logger.pos_sp_x = logger.data(:,10);


%% Ulog data
message = 'Choose setpoint CSV file';
[file_name,parent_dir] = uigetfile('/home/esl/Masters/Developer/MATLAB/Quad_Sim_Murray/compare_to_SITL/*.csv', message);
ulog.data = readmatrix(strcat(parent_dir, '/', file_name));

ulog.time = ulog.data(:,1)*1e-6; % ulog in micro-seconds
ulog.pos_sp_x = ulog.data(:,2);

%% Plot
figure
plot(logger.time, logger.pos_sp_x)
hold on
grid on
plot(ulog.time, ulog.pos_sp_x)
hold off


