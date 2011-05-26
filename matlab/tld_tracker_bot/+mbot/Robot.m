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
        
    end
    methods
        function obj = Robot()
            % Initialize robot
            addpath('../');
            import mbed.*        
            url = '192.168.0.11';
            port = 3444;
            obj.m = mbed.UDPRPC(url, port);
            obj.drive = mbot.Motor(obj.m, mbed.p21, 0.0011, 0.0012, 0.00103, 0.00102);
            obj.steer = mbot.Servo(obj.m, mbed.p22, 0.0016, 0.0011, 0.0019);
            obj.cam_pitch = mbot.Servo(obj.m, mbed.p23, 0.0016, 0.0011, 0.0019);
            obj.cam_yaw = mbot.Servo(obj.m, mbed.p24, 0.0016, 0.0011, 0.0019);
            
            obj.camera = mbot.Camera(10);
            
            obj.r_p = [0 0];
            obj.r_pd = [0 0];
            obj.c_p = [0 0];
            obj.c_pd = [0 0];
        end                                           
        
        function update(obj)
            % Update the overall state of the robot            
            obj.drive.update()            
            obj.steer.update()
            obj.cam_pitch.update()
            obj.cam_yaw.update()
            obj.camera.update()
        end
    end
end
        
        
        