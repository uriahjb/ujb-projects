% Copyright (c) 2010 ARM Ltd with some modification by Uriah Baalke
%  
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%  
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%  
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.
%
% <a href="matlab:help mbed.SerialRPC.SerialRPC">mbed.SerialRPC</a>

classdef UDPRPC < mbed.RPCConnection
    
    properties(SetAccess = private)
       UDP_IP;
       UDP_PORT;
       UDP_CON
    end
    
    methods
        function obj = UDPRPC(IP, PORT)
            % mbed.SerialRPC provides a RPC connection to an mbed over a serial connection.
            % 
            % Usage: 
            %  % Create a RPC connection
            %  mymbed = mbed.SerialRPC('COM3',9600);
            %
            %  % Pass the RPC object to the other interface objects
            %  ai = mbed.AnalogIn(mymbed, mbed.p15);
            %  di = mbed.DigitalIn(mymbed, mbed.p5); 
            %
            % Notes: 
            %  * For details on mbed RPC, see 
            %     http://mbed.org/cookbook/Interfacing-Using-RPC
            %     http://mbed.org/cookbook/Interfacing-with-Matlab

            if ~isnumeric(PORT)
                error('The Port name input must be numeric');
            end
            
            if PORT > (2^16),
                error('The Port name input argument must be less than %s', (2^16));
            end
            
            if ~ischar(IP),
                error('The baud rate must be a string. ie: 192.168.0.1');
            end
                                    
            % check whether serial port is currently in use by MATLAB            
            if ~isempty(instrfind({'RemotePort', 'RemoteHost'}, {PORT, IP}))                
                disp('Use instrreset ... or');
                disp(['  delete(instrfind({''RemotePort'', ''RemoteHost''},{''' PORT ''', ''' IP '''}))']);
                error(['UDP Com already used by MATLAB']);                
            end            
            
            obj.UDP_PORT = PORT;
            obj.UDP_IP = IP;            
            
            obj.UDP_CON = udp(obj.UDP_IP, ...
                             obj.UDP_PORT, ...
                             'localport', obj.UDP_PORT);            
            try
                fopen(obj.UDP_CON);
            catch ME,
                disp(ME.message)
                delete(obj);
                error(['Could not open udp connection: ' IP, PORT]);
            end
            %Send an empty message to get a response from the RPC
            %handler
            
            % Flush the input ... just in case
            while(obj.UDP_CON.BytesAvailable > 0)
                fread(obj.UDP_CON, 1);
            end
                        
            fprintf(obj.UDP_CON,'/ /','Async');
            pause(0.05);
            if obj.UDP_CON.BytesAvailable >1,
                res = fscanf(obj.UDP_CON);
                fprintf('Successfully connected to mbed\n');
                fprintf('Objects that can be created or used:\n  %s\n', res);
            else
                delete(obj)
                error('No response from mbed - check it is plugged in and you are using the correct serial port');
            end
        end

        function delete(obj)
           if isa(obj.UDP_CON,'serial') && isvalid(obj.UDP_CON),
                fclose(obj.UDP_CON);
           end
           if isobject(obj.UDP_CON),
                delete(obj.UDP_CON);
           end
        end
        
        function reset(obj)
            try
                serialbreak(obj.UDP_CON);
            catch ME
                disp(ME.Message);
                disp('Failed to send break command to reset mbed');
            end    
        end  
        
        function response = RPC(obj, name, method, args)
            %Executes an RPC command over serial. name and method are
            %strings. args must be a cell array of strings.
             if nargin > 1
                if nargin > 2
                    RPCString = ['/' name '/' method ' '];
                    if nargin > 3
                        %Add all the arguments
                        args(2,:) = {' '}; 
                        RPCString = [RPCString args{:}];
                    end
                else
                   RPCString = ['/' name];
                end
                %{
                disp(length(RPCString));           
                len = length(RPCString);
                chk = uint16(0);
                for c = 1:len
                    chk = chk + char(RPCString(c));
                    disp(chk);
                end
                chk_low = bitand(chk, 255);
                chk_high = bitshift(chk, -8);
                disp(chk_low);
                disp(chk_high);
                disp(strcat('rpc', char(len), num2str(RPCString)));
                RPC_out = strcat('rpc', char(len), num2str(RPCString)); 
                fprintf(obj.UDP_CON, RPC_out);
                %}
                % if Response is of type:  'new or 'read' then get the 
                %   response, otherwise don't bother, it consumes too 
                %   much time
                
                disp(method);                
                if ~isempty(strfind(method, 'new')) || ...
                   ~isempty(strfind(method, 'read'))
                    response = '';
                    while(isempty(response) || (~isempty(strfind(response, 'Serial'))))                        
                        fprintf(obj.UDP_CON, RPCString);
                        response = fgetl(obj.UDP_CON);
                    end
                else
                    fprintf(obj.UDP_CON, RPCString);
                    response = '';
                end
            else
                error('You must pass some commands into the RPC function');
            end
        end
        
        function disp(obj)
            fprintf('<a href="matlab:help mbed.UDPRPC.UDPRPC">mbed.UDPRPC</a>\n');
            if isvalid(obj)
                fprintf('  UDP port: %s\n', obj.UDP_IP, obj.UDP_PORT);
            else
                fprintf('This object has been deleted and is no longer valid\n');
            end            
        end
        
    end
end
   
