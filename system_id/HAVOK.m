%% Implentation of Hankel Alternative View Of Koopman for 2D Drone
% Always run HAVOK_param_swep.m first before running this file.
% This will set all varaibkles correctly
close all;
% %% Run simulation
% tic;
% disp('Start simulation.')
% sim 'quad_simulation_with_payload.slx'
% disp('Execution time:')
% toc

results_file = ['system_id/',uav_name, '/results/havok_results_', simulation_data_file, comment, '.mat'];

try
    load(results_file);
    results(~results.q,:) = []; % remove empty rows
    
    % Parameters
    best_row = find(results.MAE_mean == min(results.MAE_mean));
    best_results = results(best_row,:);
    q = double(best_results.q);
    p = double(best_results.p);
    
    only_q_Ts = 0; % Try best result for specific q
    if only_q_Ts
        '---------------------------------------------- Chosen q --------------------------------------------------------'
        q = 13;
        q_results = results((results.q == q & results.Ts == Ts),:);
        best_row = find(q_results.MAE_mean == min(q_results.MAE_mean));
        best_results = q_results(best_row,:)
        p = double(best_results.p);
    end
    
    override = 0;
    if override
        '---------------------------------------------- Override --------------------------------------------------------'
        q = 30
        p = 14
        
    end
    % % Override parameters:
    % q = 80
    % p = 40
   
    q
    p
    
catch
    disp('No saved results file')  
end

w = N_train - q + 1; % num columns of Hankel matrix
D = (q-1)*Ts; % Delay duration (Dynamics in delay embedding)

% Create Hankel matrix with measurements
Y = zeros((q)*ny,w); % Augmented state Y[k] at top
for row = 0:q-1 % Add delay coordinates
    Y((end - ny*(row+1) + 1):(end - ny*row), :) = y_train(:, row + (1:w));
end

Upsilon = u_train(:, q:end); % Leave out last time step to match V_til_1
YU_bar = [Y; Upsilon];

% SVD of the Hankel matrix
[U1,S1,V1] = svd(YU_bar, 'econ');
figure, semilogy(diag(S1), 'x'), hold on;
title('Singular values of Omega, showing p truncation')
plot(p, S1(p,p), 'ro'), hold off;

% Truncate SVD matrixes
U_tilde = U1(:, 1:p); 
S_tilde = S1(1:p, 1:p);
V_tilde = V1(:, 1:p);

% Setup V2 one timestep into future from V1
V_til_2 = V_tilde(2:end  , :)'; % Turnd on side (wide short matrix)
V_til_1 = V_tilde(1:end-1, :)';

% DMD on V
AB_tilde = V_til_2*pinv(V_til_1); % combined A and B matrix, side by side
AB_tilde = stabilise(AB_tilde,3);

% Convert to x coordinates
AB_havok = (U_tilde*S_tilde)*AB_tilde*pinv(U_tilde*S_tilde);

% System matrixes from HAVOK
A_havok = AB_havok(1:q*ny, 1:q*ny);
B_havok = AB_havok(1:q*ny, q*ny+1:end);
% A_havok = stabilise(A_havok,10);

% Make matrix sparse
A_havok(ny+1:end, :) = [eye((q-1)*ny), zeros((q-1)*ny, ny)]; % Add Identity matrix to carry delays over to x(k+1)
B_havok(ny+1:end, :) = zeros((q-1)*ny, nu); % Input has no effect on delays

%% Run with HAVOK (A_havok, B_havok and x)
figure;
plot(V1(:,1:5))
title('First 5 modes of SVD')

%% Compare to testing data
% Initial condition (last entries of training data)
y_hat_0 = zeros(q*ny,1); % Y[k] at top
for row = 0:q-1 % First column of spaced Hankel matrix
    y_hat_0(row*ny+1:(row+1)*ny, 1) = y_test(:,q-row);
end

% Run model
Y_hat = zeros(length(y_hat_0),N_test); % Empty estimated Y
Y_hat(:,q) = y_hat_0; % Initial condition
for k = q:N_test-1
    Y_hat(:,k+1) = A_havok*Y_hat(:,k) + B_havok*u_test(:,k);
end

y_hat_bar = Y_hat(1:ny, :); % Extract only non-delay time series

% Vector of Mean Absolute Error on testing data
MAE = sum(abs(y_hat_bar - y_test), 2)./N_test % For each measured state

%% Plot training data
% close all;

figure;
plot(t_train, y_train);
title(['HAVOK - Train y - ', simulation_data_file]);

figure;
plot(t_train, u_train);
title(['HAVOK - Train u - ', simulation_data_file]);
legend('x', 'y', 'z')

%% Plot preditions
for i = 1:ny
    figure;
    plot(t_test, y_test(i,:), 'b');
    hold on;
    plot(t_test, y_hat_bar(i,:), 'r--', 'LineWidth', 1);
    hold off;
    legend('actual', 'predicted')
    title(['HAVOK - Test y', num2str(i), ' - ', simulation_data_file]);
end

%% Save model
model_file = ['system_id/', uav_name, '/models/havok_model_', simulation_data_file, '_q', num2str(q), '_p', num2str(p), '.mat'];
save(model_file, 'A_havok', 'B_havok', 'Ts_havok', 'q', 'p', 'ny', 'nu')
disp('model saved')

function A = stabilise(A_unstable,max_iterations)
    % If some eigenvalues are unstable due to machine tolerance,
    % Scale them to be stable
    A = A_unstable;
    count = 0;
    while (sum(abs(eig(A)) > 1) ~= 0)       
        [Ve,De] = eig(A);
        unstable = abs(De)>1; % indexes of unstable eigenvalues
        De(unstable) = De(unstable)./abs(De(unstable)) - 10^(-14 + count*2); % Normalize all unstable eigenvalues (set abs(eig) = 1)
        A = Ve*De/(Ve); % New A with margininally stable eigenvalues
        A = real(A);
        count = count+1;
        if(count > max_iterations)
            break
        end
    end

end