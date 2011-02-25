function [] = pumaServo(th1,th2,th3,th4,th5,th6)
% Commands the PUMA to the angles defined by the input (in radians)
% Has a change in joint angle limit of 5 degrees between successive calls
% Also, the function cannot be called successively without a gap of 100 ms
%
% INPUTS:
%   th1...th6 : Joint variables for the six DOF PUMA arm
% OUTPUT:
%   Calls Pumamove.m and displays the PUMA in the configuration specified by 
%   the input parameters
    
    if(~evalin('base','exist(''puma'',''var'')'))
        error('PUMA has not been initialised. Run puma260.m first');
    end
%% Time between calls limit    
    global time_prev;
    if(isempty(time_prev))
        t1 = clock;
        time_prev = t1(6);
    else
        t2 = clock;
        time_cur = t2(6);
        if((abs(time_prev - time_cur)) < 0.025)
            error('Time between two calls of pumaServo is less than 100 ms');
        end
        time_prev = time_cur;
    end
%% Delta angle limit    
    global puma;
    q = plotrobot(puma);
    th = [th1 th2 th3 th4 th5 th6];
    if(max(abs(q-th)) > 5*pi/180)
        error('Successive angle inputs are more than 5 degrees apart');
    end
    
    pumaMove(th1,th2,th3,th4,th5,th6);

end

