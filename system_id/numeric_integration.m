% Estimate model to integrate velocit to obtain position
% Used to add position to HAVOK model

q=5
% t_train = 1:8
% p_train = t_train
% v_train = ones(length(p_train))
% N_train = length(p_train)

% P2;
PV = []; % Position and Velocity data 
w = N_train - q; % num columns of PV and P2 matrix

% Newest state at top
% Add velocities
for delay = 1:q 
    PV = [ ... 
            v_train(delay:delay+w-1); 
            PV
         ];
end

% Add position to top row
PV = [ ... 
            p_train(delay:delay+w-1); 
            PV
         ];

% Position data at next time step to PV
P2 = p_train(q+1:q+w); 

% Linear regression
Int = P2/PV
