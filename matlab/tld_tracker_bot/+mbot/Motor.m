% Mobile Tracking Robot Interface: Motor Class,
%       interface with Axial AE-1 ESC
%    by: Uriah Baalke
%
%
%
%
%
%
%
classdef Motor < handle
    % Define basic servo properties
    properties
        % Properties
        pin_handle
        direction
        forward_zero
        forward_max
        reverse_zero
        reverse_max
        zero
        velocity                
        pwm_cmd        
    end
    methods
        % The Servo provides a basic class for controlling servos
        % using pwm inputs from the mbed
        function obj = Motor(mbed_handle, pin_handle, forward_zero, forward_max, reverse_zero, reverse_max)
            % Initialize servo with a handle to the mbed.pin, a zero
            % position, and limits
            obj.pin_handle = mbed.PwmOut(mbed_handle, pin_handle);
            obj.zero = forward_zero;
            obj.forward_zero = forward_zero;
            obj.reverse_zero = reverse_zero;            
            obj.forward_max = forward_max;
            obj.reverse_max = reverse_max;
            
            % Init velocity state
            obj.velocity = 0;
            
            % Set up period and pulsewidth corresponding to zero_pos
            pause(0.05);
            obj.pin_handle.period(1/50);
            obj.pwm_cmd = obj.forward_zero;
            obj.pin_handle.pulsewidth(obj.pwm_cmd);
        end
        
        function out = limit(obj, velocity)
            % Safety limit function
            if velocity > 0              
                velocity = (obj.forward_max - obj.forward_zero)*(velocity) ...
                             + obj.forward_zero;
                if velocity > obj.forward_max
                    out = obj.forward_max; 
                    return
                end
            end
            if velocity < 0              
                velocity = (obj.reverse_zero - obj.reverse_max)*(velocity) ...
                             + obj.reverse_zero;
                if velocity < obj.reverse_max
                    out = obj.reverse_max;                    
                    return
                end
            end
            if velocity == 0
                out = obj.forward_zero;
                return;
            end
            out = velocity;
        end
        
        function velocity_pw = set_velocity(obj, velocity)
            % Set velocity from -1.0 to 1.0, for direction and 
            %   amount of speed
            if velocity > 1.0                
                velocity = 1.0;
            end
            if velocity < -1.0
                velocity = -1.0;
            end
            obj.velocity = velocity;
            velocity_pw = obj.limit(velocity); 
            % Send pulsewidth command
            obj.pwm_cmd = velocity_pw;            
        end
                
        function update(obj)
            % Update current servo state                       
            obj.pin_handle.pulsewidth(obj.pwm_cmd);
        end
        
    end    
end