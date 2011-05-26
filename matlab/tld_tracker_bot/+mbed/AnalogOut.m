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
% <a href="matlab:help mbed.AnalogOut.AnalogOut">mbed.AnalogOut</a>

classdef AnalogOut < handle
    properties (SetAccess = private)
        thismbed
        name
    end
    methods
        function obj = AnalogOut(mbed, Arg)
            % mbed.AnalogOut allows you to create an AnalogOut object 
            % on the mbed and access its methods using RPC.
            % 
            % Usage: 
            %  % Create a RPC connection
            %  mymbed = mbed.SerialRPC('COM3',9600);
            %
            %  % Create the object on the mbed for pin 18
            %  ao = mbed.AnalogOut(mymbed, mbed.p18); 
            %  ao = mbed.AnalogOut(mymbed, 'myObj'); % tie to existing 'myObj' object on mbed
            %
            %  % view the list of methods
            %  ao
            %
            %  % invoke a method 
            %  ao.write(23)
            %
            % Notes: 
            %  * Only pin 18 (mbed.p18) can be used for analog output
            %  * See http://mbed.org/handbook/AnalogOut
            
            if ~((nargin == 2) && isa(mbed, 'mbed.RPCConnection') ...
                    && ( isa(Arg,'mbed.PinName') || ischar(Arg) ))
                nl = sprintf('\n');
                msg = [' Expecting two parameters, e.g.:' nl ...
                       '  mymbed = mbed.SerialRPC(''COM3'',9600);' nl ...
                       '  ao = mbed.AnalogOut(mymbed, mbed.p18);' nl ...
                       '     or   '  nl ...
                       '  ao = mbed.AnalogOut(mymbed, ''myObj'');'];
                error(msg);
            end
                        
            obj.thismbed = mbed;
            if isa(Arg,'mbed.PinName')
                %Create a new instance
                if (Arg.no ~= 18)
                    error('Only pin 18 (mbed.p18) can be used for analog output');
                end                
                obj.name = obj.thismbed.RPC('AnalogOut', 'new', {Arg.name});
                disp('Created new Analog Out on mbed');
            elseif ischar(Arg)
                %This is a tie command
                obj.name = Arg;
                disp('Tied MATLAB to existing AnalogOut on mbed');
            end
        end
        
        function write(obj, value)
            % write          mbed.AnalogOut method
            %   obj.write(value) sets the output voltage, specified as a
            %   value between 0.0 (0 Volts) and 1.0 (3.3 Volts). Values
            %   outside this range will be saturated to 0 or 1.

            validateattributes(value, {'numeric'},{'scalar', 'real', 'nonnegative'});
            obj.thismbed.RPC(obj.name, 'write', {num2str(value)});
        end
        
        function write_u16(obj, value)
            % write_u16      mbed.AnalogOut method
            %   obj.write_u16(value) sets the output voltage, specified as a
            %   16-bit unsigned integer value (where 0 = 0V, 65535 = 3.3V)
            
            validateattributes(value, {'numeric'},{'scalar', 'nonnegative', 'integer'});
            obj.thismbed.RPC(obj.name, 'write_u16', {num2str(value)});
        end
        
        function r = read(obj)
            % read          mbed.AnalogOut method            
            %   obj.read() returns the current output voltage setting as a 
            %   value between 0.0 (0 Volts) and 1.0 (3.3 Volts)
            
            r = str2double( obj.thismbed.RPC(obj.name, 'read') );
        end
        
        function disp(obj)
            mbed.utils.showObjectInfo(obj, {'write', 'write_u16', 'read'}, ...
                'http://mbed.org/handbook/AnalogOut');
        end        
    end
end