%% Symbolic variables
syms mp mq l g;
syms s;

%% State Space
A = [0          0           0           0           0           (mp/mq)*g;
     0          0           0   (g*mp)/mq   0           0;
     0          0           0   -g*(mq+mp)/(l*mq)   0           0;
     0          0           1           0           0           0;
     0          0           0           0           0           -g*(mq+mp)/(l*mq);
     0          0           0           0           1           0];
 
B = [1/mq       0;
     0          1/mq;
     0          -1/(l*mq);
     0          0;
     -1/(l*mq)  0;
     0          0]; 
 
 C = [1 1 0 0 0 0]; %[Vn Ve]
 %C = [1 1 0 1 0 1]; % [phi theta]
 D = 0;
 
 %% transfer functions
 % find state transition matrices
 phi = inv(s*eye(6) - A);
 
 % Find transfer function
 H = C*phi*B
 
 % display
 pretty(simplify(simplifyFraction(H)))
 
 
 
 
 % calculate
 %pretty(simplify(simplifyFraction(C*(inv(s.*eye(6) - A))*B)))
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 