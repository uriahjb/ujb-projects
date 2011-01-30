%% Define the PUMA260's DH parameters:
classdef puma260 < handle
    properties
    L
    plot
    qz
    h
  
    end
  
    methods
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
    
        self.plot.created = false;
        
        self.h;
    
        end
    end
end
    