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
% <a href="matlab:help mbed.HTTPRPC.HTTPRPC">mbed.HTTPRPC</a>

classdef HTTPRPC < mbed.RPCConnection
%Use java directly to implement RPC over TCP
    properties (SetAccess = private)
       addr   
       timeout
    end
    methods
        function obj = HTTPRPC(ipAddress, timeout)            
            % mbed.HTTPRPC provides a RPC connection to an mbed over a HTTP.
            % The mbed needs to be running a HTTP server program.
            % 
            % Usage: 
            %  % Create a RPC connection
            %  mymbed = mbed.HTTPRPC('192.168.2.2');
            %
            %  % Pass the RPC object to the other interface objects
            %  ai = mbed.AnalogIn(mymbed, mbed.p15);
            %  di = mbed.DigitalIn(mymbed, mbed.p5); 
            %
            % Notes: 
            %  * For details on mbed RPC, see 
            %     http://mbed.org/cookbook/Interfacing-Using-RPC
            %     http://mbed.org/cookbook/Interfacing-with-Matlab
            
            if nargin ==0 || ~ischar(ipAddress) || isempty(regexp(ipAddress, '^\d+\.\d+\.\d+\.\d+$', 'once'))
               error('Parameter should be a string specifying an IP Address, e.g., ''192.168.2.2''');
            end
            
            % Nothing actually is done here, other than the put the address
            % of the mbed into the private properties
            % Address should be of the form '192.168.2.2'            
            obj.addr = ipAddress; 
            
            % Set a timeout for http reads if arguement specified
            if nargin > 1                
                obj.timeout = timeout;
            else
                obj.timeout = 5000;
            end
                        
        end
        
        function delete(obj) %#ok<MANU>
           %nothing need actually be done here to close the transport mechanism
        end
        
        function response = RPC(obj, name, method, args)
            %Executes an RPC command over HTTP. name and method are
            %strings. args must be a cell array of strings.             
             if nargin > 1
                if nargin > 2
                    RPCString = ['http://' obj.addr '/rpc/' name '/' method '%20'];
                    if nargin > 3
                        args(2,:) = {'%20'}; 
                        RPCString = [RPCString args{:}];
                    end
                else
                   RPCString = ['http://' obj.addr '/rpc/' name];                   
                end                 
                try                    
                    disp(RPCString);
                    % Java style                      
                    tic
                    url = java.net.URL(RPCString);
                    % Modifications by Uriah, based of of imread.m
                    urlConnection = url.openConnection;
                    urlConnection.setConnectTimeout(obj.timeout);
                    urlConnection.setReadTimeout(obj.timeout);                                           
                    inputStream = urlConnection.getInputStream;
                    inputStreamReader = java.io.InputStreamReader(inputStream);
                    bufferedReader = java.io.BufferedReader(inputStreamReader);
                    response = char(bufferedReader.readLine());                                                            
                    disp(response);                    
                    
                    % Matlab Style
                    %{
                    tic                                        
                    response = urlread(RPCString);
                    disp(toc)
                    disp(response);                    
                    %}
                    %{
                    catch e,
                    disp(e.Message);
                    error('Error sending RPC command over HTTP or getting response');
                    %}
                end
            else
                error('You must pass some commands into the RPC function');
            end
        end              
        
        function disp(obj)
            fprintf('<a href="matlab:help mbed.HTTPRPC.HTTPRPC">mbed.HTTPRPC</a>\n');
            if isvalid(obj)
                fprintf('  IP Address: %s\n', obj.addr);
            else
                fprintf('This object has been deleted and is no longer valid\n');
            end            
        end        
    end
end

