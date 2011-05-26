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
% <a href="matlab:help mbed.TestRPC.TestRPC">mbed.TestRPC</a>

classdef TestRPC < mbed.RPCConnection
    
    methods

        function obj = TestRPC()
            % mbed.TestRPC provides a dummy RPC connection that can 
            % be used to do simple tests of tte RPC interface.
            % 
            % Usage: 
            %  % Create a dummy RPC connection
            %  mymbed = mbed.TestRPC();
            %
            %  % Pass the RPC object to the other interface objects
            %  ai = mbed.AnalogIn(mymbed, mbed.p15);
            %  di = mbed.DigitalIn(mymbed, mbed.p5); 
            %
            % Notes: 
            % For details on mbed RPC, see 
            %     http://mbed.org/cookbook/Interfacing-Using-RPC
        end
        
        function response = RPC(obj, name, method, args) %#ok<MANU>
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
                
                fprintf('### %s\n', RPCString);
                pause(0.02);
                
                if nargout > 0,
                    if strcmp(method, 'new')
                        response = args{1};
                    elseif strcmp(method, 'getc')
                        if rand(1) > 0.9
                            response = '10';
                        else
                            response = sprintf('%d', 96+ceil(rand(1)*26));
                        end
                    else
                        response = '0';
                    end
                end
            else
                error('You must pass some commands into the RPC function');
            end
        end
                
    end
    
end
   
