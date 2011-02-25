%% Draw a quick path with ikine

clear all
close all

puma260;

current_q = pumaAngles();

delta = 0.05;


%% Generate butterfly path
t = [0:0.003:6];

scale_factor = 0.02;
y_0 = 0.15;
z_0 = 0.4;

Y = y_0 + scale_factor*(sin(t).*(exp((cos(t))) - 2*cos(4*t) - sin(t/30).^5));
Z = z_0 + scale_factor*(cos(t).*(exp((cos(t))) - 2*cos(4*t) - sin(t/30).^5));


R = (sqrt((Y - y_0).^2 + (Z - z_0).^2));
R = R/max(R);

y = Y;
z = Z;

for i=1:length(y)
    x(i) = 0.35;
end

%% Move from Puma zero pos to path Init pos
orientation = [pi, pi/2, 0];

[x, y, z] = puma_trajectory(x, y, z, ...                                    
                            orientation(1), ...
                            orientation(2), ...
                            orientation(3));  


[t1, t2, t3, t4, t5, t6] = puma_ik(x(1), y(1), z(1), ...
                                   orientation(1), ...
                                   orientation(2), ...
                                   orientation(3));  
q = [t1 t2 t3 t4 t5 t6];
                               
steps = 20;

t01 = [0:t1/steps:t1];
t02 = [0:t2/steps:t2];
t03 = [0:t3/steps:t3];
t04 = [0:t4/steps:t4];
t05 = [0:t5/steps:t5];
t06 = [0:t6/steps:t6];

pumaStart %Initialize

for i = 1:steps,
    pumaServo(t01(i), t02(i), t03(i), t04(i), t05(i), t06(i));
    pause(0.025)% time between two successive calls is greater than 100 ms
end
% Let it settle
pause(0.5);


%% Move through path

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
                           
%pumaMove(t1, t2, t3, t4, t5, t6);                                   

for k = 1:length(x),
    disp(k);
    [t1, t2, t3, t4, t5, t6] = puma_ik(x(k), y(k), z(k), ...
                                       orientation(1), ...
                                       orientation(2), ...
                                       orientation(3));
                                   
    
    q = [t1 t2 t3 t4 t5 t6];
    
    pumaLED([1.0,1 - 0.7*R(k), 0.5*R(k)]);
    pumaMove(t1,t2,t3,t4,t5,t6);
    %pause(0.025)% time between two successive calls is greater than 100 ms
end
