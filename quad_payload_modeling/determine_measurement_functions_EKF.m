%%%%%%%%%%%%%%%%%%%%%% enkel pendulum 3D, Euler 2-1 dynamics
%variables

clc;
clear all;
       
syms theta_q_i phi_q_i psi_q_i
syms theta_p_i phi_p_i dtheta_p_i dphi_p_i
syms theta_p_c phi_p_c
syms x_q_c y_q_c z_q_c  



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DCM inertial to quad
roll = [1       0                  0; 
        0       cos(phi_q_i)      sin(phi_q_i); 
        0       -sin(phi_q_i)     cos(phi_q_i)]

pitch = [cos(theta_q_i)     0       -sin(theta_q_i);
        0           1       0; 
        sin(theta_q_i)      0       cos(theta_q_i)]
    
yaw = [cos(psi_q_i)  sin(psi_q_i)   0;
       -sin(psi_q_i) cos(psi_q_i)   0;
       0         0          1]
    
DCM_inertial_to_quad = roll*pitch*yaw;
DCM_quad_to_camera = [0 1 0; 1 0 0; 0 0 -1];
%size(DCM_inertial_to_quad)

%% payload position relative to attachment point in inertial 
%{ Pos_p_att = [sin(theta_p_i)*cos(phi_p_i); sin(phi_p_i); cos(theta_p_i)*cos(phi_p_i)] %}

% vir gazebo assestelsel moet z negatief wees, vir NED moet z positief wees
Pos_p_att = [cos(theta_p_i)*sin(phi_p_i); sin(theta_p_i); -cos(theta_p_i)*cos(phi_p_i)]

  
  
%size(Pos_p_att) 


%% payload position relative to attachment point, but rotated to camera frame
%Pos_p_att_rot = DCM_inertial_to_quad*Pos_p_att
Pos_p_att_rot = DCM_quad_to_camera*(DCM_inertial_to_quad*Pos_p_att)

%size(Pos_p_att_rot)
%% camera frame relative to quad frame
%Pos_c_q = [x_c_q; y_c_q; z_c_q]

%% quad frame relative to camera frame in camera frame
Pos_q_c = [x_q_c; y_q_c; z_q_c]

%size(Pos_c_q)
%% unit vector of payload in camera frame, from estimated angles in inertial frame
%Pos_p_c = Pos_p_att_rot - Pos_c_q
Pos_p_c = Pos_p_att_rot + Pos_q_c
%size(Pos_p_c)

Unit_p_c = Pos_p_c/(sqrt(Pos_p_c(1)^2 + Pos_p_c(2)^2 + Pos_p_c(3)^2))
%size(Unit_p_c)


%% determine jacobian of measurement matrix
h1 = acos(Unit_p_c(3));
%h2 = asin((Unit_p_c(2))/(sin(acos(Unit_p_c(3)))));
h2 = asin((Unit_p_c(1))/(cos(acos(Unit_p_c(3)))));

%h2 = acos((Unit_p_c(1))/(sin(h1)));

%% h1

h1_theta = simplify(diff(h1, theta_p_i))
h1_dtheta = simplify(diff(h1, dtheta_p_i))
h1_phi = simplify(diff(h1, phi_p_i))
h1_dphi = simplify(diff(h1, dphi_p_i))

%% h2
h2_theta = simplify(diff(h2, theta_p_i))
h2_dtheta = simplify(diff(h2, dtheta_p_i))
h2_phi = simplify(diff(h2, phi_p_i))
h2_dphi = simplify(diff(h2, dphi_p_i))

%jacobian([h1; h2], [theta_p_i, dtheta_p_i, phi_p_i, dphi_p_i])

