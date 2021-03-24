time = 0:1/sim_freq:sim_time;
zero = zeros(size(time));
one = ones(size(time));

time_rates_sp = time;
roll_rate_sp = zero;
pitch_rate_sp = zero;
yaw_rate_sp = zero;
 
time_att_sp = time;
q0 = one;
roll_sp = zero;
pitch_sp = zero;
yaw_sp = zero;
quat_sp = [one roll_sp pitch_sp yaw_sp];
 
time_att = time;
roll_rate = zero;
pitch_rate = zero;
yaw_rate = zero;
quat = [one zero zero zero];
roll = zero;
pitch = zero;
yaw = zero;
 
time_pos_sp = time;
vn_sp = zero;
ve_sp = zero;
vd_sp = zero;
n_sp = zero;
e_sp = zero;
d_sp = zero;
 
time_pos = time;
vn = zero;
ve = zero;
vd = zero;
north = zero;
east = zero;
down = zero;
 
time_act = time;
act_aileron = zero;
act_elevator = zero;
act_rudder = zero;

time_thr = time;
thr1 = zero;
thr2 = zero;
thr3 = zero;
thr4 = zero;
thr = [thr1' thr2' thr3' thr4'];