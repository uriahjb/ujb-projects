% MATLAB Interface to mbed 
% Version 1.0 01-nov-2010
%
% RPC connections 
%   <a href="matlab:help mbed.SerialRPC.SerialRPC">mbed.SerialRPC</a>  - RPC over a serial (uart) connection
%   <a href="matlab:help mbed.HTTPRPC.HTTPRPC">mbed.HTTPRPC</a>    - RPC over a HTTP connection
%   <a href="matlab:help mbed.TestRPC.TestRPC">mbed.TestRPC</a>    - Dummy RPC (for testing)
%
% Library classes 
%   <a href="matlab:help mbed.AnalogIn.AnalogIn">mbed.AnalogIn</a>   - Analog input
%   <a href="matlab:help mbed.AnalogOut.AnalogOut">mbed.AnalogOut</a>  - Analog output
%   <a href="matlab:help mbed.DigitalIn.DigitalIn">mbed.DigitalIn</a>  - Digital Input
%   <a href="matlab:help mbed.DigitalOut.DigitalOut">mbed.DigitalOut</a> - Digital Output
%   <a href="matlab:help mbed.PwmOut.PwmOut">mbed.PwmOut</a>     - PWM Output
%   <a href="matlab:help mbed.Serial.Serial">mbed.Serial</a>     - Serial port on mbed 
%   
% mbed Namespace
%   Use "import mbed.*" to avoid having to specify the namespace every time.
%   BEFORE
%     mymbed = mbed.SerialRPC('COM5',9600);
%     ao = mbed.AnalogOut(mymbed, mbed.p18); 
%   AFTER
%     import mbed.*
%     mymbed = SerialRPC('COM5',9600);
%     ao = AnalogOut(mymbed, p18);
% 
% Getting Started & Examples 
%   http://mbed.org/cookbook/Interfacing-with-Matlab 
% 
% More information
%   http://mbed.org/handbook/Homepage  (mbed Library reference)
