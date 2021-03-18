%%%%%%%%%%%%%%%%%%%%%% enkel pendulum 3D, Euler 2-1 dynamics
%variables
% jys n legend 
clc;
clear all;

syms l g  % top link and mass    t1 = xz 
syms theta_p_i phi_p_i dphi_p_i dtheta_p_i
syms ddxq ddyq ddzq




f1 = dtheta_p_i;
f2 = -(l*cos(theta_p_i)*sin(theta_p_i)*dphi_p_i^2 + ddyq*cos(theta_p_i) + (ddzq-g)*cos(phi_p_i)*sin(theta_p_i) - ddxq*sin(phi_p_i)*sin(theta_p_i))/(l);
f3 = dphi_p_i;
f4 = (-(ddxq*cos(phi_p_i) + (ddzq - g)*sin(phi_p_i) - 2*dtheta_p_i*dphi_p_i*l*sin(theta_p_i)))/(l*cos(theta_p_i))

%%

%% theta 1

f2_t = simplify(diff(f2, theta_p_i))
f4_t = simplify(diff(f4, theta_p_i))

f2_dt = simplify(diff(f2, dtheta_p_i))
f4_dt = simplify(diff(f4, dtheta_p_i))

f2_p = simplify(diff(f2, phi_p_i))
f4_p = simplify(diff(f4, phi_p_i))

f2_dp = simplify(diff(f2, dphi_p_i))
f4_dp = simplify(diff(f4, dphi_p_i))

simplify(jacobian([f1, f2, f3, f4], [theta_p_i; dtheta_p_i; phi_p_i; dphi_p_i]))

