
            % Truncate SVD matrixes
            U_tilde = U1(:, 1:p); 
            S_tilde = S1(1:p, 1:p);
            V_tilde = V1(:, 1:p);

            % Setup V2 one timestep into future from V1
            V_til_2 = V_tilde(2:end  , :)'; % Turnd on side (wide short matrix)
            V_til_1 = V_tilde(1:end-1, :)';

            % DMD on V
            AB_tilde = V_til_2*pinv(V_til_1); % combined A and B matrix, side by side
            AB_tilde = stabilise(AB_tilde,3);
            
            % convert to x coordinates
            AB = (U_tilde*S_tilde)*AB_tilde*pinv(U_tilde*S_tilde);
            A = AB(1:q*ny, 1:q*ny);
            B = AB(1:q*ny, q*ny+1:end);            

            % Make matrix sparse
            A(ny+1:end, :) = [eye((q-1)*ny), zeros((q-1)*ny, ny)]; % Add Identity matrix to carry delays over to x(k+1)
            B(ny+1:end, :) = zeros((q-1)*ny, nu); % Input has no effect on delays
            