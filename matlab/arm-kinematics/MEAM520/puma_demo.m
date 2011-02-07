function puma_demo()
    p = puma260;
    disp('PUMA260 demos');
    disp('');
    disp('Random movements showing end effector points');
    disp('');
    p.demo_workspace(50);
    p.reset;
    p.demo_workspace(50);
    p.reset;
    disp('Spiralling Movements demo');
    p.demo_spiral(0, pi/2, -pi/2, -0.1, -0.002, 0, 100);
    p.reset;
    p.demo_spiral(0, pi/2, -pi/2, -0.1, -0.003, 0.004, 100)
    p.reset;
    disp('');
    disp('Driving Joint Oscillations');
    p.demo_oscillate(0, pi/2, -pi/4, -0.1, 0.03, -0.01, 100) 
    p.reset
    p.demo_oscillate(0, pi/2, -pi/2, -0.1, 0.005, -0.0, 100)
    p.reset;
end