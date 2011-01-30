%% Animate PUMA
function animate_puma(robot, q)        

    h = robot.h;
    L = robot.L;
	magnitude = h.magnitude;

	% Assuming that the base of the robot is at [0, 0, 0]
	x = 0;
	y = 0;
	z = 0;

	xs = 0;
	ys = 0;
	zs = h.zmin;
    
	% Compute link transforms ... like puma_fk and record origin 
    %  of each frame
    A = [];
	base = eye(4);
	t = base;
    Tn = t;
	for i = 1:length(L)
        
		Tn(:,:,i) = t;
         
        % 	L =LINK([alpha A theta D sigma])        
        alpha_i = L{i}(1);
        A_i = L{i}(2);
        theta_i = L{i}(3) + q(i);       
        D_i = L{i}(4);
        
        A = [
            [cos(theta_i) -sin(theta_i)*cos(alpha_i) sin(theta_i)*sin(alpha_i)  A_i*cos(theta_i)];
            [sin(theta_i)  cos(theta_i)*cos(alpha_i) -cos(theta_i)*sin(alpha_i) A_i*sin(theta_i)];
            [0             sin(alpha_i)                         cos(alpha_i)    D_i             ];
            [0             0                         0                          1               ]
            ];
        
        t = t * A;
        
		x = [x; t(1,4)];
		y = [y; t(2,4)];
		z = [z; t(3,4)];
		xs = [xs; t(1,4)];
		ys = [ys; t(2,4)];        
		zs = [zeros(length(zs),1); 0.0];
    end

	% Draw robot stick figure
	set(h.robot,'xdata', x, 'ydata', y, 'zdata', z);
    
    % Draw robot shadow
	set(h.shadow,'xdata', xs, 'ydata', ys, 'zdata', zs);	

	% Draw joints and joint axis
	xyz_line = [0 0; 0 0; -2*magnitude 2*magnitude; 1 1];

    for i = 1:length(L),
	  % Get coordinate data 
	  xyz = get(h.joint(i), 'UserData');
	  xyz = Tn(:,:,i) * xyz;
      [~, c] = size(xyz);
	  number_columns = c/2;
	  xc = reshape(xyz(1,:), 2, number_columns);
	  yc = reshape(xyz(2,:), 2, number_columns);
	  zc = reshape(xyz(3,:), 2, number_columns);

	  set(h.joint(i), 'Xdata', xc, ...
                      'Ydata', yc, ...
				      'Zdata', zc);

	  xyzl = Tn(:,:,i) * xyz_line;
	  set(h.jointaxis(i), 'Xdata', xyzl(1,:), ...
				          'Ydata', xyzl(2,:), ...
				          'Zdata', xyzl(3,:));
    end

    % And finally draw everything
	drawnow
end
  