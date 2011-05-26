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
% <a href="matlab:help mbed.PwmOut.PwmOut">mbed.PwmOut</a>

classdef PwmOut < handle
    properties (SetAccess = private)
        thismbed
        name
    end
    
    methods
        function obj = PwmOut(mbed, Arg)
            % mbed.PwmOut allows you to create an PwmOut object 
            % on the mbed and access its methods using RPC.
            % 
            % Usage: 
            %  % Create a RPC connection
            %  mymbed = mbed.SerialRPC('COM3',9600);
            %
            %  % Create the object on the mbed for pin 21
            %  obj = mbed.PwmOut(mymbed, mbed.p21); 
            %  obj = mbed.PwmOut(mymbed, 'myObj'); % tie to existing 'myObj' object on mbed
            %
            %  % view the list of methods
            %  obj
            %
            %  % invoke a method 
            %  obj.write(0.5);     % set duty cycle to 50%
            %  obj.period(1.5);    % set period to 1.5 seconds
            %  obj.period_ms(200); % set period to 200 milliseconds
            %
            % Notes: 
            %  * Only pins 21 - 26 (mbed.p21 ... mbed.p26) can be used for PWM output
            %  * See http://mbed.org/handbook/PwmOut
            
            if ~((nargin == 2) && isa(mbed, 'mbed.RPCConnection') ...
                    && ( isa(Arg,'mbed.PinName') || ischar(Arg) ))
                nl = sprintf('\n');
                msg = [' Expecting two parameters, e.g.:' nl ...
                       '  mymbed = mbed.SerialRPC(''COM3'',9600);' nl ...
                       '  pwm = mbed.PwmOut(mymbed, mbed.p21);' nl ...
                       '     or   '  nl ...
                       '  pwm = mbed.PwmOut(mymbed, ''myObj'');'];
                error(msg);
            end
            
            obj.thismbed = mbed;
            if isa(Arg,'mbed.PinName')
                %Create a new instance
                if (Arg.no < 21 || Arg.no > 26)
                    error('Only pins 21 - 26 (mbed.p21 ... mbed.p26) can be used for PWM output');
                end                   
                obj.name = obj.thismbed.RPC('PwmOut', 'new', {Arg.name});
                disp('Created new Pwm Out on mbed');
            elseif ischar(Arg)
                %This is a tie command
                obj.name = Arg;
                disp('Tied MATLAB to existing PwmOut on mbed');
            end
            
            % delete this object when thismbed is deleted
            addlistener(obj.thismbed, 'ObjectBeingDestroyed', @(h,e) delete(obj));             
        end
 
        function write(obj, value)
            % write          mbed.PwmOut method
            %   obj.write(pwmValue) sets the ouput duty-cycle, specified as
            %   value between 0.0 and 1.0 (100%). Values outside this range
            %   will be saturated to 0.0 or 1.0.
                        
            validateattributes(value, {'numeric'},{'scalar', 'nonnegative', 'real'});
            obj.thismbed.RPC(obj.name, 'write', {num2str(value)});
        end
        
        function r = read(obj)
            % read          mbed.PwmOut method
            %   obj.read() returns the current ouput duty-cycle setting 
            %   as a value between 0.0 and 1.0 (100%). 
                        
            r = str2double( obj.thismbed.RPC(obj.name, 'read') );
        end
        
        function period(obj, value)
            % period        mbed.PwmOut method
            %   obj.period(pwmPeriod) sets the PWM period, keeping the duty
            %   cycle the same. pwmPeriod is a continuous value specified 
            %   in units of seconds.

            validateattributes(value, {'numeric'},{'scalar', 'nonnegative', 'real'});            
            obj.thismbed.RPC(obj.name, 'period', {num2str(value)});
        end
        
        function period_ms(obj, value)
            % period_ms      mbed.PwmOut method
            %   obj.period_ms(pwmPeriodms) sets the PWM period, keeping the duty
            %   cycle the same. pwmPeriodms is an integer specifying the
            %   number of milliseconds in the period.
            
            validateattributes(value, {'numeric'},{'scalar', 'nonnegative', 'integer'});
            obj.thismbed.RPC(obj.name, 'period_ms', {num2str(value)});
        end
        
        function period_us(obj, value)
            % period_us      mbed.PwmOut method
            %   obj.period_us(pwmPeriodus) sets the PWM period, keeping the duty
            %   cycle the same. pwmPeriodus is an integer specifying the
            %   number of microseconds in the period.

            validateattributes(value, {'numeric'},{'scalar', 'nonnegative', 'integer'});
            obj.thismbed.RPC(obj.name, 'period_us', {num2str(value)});
        end
        
        function pulsewidth(obj, value)
            % pulsewidth     mbed.PwmOut method
            %   obj.pulsewidth(pulseWidth) sets the PWM pulse width, keeping
            %   the period the same. pulseWidth is a continuous value specified 
            %   in units of seconds.

            validateattributes(value, {'numeric'},{'scalar', 'nonnegative', 'real'});
            obj.thismbed.RPC(obj.name, 'pulsewidth', {num2str(value)});
        end
                
        
        function pulsewidth_ms(obj, value)
            % pulsewidth_ms   mbed.PwmOut method
            %   obj.pulsewidth_ms(pulseWidthms) sets the PWM pulse width, keeping
            %   the period the same. pulseWidthms is an integer specifying the
            %   number of milliseconds in the pulse width
            
             validateattributes(value, {'numeric'},{'scalar', 'nonnegative', 'integer'});
             obj.thismbed.RPC(obj.name, 'pulsewidth_ms', {num2str(value)});
        end
        
        function pulsewidth_us(obj, value)
            % pulsewidth_us   mbed.PwmOut method
            %   obj.pulsewidth_us(pulseWidthus) sets the PWM pulse width, keeping
            %   the period the same. pulseWidthus is an integer specifying the
            %   number of microseconds in the pulse width
            
            validateattributes(value, {'numeric'},{'scalar', 'nonnegative', 'integer'});
            obj.thismbed.RPC(obj.name, 'pulsewidth_us', {num2str(value)});
        end
        
        function disp(obj)
            mbed.utils.showObjectInfo(obj, {'write', 'read', ...
                'period', 'period_ms', 'period_us', ...
                'pulsewidth', 'pulsewidth_ms', 'pulsewidth_us'}, ...
                'http://mbed.org/handbook/PwmOut');
        end            
    end
end
