 % Simulated mpc predictions with for loop following simulation data
% Always run .slx simulation first
% Used to analyse prediction of mpc when designing

% Resample time series to mpc sample time
% x_resamp = resample(out.x_mpc, 0:Ts_mpc:(out.x_mpc.Time(end)) );  
% mo_resamp   = resample(out.mo,    0:Ts_mpc:(out.x_mpc.Time(end)) );  
% mv_resamp   = resample(out.mv,    0:Ts_mpc:(out.x_mpc.Time(end)) );  
% ref_resamp  = resample(out.ref,   0:Ts_mpc:(out.x_mpc.Time(end)) );  
% 
% % Extract data
% x_data = xmpc_resamp.Data';
% mo_data   = mo_resamp.Data';
% mv_data   = mv_resamp.Data';
% ref_data  = ref_resamp.Data';

% load('data/MPC_test_2.mat')

% Extract data
% dtheta_data = out.dtheta.Data'; % payload angular velocity is an unmeasured state
dtheta_data = out.angle_rate.Data';
mo_data   = out.mo.Data';
ov_data = [dtheta_data; mo_data]; % Output Variables [UO; MO]
mv_data   = out.mv.Data';
if enable_jerk_limited_mpc
    ref_data  = out.ref.Data; % 3D array
else
    ref_data  = out.ref.Data'; % 2D matrix
end
t = out.mo.Time';
N = size(mo_data,2); % Number of data samples

PH = mpc_vel.PredictionHorizon; % Prediction Horizon
x_mpc = mpcstate(mpc_vel); % Current state of mpc
v = []; % No measured distrubances

y_rows = 1:3

%% Plot step for step
start_pausing_time = 1.5; % Set time where it should start pausing and plotting. Press Enter to continue
pause_interval = 0.1; % Size of time gap between pauses

figure(1)

for k = 1:N % every timestep k
    k*Ts_mpc
    ym = mo_data(:, k);
    if enable_jerk_limited_mpc
        r = ref_data(:, :, k);
    else
        r = ref_data(:, k);
    end
    
    [mv, info] = mpcmove(mpc_vel, x_mpc, ym, r, v);
    if mod(k, pause_interval/Ts_mpc) == 0 && (k*Ts_mpc > start_pausing_time)
        figure(1)
        for state = y_rows
            subplot(4,1,state)
            plot(info.Topt + t(k), info.Yopt(:,state));
            hold on;
                if enable_jerk_limited_mpc
                    plot(info.Topt(2:end) + t(k), ref_data(:,state,k))
                else
                    plot(info.Topt + t(k), ref_data(state,(0:PH)+k)')
                end
            plot(info.Topt + t(k), ov_data(state,(0:PH)+k)', ':', 'LineWidth', 2)
            legend('prediction', 'ref', 'actual')
            hold off;
            
            switch state
                case 1
                    title('angle.E RATE')
                case 2
                    title('x velocity')
                case 3
                    title('angle.E')
            end
        end
        
        subplot(4,1,state + 1)
        plot(info.Topt + t(k), info.Uopt)
        hold on;
        plot(info.Topt + t(k), mv_data(:,(0:PH)+k)', ':', 'LineWidth', 2) % Actual input given
        hold off;
        legend('optimised', 'actual')
        title('Input given')
        
        %% plot position
        figure(2)
        state = 2; % position
        plot(info.Topt + t(k), info.Yopt(:,state));
        hold on;
            if enable_jerk_limited_mpc
                plot(info.Topt(2:end) + t(k), ref_data(:,state,k))
            else
                plot(info.Topt + t(k), ref_data(state,(0:PH)+k)')
            end
        plot(info.Topt + t(k), ov_data(state,(0:PH)+k)', ':', 'LineWidth', 2)
        legend('prediction', 'ref', 'actual')
        hold off;
        
        pause
        
    end
end

%% Plot
% close all
figure
plot(t, ref_data)
legend('fx', 'fy', 'fz')
title('ref-data')

figure
plot(out.y)
legend('dx', 'dy', 'dz', 'th', 'phi')
title('out.y')

figure
plot(out.u)
legend('fx', 'fy', 'fz')
title('out.u')

figure
plot(t, mv_data)
legend('fx', 'fy', 'fz')
title('mv-data')

figure
plot(t, mo_data)
% legend()
title('mo-data')

