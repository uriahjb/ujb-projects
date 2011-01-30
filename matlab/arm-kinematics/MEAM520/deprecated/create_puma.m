function robot = create_puma(robot)
     

  L = robot.L;
  
  %% Get maximum reach of for axis definition
  reach = 0;
  for i = 1:length(L)      
    %alpha_i = L{i}(1);
    A_i = L{i}(2);
    %theta_i = L{i}(3) + q(i);       
    D_i = L{i}(4);
      
    reach = reach + abs(A_i) + abs(D_i);      
  end
 
  h.dimensions = [-reach reach -reach reach -reach reach];
  h.magnitude = reach/10;
  
  if ~ishold,  
    % if current figure has hold on, then draw robot here
	% otherwise, create a new figure
    axis(h.dimensions);
  end
  xlabel('X')
  ylabel('Y')
  zlabel('Z')
  set(gca, 'drawmode', 'fast');
  grid on
  
  % Get zlimitations
  zlim = get(gca, 'Zlim');
  h.zmin = zlim(1);
  
  % Draw a line that will then be modified to draw the entire robot
  h.robot = line('Color', 'black', ...
                 'Linewidth', 4, ...
                 'erasemode', 'xor');
  
  % Add a shadow because its cool
  h.shadow = line('Color', [.8 .8 .8], ...
                  'Linewidth', 4, ...
                  'erasemode', 'xor');
   
  % Display cylinders for each joint and axis center line
  for i = 1:length(L)
     
      [xc, yc, zc] = cylinder(h.magnitude/4, 8);
      zc(zc==0) = -h.magnitude/2;
	  zc(zc==1) = h.magnitude/2;
      
      % Add surface and color it
      h.joint(i) = surface(xc, yc, zc);
      set(h.joint(i), 'Facecolor', 'blue');
      
      % Build matrix of coordinates for transformations
      %  in animate_puma
      xyz = [xc(:)'; yc(:)'; zc(:)'; ones(1, 2*8+2)];
      set(h.joint(i), 'UserData', xyz);
      
      % Add dashed line along joint axis
      h.jointaxis(i) = line('xdata', [0; 0], ...
                            'ydata', [0; 0], ...
                            'zdata', [0; 0], ...
                            'color', 'black', ...
                            'linestyle', '--', ...
                            'erasemode', 'xor');
                        
   robot.h = h;   
  
  end
  % And we are done!!                   
end
