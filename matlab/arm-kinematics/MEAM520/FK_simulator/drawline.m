%% Draw a quick line with ikine

clear all
close all

puma260;

current_q = pumaAngles();

delta = 0.05;

y = [-0.15:-0.005:-0.05];
x = [];
z = [];
for i=1:length(x),
    x(i) = 0.35;
    z(i) = 0.4;
end

[t1, t2, t3, t4, t5, t6] = puma_ik(x(1), y(1), z(1), ...
                                       0, pi/2, pi/2);

%lowlim = [-180 -75 -235 -580 -30 -215]; % LOwer limits of joints
%uplim  = [110 240 60 40 200 295]; % Upper limits of joints                                   
disp([t1 t2 t3 t4 t5 t6].*(180/pi));                                
pumaMove(t1, t2, t3, t4, t5, t6);                                   

for k = 1:length(x),
    [t1, t2, t3, t4, t5, t6] = puma_ik(x(k), y(k), z(k), ...
                                       0, pi/2, pi/2);
    disp([t1 t2 t3 t4 t5 t6]);
    pumaLED([1.0,0,1.0]);
    pumaServo(t1,t2,t3,t4,t5,t6);
    pause(0.1)% time between two successive calls is greater than 100 ms
end
