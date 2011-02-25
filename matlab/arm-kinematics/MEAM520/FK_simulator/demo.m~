close all
clear all

disp('Press ENTER to start');
pause;
figure;
hold on;
puma260;

for k = 0:0.05:1
    pumaLED([k,0,k]);
    pumaServo(-k,0,-k,-k,0,0); % successive calls have joint angles to be less than 5 degrees apart
    pumaAngles()
    pause(0.1)% time between two successive calls is greater than 100 ms
end
disp('Press ENTER to continue');
pause;

figure;
pumaLED([1,0,0]);
pumaMove(0,0,0,0,0,0);
disp('Press ENTER to continue');
pause;

figure;
pumaLED([0,0,1]);
pumaMove(0,pi/2,-pi/2,0,0,0);
disp('Press ENTER to continue');
pause;

figure;
pumaLED([0,1,0]);
pumaMove(0,-pi/4,pi/4,0,pi/2,0);
disp('Press ENTER to continue');
pause;

close all;
