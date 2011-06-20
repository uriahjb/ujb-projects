% Mobile Tracking Robot Interface:
%    by: Uriah Baalke
%
%
%
%
%
%
%

classdef Robot < handle
    % Declare robot properties
    properties (SetAccess = public)
        m
        c
        drive
        steer
        cam_pitch
        cam_yaw
        camera
        r_p  % robot pose
        r_pd % derivative of robot pose
        c_p  % cam pose
        c_pd % derivative of cam pose
        
        run
        
    end
    methods
        function obj = Robot()
            % Initialize robot
            instrreset
            addpath('../');
            import mbed.*        
            url = '192.168.0.11';
            port = 3444;
            obj.m = mbed.UDPRPC(url, port);
            obj.drive = mbot.Motor(obj.m, mbed.p21, 0.0012, 0.0013, 0.00114, 0.001124);
            obj.steer = mbot.Servo(obj.m, mbed.p22, 0.0017, 0.0011, 0.0019);
            obj.cam_pitch = mbot.Servo(obj.m, mbed.p23, 0.0016, 0.0011, 0.0019);
            obj.cam_yaw = mbot.Servo(obj.m, mbed.p24, 0.0016, 0.0011, 0.0019);
            
            obj.camera = mbot.Camera(20);
            %figure(1);
            %plot(0,0);
            pause(0.5);            
            set(gcf,'KeyPressFcn',@obj.handle_inputs);            
            
            obj.r_p = [0 0];
            obj.r_pd = [0 0];
            obj.c_p = [0 0];
            obj.c_pd = [0 0];               
        end 
        
        function handle_inputs(obj, src, evnt)
            % Read in keyboard inputs and handle them accordingly            
            if strcmp(evnt.Key,'leftarrow')            
                obj.steer.set_pos(obj.steer.pos - 0.05);                                
                disp(obj.steer.pos)
                obj.steer.update()
            elseif strcmp(evnt.Key,'rightarrow')
                obj.steer.set_pos(obj.steer.pos + 0.05);                                
                disp(obj.steer.pos)
                obj.steer.update()
            elseif strcmp(evnt.Key,'uparrow')
                obj.drive.set_velocity(obj.drive.velocity + 0.1);
                disp(obj.drive.velocity)
                obj.drive.update()
            elseif strcmp(evnt.Key,'downarrow')
                obj.drive.set_velocity(obj.drive.velocity - 0.1);
                disp(obj.drive.velocity)
                obj.drive.update()
            elseif strcmp(evnt.Key,'a')            
                obj.cam_yaw.set_pos(obj.cam_yaw.pos + 0.025);                                
                disp(obj.cam_yaw.pos)                
                obj.cam_yaw.update()                
            elseif strcmp(evnt.Key,'d')
                obj.cam_yaw.set_pos(obj.cam_yaw.pos - 0.025);                                
                disp(obj.cam_yaw.pos)                
                obj.cam_yaw.update()                
            elseif strcmp(evnt.Key,'w')            
                obj.cam_pitch.set_pos(obj.cam_pitch.pos + 0.025);                                
                disp(obj.cam_pitch.pos)                
                obj.cam_pitch.update()                
            elseif strcmp(evnt.Key,'s')
                obj.cam_pitch.set_pos(obj.cam_pitch.pos - 0.025);                                
                disp(obj.cam_pitch.pos)                
                obj.cam_pitch.update()                
            elseif strcmp(evnt.Key,'q')
                disp('Stopping Run sequency');
                obj.steer.set_pos(obj.drive.zero);
                obj.drive.set_velocity(obj.drive.zero);                
                obj.update()                
                obj.run = 0;
            end            
        end
        
        function update(obj)
            % Update the overall state of the robot            
            
            obj.drive.update()            
            pause(0.05);
            obj.steer.update()
            pause(0.05);
            obj.cam_pitch.update()
            pause(0.05);
            obj.cam_yaw.update()
            pause(0.05);            
            drawnow()                        
            obj.camera.update()
        end                
        
        function runbot(obj)
            disp('Run Robot!!!');
            obj.run = 1;
            % Run the robot code ... this needs to have increased functions
            while(obj.run)
                %obj.update()
                obj.camera.update()
                drawnow()
            end
        end
        
    end
end
        
        
        