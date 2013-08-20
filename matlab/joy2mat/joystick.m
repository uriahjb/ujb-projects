%{

  The matlab joystick input. Reads in custom formatted pygame
  event strings and provides a joystick object that outputs
  joystick event structs

  Currently the user must call python joy2mat.py manually ... the default
  frequency is 10 Hz

    - Uriah Baalke
%}
classdef joystick < handle
    
    % Declare properties
    properties (SetAccess = public)
        sock;
        port;
        joy_num;
        evnt_str;
    end
    methods
        function self = joystick( port )
            % Initialize joystick selfect with optional port
            % INPUTS:
            %    port -- int -- defaults to joy2mat default port
            if nargin < 1            
                self.port = 65001;                                              
            end
            self.sock = udp('', self.port, 'localport', self.port);
            self.sock.ReadAsyncMode = 'continuous';
            self.sock.InputBufferSize = 1024;          
            self.sock.Timeout = 0.0005;
            fopen(self.sock);         
            
            % This warning is annoying            
            warning('off', 'instrument:fread:unsuccessfulRead');
            % This is probably a useful warning, but still annoying
            warning('off', 'MATLAB:catenate:DimensionMismatch'); 
        end
        
        function close( self )
            % Close the udp object so we don't break things
            fclose(self.sock);
            delete(self.sock);
        end            
        
        function evnt = parse( self, evnt_str )
            % Parse out a struct representation of the current joystick
            % event from input array            
            if evnt_str(1) == 1
                evnt.type = 'axis';
            elseif evnt_str(1) == 2
                evnt.type = 'ball' ;             
            elseif evnt_str(1) == 3
                evnt.type = 'button';                
            elseif evnt_str(1) == 4
                evnt.type = 'hat';
            end
            num = num2str(evnt_str(2));
            evnt.type = [evnt.type num];            
            evnt.value = typecast(uint8(evnt_str(3:6)), 'single');            
        end
        
        function evnt = pull( self )
            % Pull in data from the joystick, returns a struct describing
            % a single joystick event, either for a axis, button, ball, 
            % or hat
            evnt = {}; 
            remaining = 6-length(self.evnt_str);
            if remaining > 0
                self.evnt_str = [self.evnt_str; fread(self.sock, remaining)];
            end
            if length(self.evnt_str) < 6
                return
            end                
            if isempty(self.evnt_str)
                return
            end            
            evnt = self.parse( self.evnt_str );
            self.evnt_str = [];
        end
        
        function evnts = pullall( self )
            % Pull all of the most current types of events from 
            % the buffer
            evnts = {};
            while self.sock.BytesAvailable
                evnt = self.pull();
                if isempty(evnt)
                    continue
                end
                evnts.(evnt.type) = evnt.value;                    
            end
        end                
    end
end

            
                
            
            
            
            
            
