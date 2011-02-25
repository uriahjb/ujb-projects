function [ ] = pumaLED(colr)
%PUMALED changes the LED colour based on the 1x3 input array
%   INPUTS:
%   colr = [R,G,B] a 1x3 array
%   R - Red channel ( 0 - 1 )
%   B - Blue channel (0 - 1)
%   G - Green channel (0 - 1)
%
% pumaLED(0,0,0) - LED turns off
% pumaLED(1,0,0) - LED truns RED
% pumaLED(0,1,0) - LED turns green
% pumaLED(0,0,1) - LED truns blue
% pumaLED(0.5,0.5,0.5) - LED turns to some intermediate color
% and so on...
    if(~evalin('base','exist(''puma'',''var'')'))
        error('PUMA has not been initialised. Run puma260.m first');
    end 
    global puma;
    if(nargin ~= 1 && size(colr,2) ~= 3)
        error('Need a 1x3 input array');
    end
    puma.ledcol = abs(colr);

end

