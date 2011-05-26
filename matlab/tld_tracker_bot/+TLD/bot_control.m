% Copyright 2011 Uriah Baalke
% 
% This is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% It is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% See <http://www.gnu.org/licenses/>


%% A function to control Prof. Fiene's robot to track an object using its
%% camera while interfaceing with TLD ... note: this is basically a hack
%   by: Uriah Baalke

function tld = bot_control(tld, i)


    % Create robot interface if it does not already exist
    if ~isfield(tld, 'bot')
        bot_name = 'light';
        serial_name = '/dev/tty.usbmodem411';
        instrreset
        tld.bot.serial = open_robot(serial_name, bot_name);
        tld.bot.P = 0;
        tld.bot.I = 0;
    end
    
    % Control robot to center its view on the tld bb
    %disp(bb_center(tld.bb(:,tld.source.idx(i))));    
    
    img = tld.img{i}.input;
    [H,W] = size(img);
    
    center = bb_center(tld.bb(:,tld.source.idx(i))) - [W; H]/2;    
    
    if ~isnan(center(1)) && ~isnan(center(2))        
        
        KP = 1.0;
        KI = 0.3;
        
        tld.bot.P = center(1);
        tld.bot.I = tld.bot.I + center(1);
        
        if tld.bot.I > 100
            tld.bot.I = 100;
        end
        
        
        v_cmd = 0;
        % Through down some sweet PI control on angular velocity
        w_cmd = KP*tld.bot.P + KI*tld.bot.I;
        
        % Transform angular velocity to wheel velocities
        w_l = (v_cmd + w_cmd);
        w_r = (v_cmd - w_cmd);
        set_velocities(tld.bot.serial, w_l, w_r);
    else
        set_velocities(tld.bot.serial, 0, 0);
    end
        
end
    
    