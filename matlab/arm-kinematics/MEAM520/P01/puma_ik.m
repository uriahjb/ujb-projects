%% Implementing Inverse Kinematics Solution for Puma260 Arm.
function [theta1, theta2, theta3] = puma_ik(x, y, z)

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
    d = [ a -b -d e 0 f ];
    alph = [ pi/2 0 -pi/2 pi/2 pi/2 0 ] ;

    %             alpha / a / theta / d / 0
    L{1} = link([ alph(1) off(1) 0 d(1) 0], 'standard');
    L{2} = link([ alph(2) off(2) 0 d(2) 0], 'standard');
    L{3} = link([ alph(3) off(3) 0 d(3) 0], 'standard');
    L{4} = link([ alph(4) off(4) 0 d(4) 0], 'standard');
    L{5} = link([ alph(5) off(5) 0 d(5) 0 pi/2], 'standard');
    L{6} = link([ alph(6) off(6) 0 d(6) 0], 'standard');

    tool = [1 0 0 0; 0 0 -1 -h; 0 1 0 g; 0 0 0 1]; % for the LED holder
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
    theta1 = atan2(y, x) - atan2(-del, -sqrt(-del, r^2 - del^2));
    theta2 = 0;
    theta3 = 0;
    
end