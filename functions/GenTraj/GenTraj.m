function [Y,T] = GenTraj(A,V,P,Tj,Ts_mpc)
%GenTraj Trajectory generation for point to point motion with velocity,
% acceleration, jerk and snap (second time derivative of acceleration)
% constraints
% Example:[Y,T]=GenTraj(A,V,P,Tj,Ts) returns the position, velocity
% and acceleration profiles for a snap controlled law from the specified 
% constraints on maximum velocity V, maximum acceleration A, desired 
% travelling distance P, Jerk time Tj and Snap time Ts. 
% Y is a 3 row matrix containing the position, velocity and acceleration
% profile associated to the time vector T.
%
% If Tj and Ts are not given, Tj=Ts=0 is assumed. The resulting mouvement is
% acceleration limited. If Ts is not given, Ts=0 and P contains the points
% of the corresponding jerk limited law
%
% R. Béarée, ENSAM CER Lille, France
% 
% 2007-06-14

%--------------------------------------------------------------------------

if nargin ~= 5
   error('Mismatch number of input parameters');
end

% Ts_mpc = interpolation time / Sample time

% force Tj to multiple of Ts_mpc
Tj = floor(Tj/Ts_mpc)*Ts_mpc;

% Verification of the acceleration and velocity constraints  
Ta = V/A; % Acceleration time
Tv = (P-A*Ta^2)/(V); % Constant velocity time
if P<=Ta*V % Triangular velocity profile
    Tv=0;Ta=sqrt(P/A);
end
Tf=2*Ta+Tv+Tj; % Mouvement time

% Elaboration of the limited acceleration profile 
T=0:Ts_mpc:Tf;

% Pre-allocate memory
t = zeros(1,4); 
s = zeros(1,4);
law = zeros(4,length(T));
Y = zeros(3,length(T));

t(1)=0; t(2)=Ta; t(3)=Ta+Tv; t(4)=2*Ta+Tv;
s(1)=1; s(2)=-1; s(3)=-1; s(4)=1;

% P=zeros(3,length(T));
% Ech=zeros(4);
for k=1:3
    u = zeros(1,k+1);
    u(1,1) = 1;
    for i=1:4
        Ech = tf(1, u,'inputdelay',t(i));
        law(i,:)=impulse(s(i)*A*(Ech),T);
    end
    Y(k,:)=sum(law);
end

% Average Filter for Jerk limitation
a = 1;      % Filter coefficients
b = (1/(Tj/Ts_mpc))*ones(1,(Tj/Ts_mpc)); % Filter duration equal to jerk time
Y(3,:)= filter(b,a,Y(3,:));
Y(2,1:length(T)-1)=diff(Y(3,:),1)/Ts_mpc;
Y(1,1:length(T)-1)=diff(Y(2,:),1)/Ts_mpc;


%%%%%%%%%%%%%%%
figure;
sp(1)=subplot(3,1,1);plot(T,Y(3,:))
sp(2)=subplot(3,1,2);plot(T,Y(2,:))
sp(3)=subplot(3,1,3);plot(T,Y(1,:))
linkaxes(sp,'x');
ylabel(sp(1),'Position [m]');ylabel(sp(2),'Velocity [m/s]');ylabel(sp(3),'Acceleration [m/s^2]');xlabel(sp(3),'Time [s]')

