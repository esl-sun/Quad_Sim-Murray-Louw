% Write to csv estimated cable length vs amount of training data
% Estimate cable length with FFT
% Code from Anton Erasmus

disp('Estimating cable length with FFT')
disp('--------------------------------')

% Estimate cable length with FFT
sim_type = 'Prac'
real_length = 0.5

reload_data = 1; % Re-choose csv data file for SITL data
plot_results = 0;
write_csv = 1;

% Extract data
extract_data; % Run once uncommented. get error. then comment this and
% run again. only need y_data to load, not train and test
close all

% Signal
signal = timeseries(y_data.Data(:,2), y_data.Time);
plot(signal)

start_time = 20;
max_length = 3; % Max cable length considered
min_length = 0.2; % Minimum cable length considered
f_res = 0.01; % Frequency resolution

start_index = find(abs(signal.Time - start_time) < Ts);
start_index = start_index(1);

train_times = (Ts:0.03:20); % Array of training lengths considered
estimated_lengths = zeros(1,length(train_times)); % empty array for lengths estimated for each length of training time
estimated_index = 1; % next estimated length entry index

for stop_time = start_time + train_times

    stop_index = find(abs(signal.Time - stop_time) < Ts);
    stop_index = stop_index(1);

    % Sampling period
    T = signal.Time(start_index+1) - signal.Time(start_index);
    % Sampling frequency
    Fs = 1/T;
    
    train_data = signal.Data(start_index:stop_index);
    
%     figure
%     plot(signal.Time(start_index:stop_index), signal.Data(start_index:stop_index))
%     title('Data used by FFT')
%     ylabel('payload swing angle [rad]')

    % FFT
    Y = fft(train_data, floor(Fs/f_res));
    L = numel(Y); % Length of signal
    P2 = abs(Y/L);
    P1 = P2(1:round(L/2)+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = Fs*(0:round(L/2))/L;

    % Reduce max and min freq
    decimals = f_res.*10.^(1:20); % 20 is max number of decimals
    decimals = find(decimals==round(decimals),1);

    min_freq = round(sqrt(g/max_length)/(2*pi), decimals);
    max_freq = round(sqrt(g/min_length)/(2*pi), decimals);

    freq_start = find(abs(f - min_freq) < 0.001);
    freq_stop = find(abs(f - max_freq) < 0.001);

    f = f(freq_start(1):freq_stop(1));
    P1 = P1(freq_start(1):freq_stop(1));

%     %Plot
%     figure
%     plot(f,P1,'.-')
%     title('Single-Sided Amplitude Spectrum of X(t)')
%     xlabel('f (Hz)')
%     ylabel('|P1(f)|')

    % Check for maximum
    fmax_index = find(P1 == max(P1));
    fmax = f(fmax_index);

    if ismember(1, fmax_index)
        % Find max
        max_index = length(P1);
        for i = 2:length(P1)-1
            if P1(i) > P1(i-1) && P1(i) > P1(i+1)
                if P1(i) > P1(max_index)
                   max_index = i;
                end
            end
        end

        if max_index == length(P1) && max(P1) == P1(1)
            pend_freq = f(1);
        elseif max_index == length(P1)
            pend_freq = inf;
        else
            pend_freq = f(max_index);
        end
    else
        pend_freq = fmax(1);
    end

    if pend_freq == inf
        l_est = 0;
    else
        l_est = ((mq+mp)/mq)*g/((pend_freq(1) * 2*pi)^2);
    end

    % Measured oscillation frequency
    wn_measured = pend_freq(1) % rad/s

    % Estimated length (m)
    l_est
    
    estimated_lengths(estimated_index) = l_est; % Save value in array
    estimated_index = estimated_index + 1;
    
end

percentage_error = (estimated_lengths - real_length)./real_length.*100;

%%
figure
plot(train_times, estimated_lengths)
hold on
plot(train_times, percentage_error)
hold off

%% write to csv
if write_csv
    csv_filename = ['/home/murray/Masters/Thesis/results/csv/', 'cable_length_vs_train_time_', sim_type, '_', simulation_data_file, '_', num2str(start_time), '_', num2str(real_length), '.csv'];
    csv_filename
    
    csv_matrix = [train_times', estimated_lengths', percentage_error'];
    VariableTypes = {'double',      'double',           'double'};
    VariableNames = {'train_time',  'estimated_length', 'percentage_error'};
    csv_table = table('Size',size(csv_matrix),'VariableTypes',VariableTypes,'VariableNames',VariableNames);
    csv_table(:,:) = array2table(csv_matrix);
end
writetable(csv_table,csv_filename)