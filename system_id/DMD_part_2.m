
% Truncate SVD matrixes
U_tilde = U1(:, 1:p); 
S_tilde = S1(1:p, 1:p);
V_tilde = V1(:, 1:p);

% Omega = \approx U_tilde*S_tilde*V_tilde'
AB = Y2*pinv(U_tilde*S_tilde*V_tilde'); % combined A and B matrix, side by side
% AB = Y2*pinv(YU); % combined A and B matrix, side by side

% Extract system matrixes
% Discrete, State space model:
% x(k+1) = A*x(k) + Ad*[x(k-1); x(k-2); ...; x(k-q+1)] + B*u(k)
A  = AB(:, 1:ny );              % System matrix for y(k)
Ad = AB(:,   ny+1:ny*q );       % Delay state matrix for [y(k-1); y(k-2); ...; y(k-q+1)]
B  = AB(:,        ny*q+1:end ); % Input matrix for u(k)

% Big state matrix including delays:
% [x(k+1); x(k); ...; x(k-q)] = A_big * [x(k); x(k-1); ...; x(k-q+1)] + B*u(k)
% A_big = [
%     [A, Ad]; 
%     [eye(ny*(q-1)), zeros(ny*(q-1), ny)]
%         ]; 
% 
% % Stablise minimally unstable discrete state space system matrix
% A_big = stabilise(A_big,3);
% 
% % Extract matrices
% A  = A_big(1:ny, 1:ny);
% Ad = A_big(1:ny,   ny+1:end);

% Into old format:
A_dmd = A;
B_dmd = [Ad, B];

% A_dmd  = AB(:,1:ny); % Extract A matrix
% B_dmd  = AB(:,(ny+1):end);

