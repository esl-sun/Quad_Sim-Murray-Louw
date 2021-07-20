
% Truncate SVD matrixes
U_tilde = U1(:, 1:p); 
S_tilde = S1(1:p, 1:p);
V_tilde = V1(:, 1:p);

% Omega = \approx U_tilde*S_tilde*V_tilde'
AB = Y2*pinv(U_tilde*S_tilde*V_tilde'); % combined A and B matrix, side by side
% AB = Y2*pinv(YU); % combined A and B matrix, side by side

% System matrixes from DMD
A  = AB(:, 1:ny );              % System matrix for y(k)
Ad = AB(:,   ny+1:ny*q );       % Delay state matrix for [y(k-1); y(k-2); ...; y(k-q+1)]
B  = AB(:,        ny*q+1:end ); % Input matrix for u(k)

A_dmd  = AB(:,1:ny); % Extract A matrix
B_dmd  = AB(:,(ny+1):end);
A_dmd = stabilise(A_dmd,3);
