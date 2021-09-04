%% Parameter sweep of DMD or HAVOK
% Grid search of parameters, N_train, q, and p
% Saves all the results for different parameter combinations

% Grid search
format compact % display more compact
for N_train = N_train_search
    disp('-------------------------------')
    N_train*Ts
    
    % Starting at max value, cut data to correct length
    y_train = y_train(:, 1:N_train);
    u_train = u_train(:, 1:N_train);
    t_train = t_train(:, 1:N_train);
    
    for q = q_search
            if (N_train*Ts) < 5 && q > 75 % Does not work with larger q for this low data
                break
            end
            
            q_is_new = 1; % 1 = first time using this q this session
            q
            tic;

            p_max_new = min([p_max, q*ny]); % Max p to avoid out of bounds 
            if strcmp(sim_type, 'Prac')
                p_max_new = q; % Seen that for vel.x and angle.y, best p is always below q
            end
            p_search = p_min:p_increment:p_max_new; % List of p to search, for every q
            for p = p_search
                p_is_new = 1; % 1 = first time using this p this session

                if ~isempty(find(results.q == q & results.p == p & results.Ts == Ts & results.N_train == N_train, 1)) 
                    continue % continue to next p if this combo has been searched before
                end

                if q_is_new % Do this only when q is seen first time
                    q_is_new = 0; % q is no longer new

                    switch algorithm
                        case 'dmd'                       
                            DMD_part_1;
                        case 'havok'
                            HAVOK_part_1;
                    end
                end
                
                switch algorithm
                    case 'dmd'                       
                        DMD_part_2;                        
                    case 'havok'
                        HAVOK_part_2;                        
                end
                
                run_model;

                % Save results
                results(emptry_row,:) = [{Ts, N_train, q, p, mean(MAE)}, num2cell(MAE')]; % add to table of results
                emptry_row = emptry_row + 1; 

            end % p

            save(results_file, 'results', 'emptry_row')
            toc;
    end % q
end % N_train
format short % back to default/short display

% Save results
results(~results.q,:) = []; % remove empty rows
save(results_file, 'results', 'emptry_row')

best_mean_results = results((results.MAE_mean == min(results.MAE_mean)),:)

%% Plot results

y_limits = [2e-3, 1e-1];

%%
figure
subplot(1,3,1)
semilogy(results.N_train.*Ts, results.MAE_1, '.')
grid on
ylabel('MAE_1');
xlabel('T_train');
ylim(y_limits)
title(['DMD, best q = ', num2str(best_mean_results.q)])

subplot(1,3,2)
semilogy(results.N_train.*Ts, results.MAE_1, '.')
grid on
ylabel('MAE 1');
xlabel('T_train');
ylim(y_limits)
title(['DMD, best q = ', num2str(best_mean_results.q)])

subplot(1,3,3)
semilogy(results.N_train.*Ts, results.MAE_2, '.')
grid on
ylabel('MAE 2');
xlabel('T_train');
ylim(y_limits)
title(['DMD, best q = ', num2str(best_mean_results.q)])

%% plot p
figure
semilogy(results.p, results.MAE_1, '.')
grid on
ylabel('MAE_1');
xlabel('p');
ylim(y_limits)
title(['Checkout effect of P'])

%% plot q
figure
semilogy(results.q, results.MAE_mean, '.')
grid on
ylabel('MAE_1');
xlabel('q');
ylim(y_limits)
title(['Checkout effect of Q', ' - best q = ', num2str(best_mean_results.q)])

% %% plot q for specific Ttrain
% figure
% Ntrain_cur = floor(50/Ts);
% results_T = results((results.N_train == Ntrain_cur),:);
% semilogy(results_T.q, results_T.MAE_1, '.')
% grid on
% ylabel('MAE_1');
% xlabel('q');
% ylim(y_limits)
% title(['Q', ' - T train = ', num2str(Ntrain_cur)])
% % 
% %% plot p for specific q and Ttrain
% figure
% Ntrain_cur = floor(80/Ts);
% q_cur = 20;
% results_T = results((results.N_train == Ntrain_cur),:);
% results_q = results_T((results_T.q == q_cur),:);
% semilogy(results_q.p, results_q.MAE_1, '.')
% grid on
% ylabel('MAE_1');
% xlabel('q');
% ylim(y_limits)
% title(['q = ', num2str(q_cur), ' - T train = ', num2str(Ntrain_cur)])

% %% Only for this Ts:
% results_Ts = results((results.Ts == Ts),:);
% best_results_Ts = results_Ts((results_Ts.MAE_1 == min(results_Ts.MAE_1)),:)
% 
% total_time = toc(total_timer); % Display total time taken
% 
% %% For one q:
% results_q = results((results.q == best_mean_results.q),:);
% figure
% % semilogy(results_q.p, results_q.MAE_1, 'r.')
% % hold on
% semilogy(results_q.p, results_q.MAE_1, 'k.')
% % hold off
