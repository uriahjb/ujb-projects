%% PUMA260 Class
%{
    Contains all properties and methods needed for the following:
        - forward kinematics
        - drawing (arm, pathlines, point-clouds)
        - animation
        - etc
%}

classdef puma260 < handle
    properties
        L
        lim
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
        self.L{2} = [ 0.0    8.0	   0	-3.5 ];
        self.L{3} = [ -pi/2  0.0       0	-3.0 ];
        self.L{4} = [ pi/2   0.0	   0     8.0 ]; 
        self.L{5} = [ -pi/2  0.0       0     0.0 ];
        self.L{6} = [ 0.0    0.0       0     2.5 ];
     
        % Angle Limits: format: [lower upper]
        self.lim.theta{1} = [-(pi/2)        (pi/2)];
        self.lim.theta{2} = [-((4*pi)/9)    (pi/3)];
        self.lim.theta{3} = [-((23*pi)/18)  ((5*pi)/18)];
        self.lim.theta{4} = [-((10*pi)/9)   ((37*pi)/18)];
        self.lim.theta{5} = [-((5*pi)/36)   ((10*pi)/9)];
        self.lim.theta{6} = [-((13*pi)/9)   ((13*pi)/2)];
        
        self.qz = [0, 0, 0, 0, -pi/2, pi]; % "zero" angled pose.
    
        self.plot.created = false; % Is there a plot ... n: deprecated
        self.plot.framerate = 30; % In fps
        self.plot.draw_pathline = false;
        self.plot.draw_points = false;
        
        self.h;
        
        init_draw(self)
        draw(self, self.qz)
    
        end
        
        %% Reset PUMA260 to initial configuration ... kinda
        function self = reset(self)
           self.plot.draw_pathline = false;
           self.plot.draw_points = false;
           
           reset(self.h.pathline);
           
           draw(self, self.qz)
           
            
        end
        
        %% Initialize Figure
        function self = init_draw(self)
            
            % Close current figure for reliability and what-not
            close all
            
            L = self.L;

            %% Get maximum reach of for axis definition
            reach = 0;
            for i = 1:length(L)      
                %alpha_i = L{i}(1);
                A_i = L{i}(2);
                %theta_i = L{i}(3) + q(i);       
                D_i = L{i}(4);

                reach = reach + abs(A_i) + abs(D_i);      
            end

            self.h.dimensions = [-reach reach -reach reach 0.0 reach];
            self.h.magnitude = reach/10;

            if ~ishold,  
                % if current figure has hold on, then draw robot here
                % otherwise, create a new figure
                axis(self.h.dimensions);
            end
            xlabel('X')
            ylabel('Y')
            zlabel('Z')
            set(gca, 'drawmode', 'fast');
            grid on

            %% Get zlimitations
            zlim = get(gca, 'Zlim');
            self.h.zmin = zlim(1);

            %% Draw a line that will then be modified to draw the entire robot
            self.h.robot = line('Color', 'black', ...
                                'Linewidth', 4, ...
                                'erasemode', 'xor');

            %% Add a shadow because its cool
            self.h.shadow = line('Color', [.8 .8 .8], ...
                                 'Linewidth', 5, ...
                                 'erasemode', 'xor');

            %% Add cylinders for each joint and axis center line
            for i = 1:length(L)

                [xc, yc, zc] = cylinder(self.h.magnitude/4, 8);
                zc(zc==0) = -self.h.magnitude/2;
                zc(zc==1) = self.h.magnitude/2;

                % Add surface and color it
                self.h.joint(i) = surface(xc, yc, zc);
                set(self.h.joint(i), 'FaceColor','blue','EdgeColor','none');

                % Build matrix of coordinates for transformations
                %  in animate_puma
                xyz = [xc(:)'; yc(:)'; zc(:)'; ones(1, 2*8+2)];
                set(self.h.joint(i), 'UserData', xyz);

                % Add dashed line along joint axis
                self.h.jointaxis(i) = line('xdata', [0; 0], ...
                                           'ydata', [0; 0], ...
                                           'zdata', [0; 0], ...
                                           'color', 'black', ...
                                           'linestyle', '--', ...
                                           'erasemode', 'xor');
            end
            
            %% Add in xyz axis for end effector
            self.h.xe = line('xdata', [0; 0], ...
                             'ydata', [0; 0], ...
                             'zdata', [0; 0], ...
                             'color', 'blue', ...
                             'linestyle', '--', ...
                             'erasemode', 'xor');
            
            self.h.ye = line('xdata', [0; 0], ...
                             'ydata', [0; 0], ...
                             'zdata', [0; 0], ...
                             'color', 'blue', ...
                             'linestyle', '--', ...
                             'erasemode', 'xor');
                    
            self.h.ze = line('xdata', [0; 0], ...
                             'ydata', [0; 0], ...
                             'zdata', [0; 0], ...
                             'color', 'blue', ...
                             'linestyle', '-', ...
                             'erasemode', 'xor');
                    
            self.h.xet = text(0, 0, 'x', 'erasemode', 'xor');
            self.h.yet = text(0, 0, 'y', 'erasemode', 'xor');
            self.h.zet = text(0, 0, 'z', 'erasemode', 'xor');
            
            %% Add in a end-effector path-line 'cause its rad
            self.h.pathline = line('Color', 'black', ...
                                   'Linewidth', 2, ...
                                   'linestyle', '--', ...
                                   'erasemode', 'xor');
                
        end
        
        %% Draw self with given joint theta definition
        function self = draw(self, q)
            
            % If the figure was closed, then make sure to make a new one
            % Still need to find a way to check if the figure is right
            if (findobj('Type', 'figure') == 1)
            else
                init_draw(self)
            end
            
            L = self.L;
            magnitude = self.h.magnitude;

            % Assuming that the base of the robot is at [0, 0, 0]
            x = 0;
            y = 0;
            z = 0;

            xs = 0;
            ys = 0;
            zs = self.h.zmin;

            %% Compute link transforms ... like puma_fk and record origin 
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

            %% Draw robot stick figure
            set(self.h.robot,'xdata', x, 'ydata', y, 'zdata', z);

            %% Draw robot shadow
            set(self.h.shadow,'xdata', xs, 'ydata', ys, 'zdata', zs);	

            %% Draw joints and joint axis
            xyz_line = [0 0; 0 0; -2*magnitude 2*magnitude; 1 1];
          
            for i = 1:length(L),
              % Get coordinate data 
              xyz = get(self.h.joint(i), 'UserData');
              xyz = Tn(:,:,i) * xyz;
              [~, c] = size(xyz);
              number_columns = c/2;
              xc = reshape(xyz(1,:), 2, number_columns);
              yc = reshape(xyz(2,:), 2, number_columns);
              zc = reshape(xyz(3,:), 2, number_columns);

              set(self.h.joint(i), 'Xdata', xc, ...
                                   'Ydata', yc, ...
                                   'Zdata', zc);

              xyzl = Tn(:,:,i) * xyz_line;
              set(self.h.jointaxis(i), 'Xdata', xyzl(1,:), ...
                                       'Ydata', xyzl(2,:), ...
                                       'Zdata', xyzl(3,:));
            end
            
            %% Update xyz axis for end effector
            
            xx = t*[magnitude; 0; 0; 1];
            yy = t*[0; magnitude; 0; 1];
            zz = t*[0; 0; magnitude; 1];
            
            set(self.h.xe, 'xdata', [t(1,4) xx(1)], ...
                           'ydata', [t(2,4) xx(2)], ...
                           'zdata', [t(3,4) xx(3)]);
                  
            set(self.h.ye, 'xdata', [t(1,4) yy(1)], ...
                           'ydata', [t(2,4) yy(2)], ...
                           'zdata', [t(3,4) yy(3)]);      
                  
            set(self.h.ze, 'xdata', [t(1,4) zz(1)], ...
                           'ydata', [t(2,4) zz(2)], ...
                           'zdata', [t(3,4) zz(3)]);
                  
            set(self.h.xet, 'Position', xx(1:3));
            set(self.h.yet, 'Position', yy(1:3));
            set(self.h.zet, 'Position', zz(1:3));
            
            %% If pathline option on, draw pathline otherwise clear it.
            %  Turning on points, removes the line and replaces it by
            %  points
            
            if (self.plot.draw_pathline)
              self.h.pathline_x = [self.h.pathline_x; t(1,4)];
              self.h.pathline_y = [self.h.pathline_y; t(2,4)];
              self.h.pathline_z = [self.h.pathline_z; t(3,4)];
                     
              set(self.h.pathline, 'xdata', self.h.pathline_x, ...
                                   'ydata', self.h.pathline_y, ...
                                   'zdata', self.h.pathline_z, ...
                                   'linewidth', 2, ...
                                   'linestyle', '--', ...
                                   'marker', 'none');
            
            elseif (self.plot.draw_points)
                
                self.h.pathline_x = [self.h.pathline_x; t(1,4)];
                self.h.pathline_y = [self.h.pathline_y; t(2,4)];
                self.h.pathline_z = [self.h.pathline_z; t(3,4)];

                set(self.h.pathline, 'xdata', self.h.pathline_x, ...
                                     'ydata', self.h.pathline_y, ...
                                     'zdata', self.h.pathline_z, ...
                                     'linewidth', 1, ...
                                     'linestyle', 'none', ... 
                                     'marker', '.', ...
                                    'markerfacecolor', 'black');

          
            
            else
                self.h.pathline_x = [];
                self.h.pathline_y = [];
                self.h.pathline_z = [];
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
        function [self, t] = fk(self, q)

            self.draw(q)
            
            L = self.L;
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
        
        %% Check for valid angle limits
        function inbounds = check_lim(self, q)
            for i = 1:length(self.L)
                if (q(i) < self.lim.theta{i}(1)) || (q(i) > self.lim.theta{i}(2))
                  inbounds = false;
                  return;
                end
            end
            inbounds = true;
            return
        end
        
        %% Some cool demos
        function self = demo_workspace(self, num_frames)
            
            self.plot.draw_points = true;            
            
            frames = [];
            theta1 = -pi*rand(1,1);
            theta2 = -pi*rand(1,1);
            theta3 = -pi*rand(1,1);
            theta4 = -pi*rand(1,1);
            theta5 = -pi*rand(1,1);
            
            gain1 = 5*rand(1,1);
            gain2 = 5*rand(1,1);
            gain3 = 5*rand(1,1);
            gain4 = 5*rand(1,1);
            gain5 = 5*rand(1,1);
            
            for i = 1:num_frames
                scale = 2*pi;
                theta1 = theta1 + gain1*scale/100;
                theta2 = theta2 + gain2*scale/100;
                theta3 = theta3 + gain3*scale/100;
                theta4 = theta4 + gain4*scale/100;
                theta5 = theta5 + gain5*scale/100;
                frames{i} = [theta1 theta2 theta3 theta4 0 0];
            end
            
            for frame = 1:length(frames)
                
                draw(self, frames{frame});
                %pause(wait);
            end
            
            self.plot.valid_point = true;
            self.plot.draw_points = false;
            
        end
        
        %% Draw a cool spiral
        function self = demo_spiral(self, t1, t2, t3, dt1, dt2, dt3, len)
            
            %i like:
            %     p.demo_spiral(0, pi/2, -pi/2, -0.1, -0.002, 0, 100)
            %     p.demo_spiral(0, pi/2, -pi/2, -0.1, -0.003, 0.004, 100)
            
            
            self.plot.draw_pathline = true;
            
            frames = [];                                   
            
            for i = 1:len
                scale = 2*pi;
                t1 = t1 + dt1*scale;
                t2 = t2 + dt2*scale;
                t3 = t3 + dt3*scale;
                
                frames{i} = [t1 t2 t3 0 0 0];
            end
            
            for frame = 1:length(frames)
                
                draw(self, frames{frame});
                %pause(wait);
            end
            
            self.plot.valid_point = true;
            self.plot.draw_points = false;
        
        end
        %% Oscillate and draw cool arcs
        function self = demo_oscillate(self, t1, t2, t3, dt1, dt2, dt3, len)
            
            %i like:
            %     p.demo_oscillate(0, pi/2, -pi/4, -0.1, 0.03, -0.01, 100)            
            %     p.demo_oscillate(0, pi/2, -pi/2, -0.1, 0.005, -0.0, 100)
            
            
            self.plot.draw_pathline = true;
            
            frames = [];                                   
            
            for i = 1:len
                scale = 2*pi;
                t1 = t1 + dt1*scale;
                t2 = t2 + dt2*scale;
                t3 = t3 + dt3*scale;
                                
                
                frames{i} = [sin(t1) sin(t2) sin(t3) 0 0 0];
            end
            
                        
            for frame = 1:length(frames)
                
                draw(self, frames{frame});
                %pause(wait);
            end
            
            self.plot.valid_point = true;
            self.plot.draw_points = false;
        
        end
            
            
            
    end
end

%r = a + (b-a).*rand(100,1);