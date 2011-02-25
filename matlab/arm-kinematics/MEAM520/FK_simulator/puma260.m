%PUMA260 Load kinematic data for a Puma 260 manipulator
%Arunkumar Byravan & Mike Shomin
%University of Pennsylvania
%based on puma560.m
%PUMA 260

clear all
close all

% PUMA260 constants
a = 13.0*0.0254;
b = 2.5*0.0254;
c = 8.0*0.0254;
d = 2.5*0.0254;
e = 8.0*0.0254;
f = 2.5*0.0254;
g = 0.5*0.0254;
h = 1.1*0.0254;

off = [ 0 c 0 0 0 0 ];
d = [ a -b -d e 0 f ];
alph = [ pi/2 0 -pi/2 pi/2 pi/2 0 ] ;

%             alpha / a / theta / d / 0
L{1} = link([ alph(1) off(1) 0 d(1) 0], 'standard');
L{2} = link([ alph(2) off(2) 0 d(2) 0], 'standard');
L{3} = link([ alph(3) off(3) 0 d(3) 0], 'standard');
L{4} = link([ alph(4) off(4) 0 d(4) 0], 'standard');
L{5} = link([ alph(5) off(5) 0 d(5) 0 pi/2], 'standard');
L{6} = link([ alph(6) off(6) 0 d(6) 0], 'standard');

global puma;
puma = robot(L, 'Puma 260', 'Unimation', 'params of 3/2010');
clear L
puma.name = 'Puma 260';
puma.manuf = 'Unimation';
puma.tool = [1 0 0 0; 0 0 -1 -h; 0 1 0 g; 0 0 0 1]; % for the LED holder

qz = [0 0 0 0 0 0]; % zero angles, L shaped pose
r = plotrobot(puma,qz);

