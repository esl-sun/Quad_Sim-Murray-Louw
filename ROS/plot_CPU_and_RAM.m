reload_data = 1
if reload_data
    [file_name,parent_dir] = uigetfile([getenv('HOME'), '/Masters/Developer/MATLAB/Quad_Sim_Murray/system_id/HITL/iris/data/system_logs/*.txt'], '[plot_CPU_and_RAM.m] Choose system log DATA file')
    data_path = strcat(parent_dir, file_name);
    data = readmatrix(data_path);
end

time = 0.02 * (1:size(data,1)); % Check .bshrc pidlog function for sample rate
cpu = data(:,1);
ram = data(:,2);

% Plot CPU
figure
plot(time, cpu)
title('%CPU')

% Plot RAM
figure
plot(time, ram)
title('%RAM')