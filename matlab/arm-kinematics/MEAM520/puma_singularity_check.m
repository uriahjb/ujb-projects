function J = puma_singularity_check(t1, t2, t3, t4, t5, t6)
    
    %% --------------------------------------------------------------------
    % Forward kinematics R06 symbolic-----------------------
    % using sybolic manipulation and then later using values from ik
    % solution thetas..
    %----------------------------------------------------------------------
    
    syms t1 t2 t3 t4 t5 t6 a b c d e f
    %a=13; b=2.5; c=8; d=2.5; e=8; f=2.5; % length parameters
    a_dis = [0 c 0 0 0 0];
    alpha = [pi/2 0 -pi/2 pi/2 pi/2 0];
    dis = [a -b -d e 0 f];
    theta = [t1,t2,t3,t4,t5+pi/2,t6];

    for k = 1:length(theta)

        A{k} = [cos(theta(k)), -sin(theta(k))*cos(alpha(k)), sin(theta(k))*sin(alpha(k)), a_dis(k)*cos(theta(k)); 
        sin(theta(k)), cos(theta(k))*cos(alpha(k)), -cos(theta(k))*sin(alpha(k)), a_dis(k)*sin(theta(k));
        0, sin(alpha(k)), cos(alpha(k)), dis(k);
        0, 0, 0, 1];
    end

    R06 = A{1,1}*A{1,2}*A{1,3}*A{1,4}*A{1,5}*A{1,6};

    %% --------------------------------------------------------------------
    % Finding the Jacobian
    % using epos which is end effector position above..
    % ---------------------------------------------------------------------
    
    D06 = [R06(1:3,4)];
    %a=13; b=2.5; c=8; d=2.5; e=8; f=2.5; % length parameters
    J = jacobian(D06, [a b c d e f]);
    %a = 13; b = 2.5; c = 8; d = 2.5; e = 8; f = 2.5; % length parameters used below
    J = subs(J,[t1 t2 t3 t4 t5 t6],[pi/2 0 0 0 0 0]);

end
