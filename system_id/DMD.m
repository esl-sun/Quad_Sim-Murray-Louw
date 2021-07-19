%% Implentation of DMD
% close all;

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
        q = 20;
        q_results = results((results.q == q & results.Ts == Ts),:);
        best_row = find(q_results.MAE_mean == min(q_results.MAE_mean));
        best_results = q_results(best_row,:)
        p = double(best_results.p);
    end
    
    override = 0;
    if override
        '!!!!!Override!!!!!!!'
        q
        p=q*4
        
    end
   
    q
    p

    
catch
    disp('No saved results file')  
end


w = N_train - q + 1; % num columns of Hankel matrix
D = (q-1)*Ts; % Delay duration (Dynamics in delay embedding)

% Hankel matrix with delay measurements
if q == 1 % Special case if no delay coordinates
    Xd = [];
    Upsilon = u_train(:, q:end);
else
    Xd = zeros((q-1)*ny,w); % Delay state matrix with X[k] at top
    for row = 0:q-2 % Add delay coordinates
        Xd((end - ny*(row+1) + 1):(end - ny*row), :) = y_train(:, row + (1:w));
    end

%     Upsilon = [Xd(:, 1:end-1); u_train(:, q:end-1)]; % Leave out last time step to match V_til_1
    Xd = Xd(:, 1:end-1); % Leave out last time step to match Y1
    Upsilon = u_train(:, q:end-1); % Leave out last time step to match Y1
end

% Matrix with time series of states
Y = y_train(:, q-1 + (1:w));

% DMD of Y
Y2 = Y(:, 2:end  );
Y1 = Y(:, 1:end-1);

Omega = [Y1; Xd; Upsilon]; % Combined matrix of Y above and U below

% SVD of the Hankel matrix
[U1,S1,V1] = svd(Omega, 'econ');

% Truncate SVD matrixes
U_tilde = U1(:, 1:p); 
S_tilde = S1(1:p, 1:p);
V_tilde = V1(:, 1:p);

% YU = \approx U_tilde*S_tilde*V_tilde'
AB = Y2*pinv(U_tilde*S_tilde*V_tilde'); % combined A and B matrix, side by side
% AB = Y2*pinv(YU); % combined A and B matrix, side by side

% System matrixes from DMD
A_dmd  = AB(:,1:ny); % Extract A matrix
B_dmd  = AB(:,(ny+1):end);
% A_dmd = stabilise(A_dmd,1);

% Initial condition
y_hat_0 = y_test(:,q);

% Initial delay coordinates
y_delays = zeros((q-1)*ny,1);
k = q; % index of y_data
for i = 1:ny:ny*(q-1) % index of y_delays
    k = k - 1; % previos index of y_data
    y_delays(i:(i+ny-1)) = y_test(:,k);
end

% Run model
y_hat = zeros(ny,N_test); % Empty estimated Y
y_hat(:,1) = y_hat_0; % Initial condition
for k = 1:N_test-1
    upsilon = [y_delays; u_test(:,k)]; % Concat delays and control for use with B
    y_hat(:,k+1) = A_dmd*y_hat(:,k) + B_dmd*upsilon;
    if q ~= 1
        y_delays = [y_hat(:,k); y_delays(1:(end-ny),:)]; % Add y(k) to y_delay for next step [y(k); y(k-1); ...]
    end
end

% Vector of Mean Absolute Error on testing data
MAE = sum(abs(y_hat - y_test), 2)./N_test % For each measured state

%% Plot training data
% close all;

figure;
plot(t_train, y_train);
title(['DMD - Train y - ', simulation_data_file]);

figure;
plot(t_train, u_train);
title(['DMD - Train u - ', simulation_data_file]);
legend('x', 'y', 'z')

%% Plot preditions
for i = 1:ny
    figure;
    plot(t_test, y_test(i,:), 'b');
    hold on;
    plot(t_test, y_hat(i,:), 'r--', 'LineWidth', 1);
    hold off;
    legend('actual', 'predicted')
    title(['DMD - Test y', num2str(i), ' - ', simulation_data_file]);
end

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