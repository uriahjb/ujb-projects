%% Computes the forward kinematics for the PUMA260 robot

function t = puma_fk(q)

    %% Define the PUMA260's DH parameters:
    clear L
    L = [];
    L{1} = [ pi/2   0.0	   0	13.0 ]; 
    L{2} = [ 0.0    8.0	   0	-2.5 ];
    L{3} = [ -pi/2  0.0    0	-2.5 ];
    L{4} = [ pi/2   0.0	   0     8.0 ]; 
    L{5} = [ -pi/2  0.0    0     0.0 ];
    L{6} = [ 0.0    0.0    0    7.25 ];
 
    
    %% Define a few poses
    qz = [0, 0, 0, 0, -pi/2, pi]; % "zero" angled pose.
    
    %% Compute homogeneous forward kinematic transform.
    
    A = [];
    base = eye(4);
    t = base;
    
    for i = 1:length(L)     
        
        % 	L =LINK([alpha A theta D sigma])
        
        alpha_i = L{i}(1);
        A_i = L{i}(2);
        theta_i = L{i}(3) + q(i);       
        D_i = L{i}(4);
        
        A = [
            [cos(theta_i) -sin(theta_i)*cos(alpha_i) sin(theta_i)*sin(alpha_i)  A_i*cos(theta_i)];
            [sin(theta_i)  cos(theta_i)*cos(alpha_i) -cos(theta_i)*sin(alpha_i) A_i*sin(theta_i)];
            [0             sin(alpha_i)                         cos(alpha_i)    D_i             ];
            [0             0                         0                          1               ]
            ];
        
        t = t * A;
    end
    
end