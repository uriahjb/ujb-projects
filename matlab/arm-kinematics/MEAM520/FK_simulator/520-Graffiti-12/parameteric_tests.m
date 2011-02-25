%% Testing out some cool parametric curves


close all
clear all

t = [0:0.1:100];

scale_factor = 0.05;
y_0 = 0.15;
z_0 = 0.4;

Y = y_0 + scale_factor*(sin(t).*(exp((cos(t))) - 2*cos(4*t) - sin(t/12).^5));
Z = z_0 + scale_factor*(cos(t).*(exp((cos(t))) - 2*cos(4*t) - sin(t/12).^5));

plot(Y, Z);
