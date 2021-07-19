% Code from Anton Erasmus

disp('Estimating cable length with FFT')
disp('--------------------------------')

% Actual natural frequency
wn = sqrt(g/l*(mq+mp)/mq) % rad/s

% Estimate cable length with FFT
reload_data = 1; % Re-choose csv data file for SITL data
plot_results = 0;

% Extract data
extract_data;
close all

% Signal
signal = timeseries(y_data.Data(:,2), y_data.Time);

window_start = 6;
window_stop = window_start + 10;
max_length = 10;
min_length = 0.1;

start = find(signal.Time == window_start);
stop = find(signal.Time == window_stop);

% Sampling period
T = signal.Time(2) - signal.Time(1);
% Sampling frequency
Fs = 1/T;
% Frequency resolution
f_res = 0.01;

S = signal.Data(start:stop);
figure
plot(signal.Time(start:stop), signal.Data(start:stop))
title('Data used by FFT')
ylabel('payload swing angle [rad]')

% FFT
Y = fft(S, Fs/f_res);
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

freq_start = find(f == min_freq);
freq_stop = find(f == max_freq);

f = f(freq_start(1):freq_stop(1));
P1 = P1(freq_start(1):freq_stop(1));

% Plot
figure
plot(f,P1,'.-')
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')

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
wn_measured = (pend_freq(1) * 2*pi) % rad/s

% Estimated length (m)
l_est