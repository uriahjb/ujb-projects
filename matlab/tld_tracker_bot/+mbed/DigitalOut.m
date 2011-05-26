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
% <a href="matlab:help mbed.DigitalOut.DigitalOut">mbed.DigitalOut</a>

classdef DigitalOut < handle
    properties (SetAccess = private)
        thismbed
        name
    end
    methods
        function obj = DigitalOut(mbed, Arg)
            % mbed.DigitalOut allows you to create an DigitalOut object 
            % on the mbed and access its methods using RPC.
            % 
            % Usage: 
            %  % Create a RPC connection
            %  mymbed = mbed.SerialRPC('COM3',9600);
            %
            %  % Create the object on the mbed for pin 5
            %  obj = mbed.DigitalOut(mymbed, mbed.p5); 
            %  obj = mbed.DigitalOut(mymbed, 'myObj'); % tie to existing 'myObj' object on mbed            
            %
            %  % view the list of methods
            %  obj
            %
            %  % invoke a method 
            %  obj.write(1)
            %
            % Notes: 
            %  * Only pins 5 - 30 or LEDs 1 - 4 ((mbed.p5 ... mbed.p30, 
            %    mbed.led1 ... mbed.led4) can be used for digital output
            %  * See http://mbed.org/handbook/DigitalOut
            
            if ~((nargin == 2) && isa(mbed, 'mbed.RPCConnection') ...
                    && ( isa(Arg,'mbed.PinName') || ischar(Arg) ))
                nl = sprintf('\n');
                msg = [' Expecting two parameters, e.g.:' nl ...
                       '  mymbed = mbed.SerialRPC(''COM3'',9600);' nl ...
                       '  do = mbed.DigitalOut(mymbed, mbed.p5);' nl ...
                       '     or   '  nl ...
                       '  do = mbed.DigitalOut(mymbed, ''myObj'');'];
                error(msg);
            end
                        
            obj.thismbed = mbed;
            if isa(Arg,'mbed.PinName')
                %Create a new instance
                name = Arg.name;
                
                if (name(1)=='p') && (Arg.no < 5 || Arg.no > 30)
                    error('Only pins 5 - 30 (mbed.p5 ... mbed.p30) can be used for digital output');
                elseif strncmp(name,'LED',3) && (Arg.no < 1 || Arg.no > 4)
                    error('Only LEDs 1 - 4 (mbed.led1 ... mbed.led4) can be used for digital output');
                end
                
                obj.name = obj.thismbed.RPC('DigitalOut', 'new', {Arg.name});
                disp('Created new Digital out on mbed');
            elseif ischar(Arg)
                %This is a tie command
                obj.name = Arg;
                disp('Tied MATLAB to existing DigitalOut on mbed');
            end
            
            % delete this object when thismbed is deleted
            addlistener(obj.thismbed, 'ObjectBeingDestroyed', @(h,e) delete(obj));            
        end
        
        function write(obj, value)
            % write          mbed.DigitalOut method
            %   obj.write(pinValue) sets the value of the digital pin. 
            %   pinValue should be numeric 0 or 1.

            validateattributes(value, {'numeric'},{'scalar', 'binary'});
            obj.thismbed.RPC(obj.name, 'write', {num2str(value)});
        end
        
        function r = read(obj)
            % read          mbed.DigitalOut method
            %   obj.read() returns the current setting of the digital pin 
            %   as a numeric 0 or 1. 

            r = str2double( obj.thismbed.RPC(obj.name, 'read') );
        end
        
        function disp(obj)
            mbed.utils.showObjectInfo(obj, {'write', 'read'}, ...
                'http://mbed.org/handbook/DigitalOut');
        end            
    end
end