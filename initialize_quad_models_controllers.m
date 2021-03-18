%% Control
s = tf('s');

%% Longitudinal

% Pitch Rate Controller
G_PR_OL = 2*max_T*(d/(Iyy*tau_T))*(1/(s*(s+1/tau_T)));
D_PR = K_qp + K_qi/s + K_qd*s;
G_PR_CL = (D_PR*G_PR_OL)/(1+D_PR*G_PR_OL);

[G_PR_OL_NUM, G_PR_OL_DENOM] = tfdata(G_PR_OL, 'v');

% Pitch Angle Controller
G_P_OL = G_PR_CL * 2*0.5/s;
D_P = K_theta;
G_P_CL = (D_P*G_P_OL)/(1+D_P*G_P_OL);

[G_P_OL_NUM, G_P_OL_DENOM] = tfdata(G_P_OL, 'v');

% Longitudinal Velocity Controller
G_VN_OL = max_total_T*(1/mq)/s * G_P_CL;
if enable_payload
   G_pln = max_total_T*(1/(mq*s) - (g*mp)/(mq*(l*mq*s^3 + g*mp*s + g*mq*s)));            
   G_VN_OL = G_P_CL * G_pln;
end
D_VN = K_up + K_ui/s + K_ud*s;
G_VN_CL = (D_VN*G_VN_OL)/(1+D_VN*G_VN_OL);
fb_Vn = bandwidth(G_VN_CL);

[G_VN_OL_NUM, G_VN_OL_DENOM] = tfdata(G_VN_OL, 'v');

% if enable_adaptive
%    G_VN_CL = Wm;
% end

% Longitudinal Position Controller
G_PN_OL = G_VN_CL * 1/s;
D_PN = K_np + K_ni/s + K_nd*s;
G_PN_CL = (G_PN_OL*D_PN)/(1+G_PN_OL*D_PN);

[G_PN_OL_NUM, G_PN_OL_DENOM] = tfdata(G_PN_OL, 'v');

%% Lateral

% Roll Rate Controller
G_RR_OL = 2*max_T*(d/(Ixx*tau_T))*(1/(s*(s+1/tau_T)));
D_RR = K_pp + K_pi/s + K_pd*s;
G_RR_CL = (D_RR*G_RR_OL)/(1+D_RR*G_RR_OL);
[G_RR_OL_NUM, G_RR_OL_DENOM] = tfdata(G_RR_OL, 'v');

% Roll Angle Controller
G_R_OL = G_RR_CL * 2*0.5/s;
D_R = K_phi;
G_R_CL = (D_R*G_R_OL)/(1+D_R*G_R_OL);

[G_R_OL_NUM, G_R_OL_DENOM] = tfdata(G_R_OL, 'v');

% Lateral Velocity Controller
G_VE_OL = max_total_T*(1/mq)/s * G_R_CL;
if enable_payload                 
   G_ple = max_total_T*(1/(mq*s) - (g*mp)/(mq*(l*mq*s^3 + g*mp*s + g*mq*s)));
   G_VE_OL = G_R_CL * G_ple;
end
D_VE = K_vp + K_vi/s + K_vd*s;
G_VE_CL = (D_VE*G_VE_OL)/(1+D_VE*G_VE_OL);

[G_VE_OL_NUM, G_VE_OL_DENOM] = tfdata(G_VE_OL, 'v');

% Lateral Position Controller
G_PE_OL = G_VE_CL * 1/s;
G_PE_CL = (G_PE_OL*K_ep)/(1+G_PE_OL*K_ep);

[G_PE_OL_NUM, G_PE_OL_DENOM] = tfdata(G_PE_OL, 'v');

%% Directional

% Yaw Rate Controller
G_YR_OL = 4*max_T*(Rn/(Izz*tau_T))*(1/(s*(s+1/tau_T)));
D_YR = K_rp + K_ri/s + K_rd*s;
G_YR_CL = (D_YR*G_YR_OL)/(1+D_YR*G_YR_OL);
[G_YR_OL_NUM, G_YR_OL_DENOM] = tfdata(G_YR_OL, 'v');
% Yaw Angle Controller
G_Y_OL = G_YR_CL * 2*0.5/s;
D_Y = K_psi;
G_Y_CL = (D_Y*G_Y_OL)/(1+D_Y*G_Y_OL);

[G_Y_OL_NUM, G_Y_OL_DENOM] = tfdata(G_Y_OL, 'v');

%% Heave

% Vertical Velocity Controller
G_VD_OL = 4*max_T*(1/(mq*tau_T))/(s*(s+1/tau_T));
D_VD = K_wp + K_wi/s + K_wd*s;
G_VD_CL = (D_VD*G_VD_OL)/(1+D_VD*G_VD_OL);

[G_VD_OL_NUM, G_VD_OL_DENOM] = tfdata(G_VD_OL, 'v');

% Vertical Position Controller
G_PD_OL = G_VD_CL * 1/s;
G_PD_CL = (K_dp*G_PD_OL)/(1+K_dp*G_PD_OL);

[G_PD_OL_NUM, G_PD_OL_DENOM] = tfdata(G_PD_OL, 'v');
