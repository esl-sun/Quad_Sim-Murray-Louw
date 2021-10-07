%% Implentation of DMD
% close all;

% Extract data
reload_data = 0; % Re-choose csv data file for SITL data
save_model = 1; % 1 = Save this model , 0 = dont save
extract_data;
plot_predictions = 0;

plot_index = 737; % start index to save to csv. 0 to not write anything to csv

custom_test_data = 0 % Choose custom range of test data
if custom_test_data
    test_time = 27:Ts:65;
    y_test = resample(y_data, test_time );  
    u_test = resample(u_data, test_time );  
    t_test = y_test.Time';
    if strcmp(sim_type, 'SITL')
        dtheta_test = resample(dtheta_data, test_time );
        dtheta_test = dtheta_test.Data';
    end
    N_test = length(t_test); % Num of data samples for testing

    y_test = y_test.Data';
    u_test = u_test.Data';
end

try
    load(results_file);
    results(~results.q,:) = []; % remove empty rows
    
    % Parameters
    best_row = find(results.MAE_1 == min(results.MAE_1));
    best_results = results(best_row,:);
    q = double(best_results.q);
    p = double(best_results.p);
    N_train = double(best_results.N_train);
    
    only_q_Ts = 1; % Try best result for specific q
    if only_q_Ts
        q = 50;
        q_results = results((results.q == q & results.Ts == Ts),:);
        best_row = find(q_results.MAE_mean == min(q_results.MAE_mean));
        best_results = q_results(best_row,:)
        p = double(best_results.p);
    end
    
    override = 0;
    if override
        '!!!!!Override!!!!!!!'
        q = 50
        p = 50
%         N_train = round(50/Ts)
        
    end
   
    q
    p
    N_train
    
    % Starting a max value, cut data to correct length
    y_train = y_train(:, 1:N_train);
    u_train = u_train(:, 1:N_train);
    
catch
    disp('No saved results file')  
end

DMD_part_1;
DMD_part_2;

figure, semilogy(diag(S1), 'x'), hold on;
title('Singular values of Omega, showing p truncation')
plot(p, S1(p,p), 'ro'), hold off;

run_model;
MAE

figure
semilogy(diag(S1), 'x'), hold on;
title('Singular values of Omega, showing p truncation')
plot(p, S1(p,p), 'ro'), hold off;

%% Save model
if save_model
    model_file = [uav_folder, '/models/dmd_model_', simulation_data_file, '_q', num2str(q), '_p', num2str(p), '_Ts', num2str(Ts), payload_angle_str, latency_str, '.mat'];
    save(model_file, 'A_dmd', 'B_dmd', 'Ts', 'q', 'p', 'ny', 'nu', 'u_bar')
    disp('model saved')
end

%% Plot training data
% close all;

% figure;
% plot(t_train, y_train);
% title(['DMD - Train y - ', simulation_data_file]);
% 
% figure;
% plot(t_train, u_train);
% title(['DMD - Train u - ', simulation_data_file]);
% legend('x', 'y', 'z')

%% Plot preditions
% if plot_predictions
%     for i = 1:ny
%         figure;
%         plot(t_test, y_test(i,:), 'b');
%         hold on;
%         plot(t_test, y_hat(i,:), 'r--', 'LineWidth', 1);
%         hold off;
%         legend('actual', 'predicted')
%         title(['DMD - Test y', num2str(i), ' - ', simulation_data_file]);
%     end
% end

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