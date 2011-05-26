% Copyright (c) 2010 ARM Ltd
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

classdef SerialRPC < mbed.RPCConnection
    
    properties(SetAccess = private)
       SerialCon;
       TIMEOUT = 5;
       PortName = 'COM5';
       BaudRate = 9600;
    end
    
    methods
        function obj = SerialRPC(Port, baud)
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

            if ~ischar(Port),
                error('The Port name input argument must be a string, e.g. ''COM8'' ');
            end
            if ~isnumeric(baud),
                error('The baud rate must be a numeric value');
            end
                                    
            % check whether serial port is currently in use by MATLAB
            if ~isempty(instrfind({'Port'},{Port})),
                disp(['The Port you have chosen is already in use by MATLAB. If you are sure that mbed is connected to ' Port]);
                disp('then delete the object to disconnect and execute:');
                disp(['  delete(instrfind({''Port''},{''' Port '''}))']);
                disp('to delete the port before attempting another connection');
                error(['Port ' Port ' already used by MATLAB']);
            end
            
            obj.PortName = Port;
            obj.BaudRate = baud;
            
            obj.SerialCon = serial(obj.PortName, ...
                'BaudRate', obj.BaudRate , ...
                'Parity', 'none', ...
                'DataBits', 8, ...
                'StopBits', 1);
            
            set(obj.SerialCon,'Timeout',obj.TIMEOUT);
            try
                fopen(obj.SerialCon);
            catch ME,
                disp(ME.message)
                delete(obj);
                error(['Could not open port: ' Port]);
            end
            %Send an empety message to get a response from the RPC
            %handler
            fprintf(obj.SerialCon,'/ /','Async');
            pause(0.05);
            if obj.SerialCon.BytesAvailable >1,
                res = fscanf(obj.SerialCon);
                fprintf('Successfully connected to mbed\n');
                fprintf('Objects that can be created or used:\n  %s\n', res);
            else
                delete(obj)
                error('No response from mbed - check it is plugged in and you are using the correct serial port');
            end
        end

        function delete(obj)
           if isa(obj.SerialCon,'serial') && isvalid(obj.SerialCon),
                fclose(obj.SerialCon);
           end
           if isobject(obj.SerialCon),
                delete(obj.SerialCon);
           end
        end
        
        function reset(obj)
            try
                serialbreak(obj.SerialCon);
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
                fprintf(obj.SerialCon, RPCString,'Async');
                response = fgetl(obj.SerialCon);
            else
                error('You must pass some commands into the RPC function');
            end
        end
        
        function disp(obj)
            fprintf('<a href="matlab:help mbed.SerialRPC.SerialRPC">mbed.SerialRPC</a>\n');
            if isvalid(obj)
                fprintf('  Serial port: %s\n', obj.PortName);
            else
                fprintf('This object has been deleted and is no longer valid\n');
            end            
        end
        
    end
end
   
