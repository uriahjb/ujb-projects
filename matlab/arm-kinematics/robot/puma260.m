%PUM260 Load kinematic and dynamic data for a Puma 560 manipulator
%
%	PUMA260
%
% Defines the object 'p260' in the current workspace which describes the 
% kinematic and dynamic characterstics of a Unimation Puma 260 manipulator
% using standard DH conventions.
% The model includes armature inertia and gear ratios.
%
% Also define the vector qz which corresponds to the zero joint
% angle configuration, qr which is the vertical 'READY' configuration,
% and qstretch in which the arm is stretched out in the X direction.
%
% See also: ROBOT, PUMA260AKB, STANFORD, TWOLINK.

%
% Notes:
%
% $Log: not supported by cvs2svn $
% Revision 1.0  2008/04/27 11:36:54  cor134
% Add nominal (non singular) pose qn

% Copyright (C) 1993-2008, by Peter I. Corke
% Puma 260 by Uriah Baalke
%
% This file is NOT part of The Robotics Toolbox for Matlab (RTB).
% 
% RTB is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% RTB is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
% 
% You should have received a copy of the GNU Leser General Public License
% along with RTB.  If not, see <http://www.gnu.org/licenses/>.

clear L
L{1} = link([ pi/2   0.0	0	13.0], 'standard');
L{2} = link([ 0.0    8.0	0	-2.5], 'standard');
L{3} = link([ -pi/2  0.0	0	-2.5], 'standard');
L{4} = link([ pi/2   0.0	0    8.0], 'standard');
L{5} = link([ -pi/2  0.0    0    0.0], 'standard');
L{6} = link([ 0.0    0.0    0    7.25], 'standard');
 
qz = [0, 0, 0, 0, -pi/2, pi]; % zero angles, L shaped pose

p260 = robot(L, 'Puma 260', 'Unimation', 'params of 8/95');
clear L
p260.name = 'Puma 260';
p260.manuf = 'Unimation';
