%% Joint Class. Holds all local joint properties

% Currently just assuming all joints are revolute, cause i'm a slacker
classdef joint < handle
    
    properties    
        position;
        theta;
        rotation_axis; %input vector preferably normalized of [x, y, z]
        first_draw;
        h;
        t;
    end
    
    methods       
        
        % Init
        function self = joint(position, rotation_axis, theta)
            self.position = position;
            self.rotation_axis = rotation_axis./norm(rotation_axis);
            self.theta = theta;
            self.first_draw = true;
        end
        
        % Rotation
        function rotate(self, new_theta)
            self.theta = new_theta;
        end
        
        % Draw
        function draw(self)                
            if (self.first_draw == true)
                ax = axes('XLim',[-2 1],'YLim',[-2 1],'ZLim',[-1 1]);
                view(3); grid on; axis equal
                set(gcf, 'Renderer', 'opengl')   
                % Draw Cylinder
                [X, Y, Z] = cylinder(0.5, 50);
                self.h = surface(X, Y, Z, 'FaceColor', 'white');
                self.t = hgtransform('Parent', ax);
                set(self.h, 'Parent', self.t)
                
                cylinder_axis = [0.0, 0.0, 1.0];
                %Orient Cylinder to be equal to rotation axis
                rotation_vector = cross(cylinder_axis, self.rotation_axis);
                OrientationRvec = makehgtform('axisrotate', rotation_vector, pi/2);
                %set(self.t, 'Matrix', Rvec);
                
                self.first_draw = false;
            end
            
            % Draw local axis arrow
            %{
            quiver3(self.position(1), self.position(2), self.position(3),         ...
                    self.rotation_axis(1),   ...
                    self.rotation_axis(2),   ...
                    self.rotation_axis(3),    ...
                    '--k');
            hold on
            %}
                     
            % Translate            
            Txyz = makehgtform('translate',         ...
                               [self.position(1),   ...
                                self.position(2),   ...
                                self.position(3)]);
            % Rotate
            Rvec = makehgtform('axisrotate', self.rotation_axis, self.theta);
                                        
            % Set transformation
            set(self.t, 'Matrix', Txyz*OrientationRvec*Rvec)                                     
            
            drawnow
        end
        
    end
    
end
        
            
    