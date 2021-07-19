
% Truncate SVD matrixes
U_tilde = U1(:, 1:p); 
S_tilde = S1(1:p, 1:p);
V_tilde = V1(:, 1:p);

% Omega = \approx U_tilde*S_tilde*V_tilde'
AB = Y2*pinv(U_tilde*S_tilde*V_tilde'); % combined A and B matrix, side by side
% AB = Y2*pinv(YU); % combined A and B matrix, side by side

% System matrixes from DMD
A_dmd  = AB(:,1:ny); % Extract A matrix
B_dmd  = AB(:,(ny+1):end);
% A_dmd = stabilise(A_dmd,1);
