%%  A function with the purpose of plotting the PUMA260 arm
%{  
  Drawing is a pretty complicated task, so puma_viz uses a function to 
    define what the robot is like, using a function handle, called:

  - create_puma

  And another function to animate the robot called, not surprisingly

  - animate_puma
%}

%% puma_viz
function puma_viz(robot, varargin)
    
    if (size(varargin) == 1)
        q = varargin{1};
    else
        q = robot.qz;
    end    

    if exist('puma260')        
        if robot.plot.created
            % Check if there is an existing figure ... this need to be
            % refined
            if findobj('Type', 'figure')
                animate_puma(robot, q);
            else
                robot.plot.created = false;
            end
        end
        
        if not (robot.plot.created)
            create_puma(robot);     
            robot.plot.created = true;
            animate_puma(robot, q);         
        end
    
    else
        disp('Instantiate robot obj')
    end
end