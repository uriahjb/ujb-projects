function [sdot] = StorqueStep(s,u)
% s = state vector (16x1)
% sdot = derivative of state at current time
% u = control input (6x1)

global stateMatrix;
global time;

% u = [xd_com; yd_com zd_com phi_com theta_com psi_com]
% Where com = 'commanded'
xd_com    = u(1);
yd_com    = u(2);
zd_com    = u(3);
phi_com   = u(4);
theta_com = u(5);
r_com     = u(6);

% Define all of the system variables
x = s(1);   % World Position x [m]
y = s(2);   % World position y [m]
z = s(3);   % World position z [m]

u = s(4);   % Body frame velocity xb [m/s]
v = s(5);   % Body frame velocity yb [m/s] 
w = s(6);   % Body frame velocity zb [m/s]

% Euler angles.  The comments are slightly wrong
% because really only psi is on z, while phi and theta are on
% the transformed versions of themselves. (X' and Y'')
phi   = s(7);    % Euler Angle on body axis x
theta = s(8);    % Euler angle on body axis y 
psi   = s(9);    % Euler Angle on body axis z

p = s(10);  % Angular rate around body axis x
q = s(11);  % Angular rate around body axis y
r = s(12);  % Angular rate around body axis z

% Angular rates of props 1-4
w1 = s(13);   % [rad/s]
w2 = s(14);   % [rad/s]
w3 = s(15);   % [rad/s]
w4 = s(16);   % [rad/s]

%% Control Laws Start Here

%----Constants, Function Definitions----%
% Define physical system parameters
mass = 3.495;        % [kg]
armLen = 0.382;  % [m]
Ixx = 0.0974;       % [kg*m^2]
Iyy = 0.0963;       % [kg*m^2]
Izz = 0.1874;       % [kg*m^2]
Ixy = 0.0113;
Ixz = -0.0025;
Iyx = 0.0113;
Iyz = -0.0026;
Izx = -.0025;
Izy = -0.0026;

g = 9.81;        % [m/s^2]

% Physical system gains
max_thrust = 1.5*g; % Maximum thrust we can get from a rotor [kg*m/s^2]
max_mom    = 1.0*g;
kM = [3.53023e-7 7.97209e-5 -0.0068914];    %max_mom    / (5.1313e6);%(733.038^2);  % Gain for omega -> Moment               [kg*m^2]
kT = [3.63737e-5 -0.00770417 0.63139];    %max_thrust / (5.1313e6);  % Gain for omega -> Thrust               [kg*m]
kMot = 10;           % Gain on first order motor delay        [1/s]
kRatio = kM(1)./kT(1);     % Ratio of how much Moment [kg*m^2] is exerted by a motor 
                           %  for every [kg*m] of Thrust that would be exerted by the
                           %  same motor speed w.  Units are [m]

% Form the 3x3 Rotation matrix from body to world frame in the Y-X-Z system (Theta, Phi, Psi)
R = [ cos(psi)*cos(theta) - sin(phi)*sin(psi)*sin(theta), cos(theta)*sin(psi) + cos(psi)*sin(phi)*sin(theta), -cos(phi)*sin(theta);...
-cos(phi)*sin(psi),  cos(phi)*cos(psi),  sin(phi);...
cos(psi)*sin(theta) + cos(theta)*sin(phi)*sin(psi), sin(psi)*sin(theta) - cos(psi)*cos(theta)*sin(phi),  cos(phi)*cos(theta)];

% Control gains
kpRoll = 33;  
kdRoll = 30;

kpYaw = 0;
kdYaw = 100;

kdXTrans = 12;

kdYTrans = 12;

if (zd_com > 0)
    kpZTrans = 0;
else
    kpZTrans = 0;%12.4;
end
kdZTrans = 30;
snr = 40;

% Simulating control delay and noise 
delay = 0.05;
stateIndex = find(time < (time(length(time)) - delay), 1, 'last');
if isempty(stateIndex),
    stateIndex = 1;
end

psi_perceived = stateMatrix(stateIndex, 9) + awgn(stateMatrix(stateIndex, 9), snr);
phi_perceived = stateMatrix(stateIndex, 7) + awgn(stateMatrix(stateIndex, 7), snr);
theta_perceived = stateMatrix(stateIndex, 8) + awgn(stateMatrix(stateIndex, 8), snr);
r_perceived = stateMatrix(stateIndex, 12) + awgn(stateMatrix(stateIndex, 12), snr);
p_perceived = stateMatrix(stateIndex, 10) + awgn(stateMatrix(stateIndex, 10), snr);
q_perceived = stateMatrix(stateIndex, 11) + awgn(stateMatrix(stateIndex, 11), snr);

%% Run Storque PID controls code
proto_pid = strcat('_', num2str(psi_perceived*180/pi),'_', ...
                        num2str(phi_perceived*180/pi),'_', ...
                        num2str(theta_perceived*180/pi), '_', ...
                        num2str(r_perceived*180/pi), '_', ...
                        num2str(p_perceived*180/pi), '_', ...
                        num2str(q_perceived*180/pi), '_', ... 
                        '1490', '_', '1490', '_', '1490', '_', '1515', '_', ...
                        num2str(mass), '_', ...
                        num2str(Ixx), '_', ...
                        num2str(Iyy), '_', ...
                        num2str(Izz), '_', ...
                        num2str(kpRoll), '_', ...
                        num2str(kdRoll), '_', ...
                        num2str(kpYaw), '_', ...
                        num2str(kdYaw));
                    
proto_pid = strrep(proto_pid, '_', ' ');
proto_pid = strcat('./proto_pid', proto_pid);
[success, pwm_out] = system(proto_pid);

%disp(proto_pid);
if (success == 0),
    disp('proto_pid failure');
else
    %disp(pwm_out);
end

% Convert from pwm to forces and omegas
pwm_out = str2num(pwm_out);

%%

% Define the function that will give us thrusts in the zb axis as a 
% of w (omega)
T = @(w,k)(k(1)*w.^2 + k(2).*w + k(3));
M = @(w,k)(k(1)*w.^2 + k(2).*w + k(3));

% Define the inverse of T(w,k)
Ttow = @(T,k)((-k(2) + sqrt(-4*k(1)*k(3) + 4*k(1)*T + k(2)^2))/(2*k(1)));
%Ttow = @(T,k)(sqrt(T./k(1)));

% Define pwm to force
Tpwm = @(pwm)(22373.4*(pwm/20000).^2 - 2313*(pwm/20000) + 60);

% Calculate trim forces and moments needed to maintain hover
forceWorldXTrim   = 0;
forceWorldYTrim   = 0;
forceWorldZTrim   = mass*g;
forceZTrim        = mass*g / (cos(phi)*cos(theta));
momPhiTrim        = 0;
momPsiTrim        = 0;
momThetaTrim      = 0;

%----Dynamic Controls Calculations----%
% Spatial Control
%{
thrustCont(1) = kdXTrans*(xd_com - u) * mass; % Thrust in x [N]
thrustCont(2) = kdYTrans*(yd_com - v) * mass; % Thrust in y [N]
thrustCont(3) = (kpZTrans*(0 - z) + kdZTrans*(zd_com - w))*mass ; %Thrust in z [N]


forceWorldX = forceWorldXTrim + thrustCont(1);
forceWorldY = forceWorldYTrim + thrustCont(2);
forceWorldZ = forceWorldZTrim + thrustCont(3);
forceZ      = forceZTrim      + thrustCont(3)/(cos(phi)*cos(theta));

if forceZ > max_thrust*4
    forceZ = max_thrust*4;
elseif forceZ < 0
    forceZ = 0;
end

if forceWorldZ > max_thrust*4
    forceWorldZ = max_thrust*4;
elseif forceWorldZ < 0
    forceWorldZ = 0;
end

bigger = max(abs(forceWorldX),abs(forceWorldY));
smaller = min(abs(forceWorldX),abs(forceWorldY));

if bigger ~= 0
    big_small_ratio = abs(smaller) / abs(bigger);
else
    big_small_ratio = 0;
end

% u^2 + (big_small_ratio*u)^2 + forceWorldZ^2 = forceZ^2;

%(1+ big_small_ratio^2) * u^2 + 0*u + (forceWorldZ^2 - forceZ^2)
most_xory = sqrt( - 4*(1+big_small_ratio^2)*(forceWorldZ^2 - (max_thrust*4)^2)) / (2* (1+big_small_ratio^2));

if most_xory > abs(bigger)
    most_xory = abs(bigger);
end

forceDesZ = sqrt(most_xory^2 + (big_small_ratio*most_xory)^2 + forceWorldZ^2);

if abs(forceWorldX) >= abs(forceWorldY)
    finalX = sign(forceWorldX)*most_xory;
    finalY = sign(forceWorldY)*most_xory*big_small_ratio;
else
    finalX = sign(forceWorldX)*most_xory*big_small_ratio;
    finalY = sign(forceWorldY)*most_xory;
end

% We know the final z force that we need, and we know the magnitude of the
% final vector.  We want to find the x and y components that are in the
% proper proportion, and satisfy the magnitude constraint.  Thus, we can
% say:
% min(x,y) = a*max(x,y) = b
% b^2 + a^2*b^2 = forceZ^2 - forceWorldZ^2
% b = sqrt((forceZ^2 - forceWorldZ^2) / (1 + a^2))

% Now we back out what angle is required for such lateral accelerations.
% We do this by realizing that once we've selected a commanded angle, the
% quad will converge on it, eventually stabilizing at the commanded angle
% and powering all rotors equally such that their sum adds to the
% forceZ value, assuming the angle is not so severe that this value is
% greater than the maximum possible thrust.
% R*(0 0 forceZ)' = (forceWorldX forceWorldY forceWorldZ)'

% sin(phi)*forceZ = forceWorldY
phi_com_des = asin(finalY/forceDesZ);

% -cos(phi)*sin(theta) * forceZ = forceWorldX
theta_com_des = asin( -finalX / (cos(phi_com)*forceDesZ) );

% cos(phi)*cos(theta) * forceZ = (thrustCont(3))
%psi_com = 0;

phi_com_des = sign(phi_com_des)*min(abs(phi_com_des),.5);
theta_com_des = sign(theta_com_des)*min(abs(theta_com_des),.5);

phi_com = phi_com + .19*(phi_com_des - phi_com);
theta_com = phi_com + .19*(theta_com_des - theta_com);


% Moment = (Angular Accel Desired) * Moment of Inertia
momCont(1) = (kpRoll*(  phi_com -   phi) - kdRoll*p) * Ixx;  % Phi 
momCont(2) = (kpRoll*(theta_com - theta) - kdRoll*q) * Iyy;  % Theta
momCont(3) =  kdYaw *(    r_com -   r  ) * Izz;  %(kpYaw *(  psi_com -   psi) - kdYaw *(r_com - r) * Izz;  % Psi

% Define and calculate the vertical force and the three body-axis moments
% that we want
momPhi   = momPhiTrim   + momCont(1);
momTheta = momThetaTrim + momCont(2);
momPsi   = momPsiTrim   + momCont(3);

% Determine the required motor forces we desire to achieve these force /
% moments by applying these constraints in order.  First, we distribute the
% required z force evenly between all the motors.  Then, we use any
% remaining flexibility in the thrusts to exert moments about the x and y
% axes, up to the actual momPhi and momTheta values we've just calculated.
% Finally, if the motors are still not max-ed or min-ed out, we can put a
% yaw moment on the vehicle with any remaining thrust flexibility.

clipped_moment_Phi   = min(abs(momPhi/(2*armLen)), (max_thrust/2));
clipped_moment_Theta = min(abs(momTheta/(2*armLen)), (max_thrust/2));

max_attitude_thrust_increase = max( clipped_moment_Phi,clipped_moment_Theta);

fDes = max_attitude_thrust_increase* ([1 1 1 1]');

fDes(1) = fDes(1) - clipped_moment_Phi*sign(momPhi); %<-- ???
fDes(2) = fDes(2) + clipped_moment_Phi*sign(momPhi);
fDes(3) = fDes(3) - clipped_moment_Theta*sign(momTheta);
fDes(4) = fDes(4) + clipped_moment_Theta*sign(momTheta);

%Scale it up to the total thrust we want, or the most we can achieve
cur_thrust = sum(fDes);
max_possible_added = max_thrust - max(fDes);

if ((forceZ - cur_thrust)/4 > max_possible_added)
    fDes = fDes + max_possible_added;
else
    fDes = fDes + max((forceZ-cur_thrust)/4,0);
end

ab = [3 4];
cd = [1 2];

if sign(momPsi) > 0
    ab = [1 2];
    cd = [3 4];
end

yaw_clip1 = max_thrust - max(fDes(ab));
yaw_clip2 = min(fDes(cd)) - 0;

yaw_clip = min(yaw_clip1, yaw_clip2);

if ( (kRatio*yaw_clip) < abs(momPsi/4) )
    fDes(ab) = fDes(ab) + yaw_clip;
    fDes(cd) = fDes(cd) - yaw_clip;
else
    fDes(ab) = fDes(ab) + abs(momPsi/kRatio)/4;
    fDes(cd) = fDes(cd) - abs(momPsi/kRatio)/4;
end

%This matrix describes the mapping from: The desired moments and vertical
%force that we've just calculated -to- the thrust required from each motor
%to achieve those total force / moments.
%{
A =        [1       1       1        1;...
            armLen -armLen  0        0;...
            0       0       armLen  -armLen;...
            kRatio  kRatio -kRatio  -kRatio];
%}
%We solve our matrix equation [forceZ momPhi momTheta momPsi]' = A*fDes by
%multiplying both sides by the inverse of M.  Though M is a constant matrix
%for a given physical configuration with fixed motor characteristics, we
%may tune these during testing.  For now, it is calculated every time
%StorqueStep is run, though in the future it could be pre-computed to
%improve speed.
%fDes = A\[forceZ momPhi momTheta momPsi]';

%Constrain the forces to a physically possible ranges.  The rotors only
%spin one way, so we cannot exert a negative force.  Also, the rotors have
%a maximum thrust they can attain, so we can't ask for more than that.
for b = 1:4
    if fDes(b) > max_thrust
        fDes(b) = max_thrust;
    elseif fDes(b) < 0
        fDes(b) = 0;
    end
end

%Convert the final desired thrusts into desired prop speeds
%wDes = Ttow(fDes,kT);
%}

%% Using proto_pid code
Tout = Tpwm(pwm_out');
%disp('Tout');
%disp(Tout);
wDes = Ttow(Tout, kT);
%disp('wDes');
%disp(wDes);
%disp('w1 w2 w3 w4');
%disp([w1 w2 w3 w4]);

%In the embedded code, we would now convert wDes to required PWM output, and
%this would conclude the controls code.  The quadrotor's motors will not
%instantly respond to the PWM that we command, but our controls will be
%robust enough to keep it stable despite this, as we prove with this
%simulation.

%% Physical Modeling Starts Here

% Build the tensors that describe the quadrotor dynamics
Itens = [Ixx Ixy Ixz;...  % Inertial tensor
         Iyx Iyy Iyz;...
         Izx Izy Izz];
 
Mtens = mass * eye(3,3); % Mass tensor


%----Calculate the Dynamics----%
% Linear Acceleration
linAccel = (Mtens)\([0 0 -mass*g]' + R*[0 0 (T(w1,kT)+T(w2,kT)+T(w3,kT)+T(w4,kT))]');

% Angular Acceleration
omegaDot = (Itens)\([-armLen*(T(w1,kT)-T(w2,kT)) -armLen*(T(w3,kT)-T(w4,kT)) M(w1,kM)+M(w2,kM)-M(w3,kM)-M(w4,kM)]' - cross(s(10:12)', Itens*s(10:12)'));

% Matrix that brings you from your angular velocities to derivatives of euler
% angles.
omegaDotToEulerDot = [cos(theta) 0 -cos(phi)*sin(theta);...    
                      0          1      sin(phi);...
                      sin(theta) 0   cos(phi)*cos(theta)];

eulerAngleDot = (omegaDotToEulerDot)\[p q r]';

% First order motor response.
omegaPropsDot = kMot*(wDes' - [w1 w2 w3 w4]);

% Construct the output vector sdot that contains the derivatives of the
% input state s
sdot = [s(4:6) linAccel' eulerAngleDot' omegaDot' omegaPropsDot];
end