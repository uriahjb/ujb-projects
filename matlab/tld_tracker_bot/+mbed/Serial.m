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
% <a href="matlab:help mbed.Serial.Serial">mbed.Serial</a>

classdef Serial < handle
    properties (SetAccess = private)
        thismbed
        name
    end
    methods
        function obj = Serial(mbed, transmitPin, recvPin)
            % mbed.Serial allows you to create an Serial object 
            % on the mbed and access its methods using RPC.
            % 
            % Usage: 
            %  % Create a RPC connection
            %  mymbed = mbed.SerialRPC('COM3',9600);
            %
            %  % Create the object on the mbed with pin 9 as transmit (tx)  
            %  % pin and pin 10 as the receive (rx) pin 
            %  obj = mbed.Serial(mymbed, mbed.p9, mbed.p10); 
            %  obj = mbed.Serial(mymbed, 'myObj'); % tie to existing 'myObj' object on mbed
            %
            %  % view the list of methods
            %  obj
            %
            %  % invoke a method 
            %  obj.baud(9600);      % specify the baud rate
            %  obj.putc('c');       % send a single character 
            %  val = obj.getc();    % receive a character
            %  obj.puts('hello');   % send a string 
            %
            % Notes: 
            %  * Only the following pairs of pins are allows for serial I/O:
            %      pins 9  (tx) and 10 (rx)
            %      pins 13 (tx) and 14 (rx)
            %      pins 28 (tx) and 27 (rx)            
            %  * See http://mbed.org/handbook/Serial
            
            threeArgs = (nargin == 3) && isa(mbed, 'mbed.RPCConnection') ...
                        && isa(transmitPin,'mbed.PinName') ...
                        && isa(recvPin,'mbed.PinName');
            twoArgs = (nargin == 2) && isa(mbed, 'mbed.RPCConnection') ...
                        && ischar(transmitPin);
                    
            if ~(threeArgs || twoArgs)
                nl = sprintf('\n');
                msg = [' Expecting three or two parameters, e.g.:' nl ...
                       '  mymbed = mbed.SerialRPC(''COM3'',9600);' nl ...
                       '  ser = mbed.Serial(mymbed, mbed.p9, mbed.p10); % TX pin, RX pin' nl ...
                       '     or   '  nl ...
                       '  ser = mbed.Serial(mymbed, ''myObj'');'];
                error(msg);
            end
                        
            % Create a Serial port, connected to the specified transmit and receive pins
            obj.thismbed = mbed;
            if threeArgs
                %Create a new instance
                pins = [transmitPin.no recvPin.no];
                if ~(all(pins == [9 10]) || all(pins == [13 14]) || all(pins == [28 27]))
                    error('Only pin pairs 9/10, 13/14, or 28/27 are allowed for Serial');
                end  
                
                obj.name = obj.thismbed.RPC('Serial', 'new', {transmitPin.name, recvPin.name});
                disp('Created new Serial on mbed');
            elseif twoArgs
                %This is a tie command
                obj.name = transmitPin;
                disp('Tied MATLAB to existing Serial on mbed');
            end
            
            % delete this object when thismbed is deleted
            addlistener(obj.thismbed, 'ObjectBeingDestroyed', @(h,e) delete(obj));             
        end
 
        function puts(obj, str)
            % puts           mbed.Serial method
            %   obj.puts(strToSend) writes a string to the serial port. A
            %   final newline is added automatically. Use PUTC to write a 
            %   single character

            validateattributes(str,{'char'},{'nonempty'});
            for i = 1:numel(str)               
                 obj.thismbed.RPC(obj.name, 'putc', { sprintf('%d', str(i))} );
            end
            obj.thismbed.RPC(obj.name, 'putc', {'10'} );  % send new line
        end
        
        function str = gets(obj)
            % gets           mbed.Serial method
            %   str = obj.gets() reads a string from the serial port until a 
            %   final newline is received. Use GETC to read a single character. 
            %
            %   Note: If the newline is not received within 5 seconds, GETS
            %   times out and returns the characters received before the timeout.

            timeoutSeconds = 5;
            str = '';
            tStart = tic;
            r = 0;
            while toc(tStart) < timeoutSeconds,
                r = str2double(obj.thismbed.RPC(obj.name, 'getc'));
                if r == 10
                    break;
                end
                str(end+1) = char(r);
            end
            if r ~= 10
                warning('mbed.Serial.gets did not receive a newline within 5 seconds');
            end
        end
        
        function putc(obj, c)            
            % putc           mbed.Serial method
            %   obj.putc(charToSend) writes a single character to the serial port. 
            
            validateattributes(c,{'char'},{'nonempty', 'size', [1 1]});
            obj.thismbed.RPC(obj.name, 'putc', {sprintf('%d',c)});
        end
        
        function r = getc(obj)
            % getc           mbed.Serial method
            %   c = obj.getc() reads a single character from the serial port. 

            r = char(str2double( obj.thismbed.RPC(obj.name, 'getc') ));
        end
        
        function r = readable(obj)
            % readable       mbed.Serial method
            %   obj.readable() returns 1 if there is a character 
            %   available to be read
            
            r = str2double( obj.thismbed.RPC(obj.name, 'readable') );
        end
        
        function r  = writeable(obj)
            % readable       mbed.Serial method
            %   obj.readable() returns 1 if there is space available 
            %   to write a character
            
            r = str2double( obj.thismbed.RPC(obj.name, 'writeable') );
        end
        
        function baud(obj, baudrate)
            % baud          mbed.Serial method
            %   obj.baud(baudRate) sets the baud rate of the serial port
            %   The default value is 9600 baud
            
            validateattributes(baudrate, {'numeric'},{'scalar', 'positive', 'integer'});
            obj.thismbed.RPC(obj.name, 'baud', {num2str(baudrate)});
        end
        
        function disp(obj)
            mbed.utils.showObjectInfo(obj, {'baud', ...
                'getc', 'putc', 'puts', 'gets', ...
                'readable', 'writeable'}, ...
                'http://mbed.org/handbook/Serial');
        end                 
    end
end
