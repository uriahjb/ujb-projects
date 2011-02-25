%% Draw a quick line with ikine

clear all
close all

puma260;

current_q = pumaAngles();

delta = 0.05;

y = [-0.15:0.005:-0.05];

x = [];
z = [];

for i=1:length(y)
    x(i) = 0.35;
    z(i) = 0.4;
end

% Point the tool in the corrent direction
orientation = [pi/2, pi, 0];

[t1, t2, t3, t4, t5, t6] = puma_ik(x(1), y(1), z(1), ...
                                   orientation(1), ...
                                   orientation(2), ...
                                   orientation(3));                             

% For debugging
%{
lowlim = [-180 -75 -235 -580 -30 -215]; % LOwer limits of joints
uplim  = [110 240 60 40 200 295]; % Upper limits of joints                                   
disp('lowlim');
disp(lowlim);
disp('uplim');
disp(uplim);
q = [t1 t2 t3 t4 t5 t6];
plotrobot(puma, q, 'shadow', 'noshadow');
disp([t1 t2 t3 t4 t5 t6].*(180/pi));     
%}
                           
pumaMove(t1, t2, t3, t4, t5, t6);                                   

for k = 1:length(x),
    [t1, t2, t3, t4, t5, t6] = puma_ik(x(k), y(k), z(k), ...
                                       orientation(1), ...
                                       orientation(2), ...
                                       orientation(3));
    disp([t1 t2 t3 t4 t5 t6]);
    pumaLED([1.0,0,1.0]);
    pumaServo(t1,t2,t3,t4,t5,t6);
    pause(0.1)% time between two successive calls is greater than 100 ms
end
