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

%This class allows you to create a RPCFunction object on your mbed and then
%access its methods using RPC.

classdef RPCFunction < handle
    properties (SetAccess = private)
        thismbed
        name
    end
    methods
        function obj = RPCFunction(mbed, Arg)
            obj.thismbed = mbed;
            if ischar(Arg)
                %This is a tie command
                obj.name = Arg;
                disp('Tied MATLAB to existing RPCFunction on mbed');
            end
        end
        function r = read(obj)
            r = obj.thismbed.RPC(obj.name, 'read');
        end
        function r = run(obj, value)
            r = obj.thismbed.RPC(obj.name, 'run', {value});
        end
    end
end

