function t = puma_fk(q)
    % Initialize PUMA260 object
    p = puma260;
    
    % Run PUMA260 forward kinematics
    [~, t] = p.fk(q);

end