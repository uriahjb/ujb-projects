%% Test trajectory code

t = [0:0.1:100];

scale_factor = 0.03;
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
% Point the tool in the corrent direction
orientation = [pi, pi/2, 0];

[XX, YY, ZZ] = puma_trajectory(x, y, z, orientation(1), ...
                                     orientation(2), ...
                                     orientation(3));
