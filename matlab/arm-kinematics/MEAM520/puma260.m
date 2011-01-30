%% PUMA260 Class
%{
    Contains all properties and methods needed for the following:
        - forward kinematics
        - drawing
        - animation
        - etc
%}

classdef puma260 < handle
    properties
        L
        plot
        qz
        h
  
    end
  
    methods
        %% Initialize PUMA260 Properties and Figure
        function self = puma260()
        clear self.L
        self.L = [];
        self.L{1} = [ pi/2   0.0	   0	13.0 ]; 
        self.L{2} = [ 0.0    8.0	   0	-2.5 ];
        self.L{3} = [ -pi/2  0.0    0	-2.5 ];
        self.L{4} = [ pi/2   0.0	   0     8.0 ]; 
        self.L{5} = [ -pi/2  0.0    0     0.0 ];
        self.L{6} = [ 0.0    0.0    0    7.25 ];
     
        self.qz = [0, 0, 0, 0, -pi/2, pi]; % "zero" angled pose.
    
        self.plot.created = false; % Is there a plot ... n: deprecated
        self.plot.framerate = 30; % In fps
        
        self.h;
        
        init_draw(self)
        draw(self, self.qz)
    
        end
        
        %% Initialize Figure
        function self = init_draw(self)
            
            % Close current figure for reliability
            close all
            
            L = self.L;

            % Get maximum reach of for axis definition
            reach = 0;
            for i = 1:length(L)      
                %alpha_i = L{i}(1);
                A_i = L{i}(2);
                %theta_i = L{i}(3) + q(i);       
                D_i = L{i}(4);

                reach = reach + abs(A_i) + abs(D_i);      
            end

            h.dimensions = [-reach reach -reach reach 0.0 reach];
            h.magnitude = reach/10;

            if ~ishold,  
                % if current figure has hold on, then draw robot here
                % otherwise, create a new figure
                axis(h.dimensions);
            end
            xlabel('X')
            ylabel('Y')
            zlabel('Z')
            set(gca, 'drawmode', 'fast');
            grid on

            % Get zlimitations
            zlim = get(gca, 'Zlim');
            h.zmin = zlim(1);

            % Draw a line that will then be modified to draw the entire robot
            h.robot = line('Color', 'black', ...
                           'Linewidth', 4, ...
                           'erasemode', 'xor');

            % Add a shadow because its cool
            h.shadow = line('Color', [.8 .8 .8], ...
                            'Linewidth', 5, ...
                            'erasemode', 'xor');

            % Display cylinders for each joint and axis center line
            for i = 1:length(L)

                [xc, yc, zc] = cylinder(h.magnitude/4, 8);
                zc(zc==0) = -h.magnitude/2;
                zc(zc==1) = h.magnitude/2;

                % Add surface and color it
                h.joint(i) = surface(xc, yc, zc);
                set(h.joint(i), 'Facecolor', 'blue');

                % Build matrix of coordinates for transformations
                %  in animate_puma
                xyz = [xc(:)'; yc(:)'; zc(:)'; ones(1, 2*8+2)];
                set(h.joint(i), 'UserData', xyz);

                % Add dashed line along joint axis
                h.jointaxis(i) = line('xdata', [0; 0], ...
                                      'ydata', [0; 0], ...
                                      'zdata', [0; 0], ...
                                      'color', 'black', ...
                                      'linestyle', '--', ...
                                      'erasemode', 'xor');
            end
            
            self.h = h;        
        end
        
        %% Draw self with given joint theta definition
        function self = draw(self, q)
            
            % If the figure was closed, then make sure to make a new one
            % Still need to find a way to check if the figure is right
            if (findobj('Type', 'figure') == 1)
            else
                init_draw(self)
            end
            
            h = self.h;
            L = self.L;
            magnitude = h.magnitude;

            % Assuming that the base of the robot is at [0, 0, 0]
            x = 0;
            y = 0;
            z = 0;

            xs = 0;
            ys = 0;
            zs = h.zmin;

            % Compute link transforms ... like puma_fk and record origin 
            %  of each frame
            A = [];
            base = eye(4);
            t = base;
            Tn = t;
            for i = 1:length(L)

                Tn(:,:,i) = t;

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

                x = [x; t(1,4)];
                y = [y; t(2,4)];
                z = [z; t(3,4)];
                xs = [xs; t(1,4)];
                ys = [ys; t(2,4)];        
                zs = [zeros(length(zs),1); 0.0];
            end

            % Draw robot stick figure
            set(h.robot,'xdata', x, 'ydata', y, 'zdata', z);

            % Draw robot shadow
            set(h.shadow,'xdata', xs, 'ydata', ys, 'zdata', zs);	

            % Draw joints and joint axis
            xyz_line = [0 0; 0 0; -2*magnitude 2*magnitude; 1 1];

            for i = 1:length(L),
              % Get coordinate data 
              xyz = get(h.joint(i), 'UserData');
              xyz = Tn(:,:,i) * xyz;
              [~, c] = size(xyz);
              number_columns = c/2;
              xc = reshape(xyz(1,:), 2, number_columns);
              yc = reshape(xyz(2,:), 2, number_columns);
              zc = reshape(xyz(3,:), 2, number_columns);

              set(h.joint(i), 'Xdata', xc, ...
                              'Ydata', yc, ...
                              'Zdata', zc);

              xyzl = Tn(:,:,i) * xyz_line;
              set(h.jointaxis(i), 'Xdata', xyzl(1,:), ...
                                  'Ydata', xyzl(2,:), ...
                                  'Zdata', xyzl(3,:));
            end

            % And finally draw everything
            drawnow
        end
        
        %% Animate for a set number of theta definitions
        function self = animate(self, frames)
            
            wait = (1/self.plot.framerate);
            
            for frame = 1:length(frames)
                draw(self, frames(frame,:));
                pause(wait);
            end
        end
        
        %% Compute homogeneous forward kinematic transform.
        function self = fk(self, q)

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
    
    end
end
