%% Implementing Inverse Kinematics Solution for Puma260 Arm.
function [theta1, theta2, theta3, theta4, theta5, theta6] = puma_ik(x, y, z, theta, phi, psi)

    Theta = [0 0 0 0 0 0];

    %% Puma DH parameters and tool transformation, from puma260.m definition
    % -------------------------------------------------------------------------
    % PUMA260 constants
    a = 13.0*0.0254;
    b = 2.5*0.0254;
    c = 8.0*0.0254;
    d = 2.5*0.0254;
    e = 8.0*0.0254;
    f = 2.5*0.0254;
    g = 0.5*0.0254;
    h = 1.1*0.0254;

    off = [ 0 c 0 0 0 0 ];
    DD = [ a -b -d e 0 f ];
    alph = [ pi/2 0 -pi/2 pi/2 pi/2 0 ] ;
    
    alpha1 = pi/2;
    alpha2 = 0;
    alpha3 = -pi/2;
    alpha4 = pi/2;
    alpha5 = pi/2;
    alpha6 = 0;
    
    d1 = a;
    d2 = -b;
    d3 = -d;
    d4 = e;
    d5 = 0;
    d6 = f;
    
    a1 = 0;
    a2 = c;
    a3 = 0;
    a4 = 0;
    a5 = 0;
    a6 = 0;
    
    threshold = 1e6;

    %             alpha / a / theta / d / 0
    L{1} = [ alph(1) off(1) 0 DD(1) 0];
    L{2} = [ alph(2) off(2) 0 DD(2) 0];
    L{3} = [ alph(3) off(3) 0 DD(3) 0];
    L{4} = [ alph(4) off(4) 0 DD(4) 0];
    L{5} = [ alph(5) off(5) 0 DD(5) 0 pi/2];
    L{6} = [ alph(6) off(6) 0 DD(6) 0];
    
    %% --------------------------------------------------------------------
    % Rotation Matrix
    % ---------------------------------------------------------------------
    
    Rphi = [[cos(phi) -sin(phi) 0];
            [sin(phi) cos(phi)  0];
            [0        0         1]];
        
    Rtheta = [[cos(theta)  0 sin(theta)];
              [0           1 0         ];
              [-sin(theta) 0 cos(theta)]];
          
    Rpsi = [[cos(psi) -sin(psi) 0];
            [sin(psi)  cos(psi) 0];
            [0         0        1]];
     
    R = Rphi*Rtheta*Rpsi;
    
    R = round(R.*threshold)/threshold;

    
    
    
    %% --------------------------------------------------------------------
    % Transforming coordinates to compensate for tool position
    % ---------------------------------------------------------------------
    
    tool = [x; y; z] + R*[0; -f-g; h];
    
    R67 = [[1 0 0]; 
           [0 0 -1];
           [0 1 0]];
       
    x_c = tool(1);
    y_c = tool(2);
    z_c = tool(3);
    % ---------------------------------------------------------------------

    %% --------------------------------------------------------------------
    % Computing theta 1 - 3
    % ---------------------------------------------------------------------
    
    % Compute theta1
    beta = atan2(y_c, x_c);
    del = b + d;
    r = sqrt(x_c^2 + y_c^2);
    length = sqrt(r^2 - (del)^2);
    alpha = atan2(del, length);
    Theta(1) = beta - alpha;
   
    % Compute theta3
    
    r_2 = x_c^2 + y_c^2 - del^2;
    s = z_c - a;
    D = (r_2 + s^2 - c^2 - e^2)/(2*c*e);
    Theta(3) = atan2(sqrt(1 - D^2), D);
    
    theta3_actual = Theta(3) - pi/2;
  
    % Compute theta2
    Theta(2) = atan2(z_c - a, sqrt(x_c^2 + y_c^2 - del^2)) - ...
               atan2(e*sin(Theta(3)), c + e*cos(Theta(3)));
   
    % Set theta3 to actual value
    Theta(3) = theta3_actual;
    
    %% --------------------------------------------------------------------
    % Computing theta 4 - 6
    % ---------------------------------------------------------------------
    
    disp(Theta(1))
    disp(Theta(2))
    disp(Theta(3))
    
    c1 = cos(Theta(1));
    s1 = sin(Theta(1));
    
    c2 = cos(Theta(2));
    s2 = sin(Theta(2));
    
    c3 = cos(Theta(3));
    s3 = sin(Theta(3));
    
    R01 = [
         [c1 -s1*cos(alpha1)  s1*sin(alpha1)];
         [s1  c1*cos(alpha1) -c1*sin(alpha1)];
         [0      sin(alpha1)     cos(alpha1)];
         ];
     
    R12 = [
         [c2 -s2*cos(alpha2)  s2*sin(alpha2)];
         [s2  c2*cos(alpha2) -c2*sin(alpha2)];
         [0      sin(alpha2)     cos(alpha2)];
         ];
     
    R23 = [
         [c3 -s3*cos(alpha3)  s3*sin(alpha3)];
         [s3  c3*cos(alpha3) -c3*sin(alpha3)];
         [0      sin(alpha3)     cos(alpha3)];
         ];
    
    R03 = R01*R12*R23;
    R03 = round(R03.*threshold)/threshold;
    
    R36 = (R03')*R*(R67');
    R36 = round(R36.*threshold)/threshold;
    
    Theta(5) = atan2(R36(3,3), sqrt(1 - (R36(3,3)^2)));
    
    if (R36(1,3) == 0 && R36(2,3) == 0)
        if (R36(3,3) == 1)
            Theta(4) = 0;
            Theta(6) = atan2(R36(2,1), R36(1,1));
            disp('R36 == 1');
        else
            Theta(4) = 0;
            Theta(6) = -atan2(-R36(1,2), -R36(1,1));
            disp('R36 ~= 1');
        end
    else
        Theta(4) = atan2(R36(2,3), R36(1,3));
        Theta(6) = atan2(R36(3,2), -R36(3,1));
    end
    
    theta1 = Theta(1);
    theta2 = Theta(2);
    theta3 = Theta(3);
    theta4 = Theta(4);
    theta5 = Theta(5);
    theta6 = Theta(6);
    
    
end