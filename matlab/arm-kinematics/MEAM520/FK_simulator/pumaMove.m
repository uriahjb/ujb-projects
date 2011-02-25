function [ ] = pumaMove( th1,th2,th3,th4,th5,th6 )
%PUMAPOS MOves the PUMA to the new configuration specified by the input (inradians)
%parameters. This function does not have the "change in joint angle" limits and
%timestep constraints that the pumaServo function has.
%   INPUTS:
%    th1...th6 : Joint variables for the six DOF PUMA arm
%
    if(nargin ~=6)
        error('Number of inputs must be equal to 6');
    end
    
    if(~evalin('base','exist(''puma'',''var'')'))
            error('PUMA has not been initialised. Run puma260.m first');
    end 
%% Joint Limits
    th = [th1 th2 th3 th4 th5 th6];
    lowlim = [-180 -75 -235 -580 -30 -215]; % LOwer limits of joints
    uplim  = [110 240 60 40 200 295]; % Upper limits of joints
    if(sum((th<(pi/180)*(lowlim))+(th>(pi/180)*(uplim)))~=0)
        error('Joint limits exceeded. Check input angles');
    end
%% CHanges the PUMA config to that specified by input and plots it there
    global puma;   
    plotrobot(puma,th);
%% Forward Kinematics to find end-effector and joint positions    
    n = puma.n;
    tran = puma.base;
    L = puma.link;
    pos = zeros(6,3); % 6 joints and [x,y,z] positions for each
    for i=1:n,
        tran = tran * L{i}(th(i));
        pos(i,:) = tran(1:3,4); % position of end of each joint
    end
	tran = tran * puma.tool;
    epos = tran(1:3,4); % end-effector position;
    disp(epos)
    %% Workspace limits - X has to be > -6 inches and Z has to be > 2 inches
    if(epos(1) < -6*0.0254 || epos(3) < 2*0.0254) 
        error('Workspace limits exceeded at the end-effector. Check the input angles');
    end
    
    if(pos(4,1) < -6*0.0254 || pos(4,3) < 2*0.0254) 
        error('Workspace limits exceeded at the wrist. Check the input angles');
    end
    %% plots the led at the end of the arm
    col = puma.ledcol;
    if(sum(abs(col))~=0)
        hold on;
        plot3(epos(1),epos(2),epos(3),'*','Color',[col(1) col(2) col(3)]);
    end
    
end

