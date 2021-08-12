
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
% figure(1), semilogy(diag(S1), 'x'), hold on;
% title('Singular values of Omega, showing p truncation')
% plot(p, S1(p,p), 'ro'), hold off;
