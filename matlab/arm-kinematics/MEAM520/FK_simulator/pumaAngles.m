function [q] = pumaAngles()
% Returns the current Joint angles of the PUMA
% OUTPUT:
%   q - an array of joint angles corresponding to the robot's current configuration
%
    if(~evalin('base','exist(''puma'',''var'')'))
            disp('Error: PUMA has not been initialised. Run puma260.m first');
            return;
    end
    
    global puma;
    q = plotrobot(puma);
    %[t1,t2,t3,t4,t5,t6] = deal(q(1),q(2),q(3),q(4),q(5),q(6));
end
