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

%This is the superclass from which all transport mechanisms inherit.
classdef RPCConnection < handle

    methods(Abstract)
           %all sub classes must have:
           %an RPC function of this form
                response = RPC(obj, name, method, args)
                    %it should Execute an RPC command and return the result. 
                    %name and method are strings. args must be a cell array of strings.
                              
           %a reset function to remotely reset the mbed is implemented in
           %transport mechanisms which support this, eg serial.
                %function reset
    end
end
