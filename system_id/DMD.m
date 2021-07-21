%% Implentation of DMD
% close all;

% Extract data
reload_data = 0; % Re-choose csv data file for SITL data
save_model = 0; % 1 = Save this model , 0 = dont save
extract_data;
plot_predictions = 0;

try
    load(results_file);
    results(~results.q,:) = []; % remove empty rows
    
    % Parameters
    best_row = find(results.MAE_mean == min(results.MAE_mean));
    best_results = results(best_row,:);
    q = double(best_results.q);
    p = double(best_results.p);
    N_train = double(best_results.N_train);
    
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
    N_train
    
    % Starting a max value, cut data to correct length
    y_train = y_train(:, 1:N_train);
    u_train = u_train(:, 1:N_train);
    
catch
    disp('No saved results file')  
end

DMD_part_1;
DMD_part_2;

run_model;

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
if plot_predictions
    for i = 1:ny
        figure;
        plot(t_test, y_test(i,:), 'b');
        hold on;
        plot(t_test, y_hat(i,:), 'r--', 'LineWidth', 1);
        hold off;
        legend('actual', 'predicted')
        title(['DMD - Test y', num2str(i), ' - ', simulation_data_file]);
    end
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