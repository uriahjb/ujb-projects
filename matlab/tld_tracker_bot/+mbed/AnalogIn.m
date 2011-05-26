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
% <a href="matlab:help mbed.AnalogIn.AnalogIn">mbed.AnalogIn</a>

classdef AnalogIn < handle
% This class allows you to create an AnalogIn object on your mbed and then
% access its methods using RPC.
% mbed.AnalogIn Properties:
%   name - name of the AnalogIn 
% mbed.AnalogIn Methods:
%   read     - return the input voltage as a value in range [0, 1.0]
%   read_u16 - return the input voltage as a 16-bit unsigned int value
    
    properties (SetAccess = private)
        thismbed
        name
    end
    
    methods
        function obj = AnalogIn(mbed, Arg)
            % mbed.AnalogIn allows you to create an AnalogIn object 
            % on the mbed and access its methods using RPC.
            % 
            % Usage: 
            %  % Create a RPC connection
            %  mymbed = mbed.SerialRPC('COM3',9600);
            %
            %  % Create the object on the mbed for pin 15
            %  obj = mbed.AnalogIn(mymbed, mbed.p15); 
            %  obj = mbed.AnalogIn(mymbed, 'myObj'); % tie to existing 'myObj' object on mbed
            %
            %  % view the list of methods
            %  obj
            %
            %  % invoke a method 
            %  value = obj.read()
            %
            % Notes: 
            %  * Only pins 15 - 20 (mbed.p15 ... mbed.p20) can be used for analog input
            %  * See http://mbed.org/handbook/AnalogIn
            
            if ~((nargin == 2) && isa(mbed, 'mbed.RPCConnection') ...
                    && ( isa(Arg,'mbed.PinName') || ischar(Arg) ))
                nl = sprintf('\n');
                msg = [' Expecting two parameters, e.g.:' nl ...
                       '  mymbed = mbed.SerialRPC(''COM3'',9600);' nl ...
                       '  ai = mbed.AnalogIn(mymbed, mbed.p15);' nl ...
                       '     or   '  nl ...
                       '  ai = mbed.AnalogIn(mymbed, ''myObj'');'];
                error(msg);
            end
            
            obj.thismbed = mbed;
            if isa(Arg,'mbed.PinName')
                %Create a new instance
                if (Arg.no < 15 || Arg.no > 20)
                    error('Only pins 15 - 20 (mbed.p15 ... mbed.p20) can be used for analog input');
                end
                obj.name = obj.thismbed.RPC('AnalogIn', 'new', {Arg.name});
                disp('Created new Analog In on mbed');
            elseif ischar(Arg)
                %This is a tie command
                obj.name = Arg;
                disp('Tied MATLAB to existing AnalogIn on mbed');
            end
            
            % delete this object when thismbed is deleted
            addlistener(obj.thismbed, 'ObjectBeingDestroyed', @(h,e) delete(obj));
        end
        
        function r = read(obj)            
            % read          mbed.AnalogIn method
            %   obj.read() returns the input voltage for the pin  as 
            %   as continuous value in the range [0.0, 1.0]

            r = str2double( obj.thismbed.RPC(obj.name, 'read') );
        end
        
        function r = read_u16(obj)
            % read_u16          mbed.AnalogIn method
            %   obj.read_u16() returns the input voltage for the pin as a
            %   16-bit unsigned integer value, in the range [0 ... 65535].

            r = str2double( obj.thismbed.RPC(obj.name, 'read_u16') );
        end
        
        function disp(obj)
            mbed.utils.showObjectInfo(obj, {'read', 'read_u16'}, 'http://mbed.org/handbook/AnalogIn');
        end
    end
end

