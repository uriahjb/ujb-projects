% Mobile Tracking Robot Interface: Camera Class 
%    by: Uriah Baalke
%
%    ... handles camera inputs and TLD processing / viewing
%
%
%
%
%
classdef Camera < handle
    properties
        % Properties
        IP
        frame_capture_rate
        frame_number
        time
        tld
        opt
        tracked_state
    end
    
    methods 
        function obj = Camera(frame_capture_rate)                                                                                  
            
            obj.IP = 'http://127.0.0.1:8888';
            
            if obj.frame_capture_rate > 15
                error('Max Capture rate is 15 fps')
            end
            obj.frame_capture_rate = frame_capture_rate;
            obj.frame_number = 1;
            obj.time = tic;            
            
            % Start up TLD
            import TLD.*
            [obj.tld, obj.opt] = TLD.initTLD(obj.IP);                       
        end  
        
        function newframe = capture_frame(obj)
            % If its been long enough capture and process frame using TLD
            if toc(obj.time) > (1/obj.frame_capture_rate)
                obj.frame_number = obj.frame_number + 1;
                [obj.tld, obj.opt] = TLD.updateTLD(obj.IP, obj.frame_number, obj.tld, obj.opt);
                obj.time = tic;
                newframe = 1;
                return;
            end
            newframe = 0;
        end
        
        function updd = update(obj)
            % Update the state of the tracked object
            if obj.capture_frame()
                img = obj.tld.img{obj.frame_number}.input;
                [H,W] = size(img);    
                center = bb_center(obj.tld.bb(:,obj.tld.source.idx(obj.frame_number))) - [W; H]/2;        
                if ~isnan(center(1)) && ~isnan(center(2)) 
                    obj.tracked_state = center;
                end
                updd = 1;
            end
            updd = 0;
        end
                                                
        
        function kill_ffb(~)
             % Check if fast_frame_buffer is running if so kill
            res = 1;
            while(~isempty(res))
                [status, result] = system('ps x | grep mjpeg-frameserver.jar');
                if status ~= 0
                    error('Not Unix???');
                end
                disp(result)
                res = strtok(result);
                if ~isempty(res)
                    disp(res)
                    out = ['kill ' res];
                    [status, ~] = system(out);
                    if status ~= 0
                        break
                    end
                end
            end
        end                            
        
    end
end
       
        