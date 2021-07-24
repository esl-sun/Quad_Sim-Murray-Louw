%% Implentation of Hankel Alternative View Of Koopman for 2D Drone
% Always run HAVOK_param_swep.m first before running this file.
% This will set all varaibkles correctly
% close all;

% Extract data
reload_data = 0; % Re-choose csv data file for SITL data
save_model = 0; % 1 = Save this model , 0 = dont save
extract_data;

try
    load(results_file);
    results(~results.q,:) = []; % remove empty rows
    
    % Parameters
    best_row = find(results.MAE_mean == min(results.MAE_mean));
    best_results = results(best_row,:)
    q = double(best_results.q);
    p = double(best_results.p);
    N_train = double(best_results.N_train);
    
    iterate_p = 0;
    if iterate_p
        'Iterate p -------------------------------------------------------'
        p = try_p;
    end
    
    only_q_Ts = 0; % Try best result for specific q
    if only_q_Ts
        'Chosen q --------------------------------------------------------'
        q = 20;
        q_results = results((results.q == q & results.Ts == Ts),:);
        best_row = find(q_results.MAE_mean == min(q_results.MAE_mean));
        best_results = q_results(best_row,:)
        p = double(best_results.p);
    end
    
    override = 0;
    if override
        'Override --------------------------------------------------------'
        q = 23
        p = 30
        N_train = 130
        
    end
    % % Override parameters:
    % q = 80
    % p = 40
   
    q
    p
    N_train
    
    % Starting a max value, cut data to correct length
    y_train = y_train(:, 1:N_train);
    u_train = u_train(:, 1:N_train);
    
catch
    disp('No saved results file')  
end

HAVOK_part_1

figure(1), semilogy(diag(S1), 'x'), hold on;
title('Singular values of Omega, showing p truncation')
plot(p, S1(p,p), 'ro'), hold off;

HAVOK_part_2

A_havok = A;
B_havok = B;

plot_predictions = 1;
run_model;
MAE

%% Add payload angular velocity for MPC tracking position
% A_havok = [zeros( num_axis, size(A_havok,2) ); A_havok]; % Add top row zeros
% A_havok = [zeros( size(A_havok,1), num_axis ), A_havok]; % Add left column zeros
% B_havok = [zeros( num_axis, size(B_havok,2) ); B_havok]; % Add top row zeros
% 
% % Numeric differentiation: dtheta(k+1) approx.= dtheta(k) = 1/Ts*theta(k) - 1/Ts*theta(k-1)
% A_havok(1, 3) =  1/Ts*eye(num_axis); % 1/Ts*theta(k)
% A_havok(1, 5) = -1/Ts*eye(num_axis); % - 1/Ts*theta(k-1)

%% Save model
if save_model
    model_file = [uav_folder, '/models/havok_model_', simulation_data_file, '_q', num2str(q), '_p', num2str(p), payload_angle_str, '.mat'];
    save(model_file, 'A_havok', 'B_havok', 'Ts_havok', 'q', 'p', 'ny', 'nu', 'u_bar')
    disp('model saved')
end
%% Run with HAVOK (A_havok, B_havok and x)
% figure;
% for i = 1:q*p-1
%     plot(V1(:,i))
%     pause
% end
% 
% title('First 5 modes of SVD')

%% Compare to testing data
% Initial condition (starts at index = q of training data)
y_hat_0 = zeros(q*ny,1); % Y[k] at top
for row = 0:q-1 % First column of spaced Hankel matrix
    y_hat_0(row*ny+1:(row+1)*ny, 1) = y_test(:,q-row);
end

% Add initial angular velocity to top
switch num_axis
    case 1 % y_test = [vx; angle_x ... delays]
        dtheta_0 = 1/Ts * y_test(2, q)  -  1/Ts * y_test(2, q-1); % initial angular velocity
    case 2 % y_test = [vx; vy; angle_x; angle_y... delays]
        dtheta_0 = 1/Ts * y_test([3 4], q)  -  1/Ts * y_test([3 4], q-1); % initial angular velocity
end
y_hat_0 = [dtheta_0; y_hat_0];

% Run model
% figure
Y_hat = zeros(length(y_hat_0),N_test); % Empty estimated Y
Y_hat(:,q) = y_hat_0; % Initial condition
for k = q:N_test-1
    Y_hat(:,k+1) = A_havok*Y_hat(:,k) + B_havok*u_test(:,k);
%     plot(t_test, Y_hat(1:(ny+num_axis), :))
%     legend('pos', 'vel', 'theta')
%     pause
end

y_hat_bar = Y_hat(1:(ny+num_axis), :); % Extract only non-delay time series and position

% Vector of Mean Absolute Error on testing data
switch num_axis
    case 1
        MAE = sum(abs(y_hat_bar(2:end,:) - y_test), 2)./N_test % For each measured state
    case 2
        MAE = sum(abs(y_hat_bar(5:end,:) - y_test), 2)./N_test % For each measured state
end

%% Plot training data
% close all;
% 
% figure;
% plot(t_train, y_train);
% title(['HAVOK - Train y - ', simulation_data_file]);
% 
% figure;
% plot(t_train, u_train);
% title(['HAVOK - Train u - ', simulation_data_file]);
% legend('x', 'y', 'z')


%% Plot preditions
for i = 1:ny
    figure;
    plot(t_test, y_test(i,:), 'b');
    hold on;
    plot(t_test, y_hat_bar(i+num_axis,:), 'r--', 'LineWidth', 1);
    plot(t_test, u_test, 'k');
    hold off;
    legend('actual', 'predicted', 'input')
    title(['HAVOK - Test y', num2str(i), ' - ', simulation_data_file]);
end

%% Plot angle and angular velocity
% figure, hold on
% plot(t_test, y_test(2,:))
% plot(t_test, y_hat_bar(1,:))
% legend('angle_x', 'angle_x velocity')
% title('angle and angular velocity')
% hold off
