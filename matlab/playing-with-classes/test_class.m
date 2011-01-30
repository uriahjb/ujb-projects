%% Playing around with classes. Gotta figure out this stuff.

% This is pretty cool. Can instantiate and draw a sphere
classdef test_class
    
    properties
        x;
        y;
        z;
        n;
        X;
        Y;
        Z;
        
    end
    
    methods
        
        function self = test_class(x, y, z, n)
            self.x = x;
            self.y = y;
            self.z = z;
            self.n = n;
            [self.X, self.Y, self.Z] = sphere(self.n);
            self.X = self.X + self.x;
            self.Y = self.Y + self.y;
            self.Z = self.Z + self.z;
            
        end
        
        function print(self)
            disp(' ')
            disp(self.x)
            disp(self.y)
            disp(self.z)
            disp(self.n)
        end
        
        function draw(self)
            hold on 
            axis equal
            surf(self.X, self.Y, self.Z)
            daspect([1 1 1])
        end
        
    end
    
end