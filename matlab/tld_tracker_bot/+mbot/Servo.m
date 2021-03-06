% Mobile Tracking Robot Interface: Servo Class
%    by: Uriah Baalke
%
%
%
%
%
%
%
classdef Servo < handle
    % Define basic servo properties
    properties
        % Properties
        pin_handle
        zero
        pos
        velocity
        lower_limit
        upper_limit
        lower_pwm
        upper_pwm
        pwm_cmd        
    end
    methods
        % The Servo provides a basic class for controlling servos
        % using pwm inputs from the mbed
        function obj = Servo(mbed_handle, pin_handle, zero, lower_limit, upper_limit)
            % Initialize servo with a handle to the mbed.pin, a zero
            % position, and limits
            obj.pin_handle = mbed.PwmOut(mbed_handle, pin_handle);
            obj.zero = zero;
            obj.lower_limit = lower_limit;
            obj.upper_limit = upper_limit;   
            obj.upper_pwm = obj.upper_limit - obj.zero;
            obj.lower_pwm = obj.zero - obj.lower_limit; 
            
            % Init pos and velocity
            obj.pos = 0;
            obj.velocity = 0;
            
            % Set up period and pulsewidth corresponding to zero_pos
            pause(0.05);
            obj.pin_handle.period(1/50);
            obj.pwm_cmd = zero;
            obj.pin_handle.pulsewidth(obj.pwm_cmd)
        end
        
        function out = limit(obj, pos)
            % Safety limit function
            if pos > 0              
                pos = -(obj.upper_pwm - obj.zero)*(pos/2) + obj.zero;
                if pos > obj.upper_limit
                    out = obj.upper_limit; 
                    return
                end
            end
            if pos < 0              
                pos = (obj.zero - obj.lower_pwm)*(pos/2) + obj.zero;
                if pos < obj.lower_limit
                    out = obj.lower_limit;                    
                    return
                end
            end
            if pos == 0
                out = obj.zero;
                return;
            end
            out = pos;
        end
        
        function pos_pw = set_pos(obj, pos)
            % Set position from range of -1 (-90 deg) to 1 (90 deg)            
            if pos > 1
                pos = 1;
            elseif pos < -1
                pos = -1;
            end
            obj.pos = pos;
            pos_pw = obj.limit(pos); 
            % Send pulsewidth command
            obj.pwm_cmd = pos_pw;            
        end
        
        function vel_pw = set_velocity(obj, velocity)
            % Set velocity ... kinda
            obj.velocity = velocity;
            vel_pw = (obj.upper_limit - obj.lower_limit)*velocity;            
            obj.velocity = vel_pw;
        end
        
        function update(obj)
            % Update current servo state
            if obj.velocity ~= 0
                obj.pwm_cmd = obj.pwm_cmd + obj.velocity;
            end
            
            if obj.pwm_cmd > obj.upper_limit
                obj.pwm_cmd = obj.upper_limit;
            end
            
            if obj.pwm_cmd < obj.lower_limit
                obj.pwm_cmd = obj.lower_limit;
            end
            
            obj.pin_handle.pulsewidth(obj.pwm_cmd);
        end
        
    end    
end