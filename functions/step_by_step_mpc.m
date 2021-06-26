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
dtheta_data = out.dtheta.Data'; % payload angular velocity is an unmeasured state
mo_data   = out.mo.Data';
ov_data = [dtheta_data; mo_data]; % Output Variables [UO; MO]
mv_data   = out.mv.Data';
ref_data  = out.ref.Data';

t = out.mo.Time';
N = size(mo_data,2); % Number of data samples

ph = mpc_vel.PredictionHorizon; % Prediction Horizon
x_mpc = mpcstate(mpc_vel); % Current state of mpc
v = []; % No measured distrubances

y_rows = 1:4

%% Plot step for step

for k = 1:N % every timestep k
    k*Ts_mpc
    ym = mo_data(:, k);
    r = ref_data(:, k);
    [mv, info] = mpcmove(mpc_vel, x_mpc, ym, r, v);
    if mod(k, 0.1/Ts_mpc) == 0 && (k*Ts_mpc > 4.5)
        for state = y_rows
            figure(state)
            ylabel(state)
            plot(info.Topt + t(k), info.Yopt(:,state));
            hold on;
            plot(info.Topt + t(k), ref_data(state,(0:ph)+k)')
            plot(info.Topt + t(k), ov_data(state,(0:ph)+k)', ':', 'LineWidth', 2)
            legend('prediction', 'ref', 'actual')
            title(state)
            ylim([-2.5, 7])
            hold off;
        end
        
%         figure(2*state + 1)
%         plot(info.Topt + t(k), info.Uopt)
%         hold on;
%         plot(info.Topt + t(k), mv_data(:,(0:ph)+k)', ':', 'LineWidth', 2) % Actual input given
%         hold off;
%         legend('optimised', 'actual')
%         title('Input given')
        
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

