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
% <a href="matlab:help mbed.DigitalIn.DigitalIn">mbed.DigitalIn</a>

classdef DigitalIn < handle
    properties (SetAccess = private)
        thismbed
        name
    end
    methods
        function obj = DigitalIn(mbed, Arg)
            % mbed.DigitalIn allows you to create an DigitalIn object 
            % on the mbed and access its methods using RPC.
            % 
            % Usage: 
            %  % Create a RPC connection
            %  mymbed = mbed.SerialRPC('COM3',9600);
            %
            %  % Create the object on the mbed for pin 5
            %  obj = mbed.DigitalIn(mymbed, mbed.p5); 
            %  obj = mbed.DigitalIn(mymbed, 'myObj'); % tie to existing 'myObj' object on mbed
            %
            %  % view the list of methods
            %  obj
            %
            %  % invoke a method 
            %  value = obj.read()
            %
            % Notes: 
            %  * Only pins 5 - 30 (mbed.p5 ... mbed.p30) can be used for digital input
            %  * See http://mbed.org/handbook/DigitalIn
            
            if ~((nargin == 2) && isa(mbed, 'mbed.RPCConnection') ...
                    && ( isa(Arg,'mbed.PinName') || ischar(Arg) ))
                nl = sprintf('\n');
                msg = [' Expecting two parameters, e.g.:' nl ...
                       '  mymbed = mbed.SerialRPC(''COM3'',9600);' nl ...
                       '  di = mbed.DigitalIn(mymbed, mbed.p5);' nl ...
                       '     or   '  nl ...
                       '  di = mbed.DigitalIn(mymbed, ''myObj'');'];
                error(msg);
            end
                        
            obj.thismbed = mbed;
            if isa(Arg,'mbed.PinName')
                %Create a new instance
                if (Arg.no < 5 || Arg.no > 30)
                    error('Only pins 5 - 30 (mbed.p5 ... mbed.p30) can be used for digital input');
                end                
                obj.name = obj.thismbed.RPC('DigitalIn', 'new', {Arg.name});
                disp('Created new Digital In on mbed');
            elseif ischar(Arg)
                %This is a tie command
                obj.name = Arg;
                disp('Tied MATLAB to existing DigitalIn on mbed');
            end
            
            % delete this object when thismbed is deleted
            addlistener(obj.thismbed, 'ObjectBeingDestroyed', @(h,e) delete(obj));            
        end
        
        function r = read(obj)
            % read          mbed.DigitalIn method            
            %   obj.read() returns the current state of the digital pin (0 or 1)
                        
            r = str2double( obj.thismbed.RPC(obj.name, 'read') );
        end
        
        function mode(obj, pinMode)
            % mode          mbed.DigitalIn method
            %   obj.mode(modeValue) sets the input pin mode. modeValue should 
            %   be 'PullUp', 'PullDown', 'PullNone', or 'OpenDrain'            
            
            validateattributes(pinMode,{'char'},{'nonempty'});            
            options = {'PullUp', 'PullDown', 'PullNone', 'OpenDrain'};
            match = find(strncmpi(pinMode, options, length(pinMode)));
            if numel(match)==1
                obj.thismbed.RPC(obj.name, 'write', options(match));
            else
                fprintf('Invalid pin mode. Should be one of: \n  ');
                fprintf('''%s'' ', options{:});
                fprintf('\n');
            end                            
        end
        
        function disp(obj)
            mbed.utils.showObjectInfo(obj, {'read', 'mode'}, ...
                'http://mbed.org/handbook/DigitalIn');
        end            
    end
end