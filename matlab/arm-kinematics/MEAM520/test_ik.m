%% A quick tester function ...

function test_ik(robot, x, y, z, theta, phi, psi)
    [t1, t2, t3, t4, t5, t6] = puma_ik(x, y, z, theta, phi, psi);
    q = [t1 t2 t3 t4 t5 t6];
    disp((180/pi)*q);
    plotrobot(robot,q);
    fkine(robot, q)
end