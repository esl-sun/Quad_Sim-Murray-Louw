% Obtain setpoints
time_sp = [sim_time];

% Set all inputs to 0 as default
sim_time = time_sp(numel(time_sp));
sim_size = size(time_sp);

pitch_rate_input = timeseries(zeros(sim_size), time_sp);
roll_rate_input = timeseries(zeros(sim_size), time_sp);
yaw_rate_input = timeseries(zeros(sim_size), time_sp);

quat_input = timeseries(zeros(sim_size(1), 4), time_sp);
pitch_input = timeseries(zeros(sim_size), time_sp);
roll_input = timeseries(zeros(sim_size), time_sp);
yaw_input = timeseries(zeros(sim_size), time_sp);

vn_input = timeseries(zeros(sim_size), time_sp);
ve_input = timeseries(zeros(sim_size), time_sp);
vd_input = timeseries(zeros(sim_size), time_sp);

n_input = timeseries(zeros(sim_size), time_sp);
e_input = timeseries(zeros(sim_size), time_sp);
d_input = timeseries(zeros(sim_size), time_sp);

actuators_aileron = timeseries(act_aileron, time_act);
actuators_elevator = timeseries(act_elevator, time_act);
actuators_rudder = timeseries(act_rudder, time_act);

thr_out = timeseries(thr, time_thr);

% if (strcmp(input_type, 'roll') == 1 || strcmp(input_type, 'pitch') == 1 || strcmp(input_type, 'yaw') == 1) && is_step == true
%     quat_input = timeseries(q_sp, time_sp);
% end
%quat_input = timeseries(q_sp, time_sp); % hoe werk dit dan as daar nie 'n quat input is nie?????

% Set NANs to 0
%input_sp(find(isnan(input_sp))) = 0;

input_sp = timeseries(zeros(sim_size), time_sp);