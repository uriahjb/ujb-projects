%% Implementing Inverse Kinematics Solution for Puma260 Arm.
function [theta1, theta2, theta3, theta4, theta5, theta6] = puma_ik(x, y, z, theta, phi, psi)

    %% Puma DH parameters and tool transformation, from puma260.m definition
    % -------------------------------------------------------------------------
    % PUMA260 constants
    a = 13.0*0.0254;
    b = 3.5*0.0254;
    c = 8.0*0.0254;
    d = 3.0*0.0254;
    e = 8.0*0.0254;
    f = 2.5*0.0254;
    g = 0.5*0.0254;
    h = 1.1*0.0254;

    off = [ 0 c 0 0 0 0 ];
    DD = [ a -b -d e 0 f ];
    alph = [ pi/2 0 -pi/2 pi/2 pi/2 0 ] ;

    %             alpha / a / theta / d / 0
    L{1} = [ alph(1) off(1) 0 DD(1) 0];
    L{2} = [ alph(2) off(2) 0 DD(2) 0];
    L{3} = [ alph(3) off(3) 0 DD(3) 0];
    L{4} = [ alph(4) off(4) 0 DD(4) 0];
    L{5} = [ alph(5) off(5) 0 DD(5) 0 pi/2];
    L{6} = [ alph(6) off(6) 0 DD(6) 0];

    tool = [1 0 0 0; 0 0 -1 -h; 0 1 0 (f+g); 0 0 0 1]; % for the LED holder
    % -------------------------------------------------------------------------

    %% Rotation Matrix
    % -------------------------------------------------------------------------
    
    R11 = (cos(phi)*cos(theta)*cos(psi) - sin(phi)*sin(psi));
    R12 = (-(cos(phi)*cos(theta)*sin(psi)) - sin(phi)*cos(psi));
    R13 = (cos(phi)*sin(theta));
    R21 = (sin(phi)*cos(theta)*cos(psi)+ cos(phi)*sin(psi));
    R22 = (-(sin(phi)*cos(theta)*sin(psi)) + cos(phi)*cos(psi));
    R23 = (sin(phi)*sin(theta));
    R31 = (-sin(theta)*cos(psi));
    R32 = (sin(theta)*sin(psi));
    R33 = (cos(theta));
   
    % -------------------------------------------------------------------------

    
    % Compute theta1
    del = b + d;
    r = sqrt(x^2 + y^2);
    theta1 = (atan2(y, x) + atan2(-del, sqrt(r^2 - del^2)));
   
    % Compute theta3
    r_2 = x^2 + y^2 - del^2;
    s = z - a;
    D = (r_2 + s^2 - c^2 - e^2)/(2*c*e);
    theta3 = atan2(sqrt(1 - D^2), D);
    
    theta3_actual = theta3 - pi/2;
    
    % Compute theta2
    theta2 = atan2(z - a, sqrt(x^2 + y^2 - del^2)) - atan2(e*sin(theta3), c + e*cos(theta3));
   
    
    
    theta1 = 0;
    theta2 = 0;
    theta3 = 0;
    theta4 = 0;
    theta5 = 0;
    theta6 = 0;
   
    theta3 = theta3_actual;
    
    % Orienting tool frame to align with euler angles and transforming to 
    % spherical wrist
    
    Orientation = [[R11 R12 R13 x];
                   [R21 R22 R23 y];
                   [R31 R32 R33 z];
                   [0   0   0   1]];
            
    R = Orientation*tool;
    trplot(R);
      
    
    
    
    
end