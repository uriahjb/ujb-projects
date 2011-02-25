%LINK create a new LINK object
%
% A LINK object holds all information related to a robot link such as
% kinematics of the joint, rigid-body inertial parameters, motor and
% transmission parameters.
%
%	L = LINK
%	L = LINK(link)
%
% Create a default link, or a clone of the passed link.
%
%	A = LINK(q)
%
% Compute the link transform matrix for the link, given the joint
% variable q.
%
%	L = LINK([alpha A theta D])
% 	L =LINK([alpha A theta D sigma])
% 	L =LINK([alpha A theta D sigma offset])
% 	L =LINK([alpha A theta D], CONVENTION)
% 	L =LINK([alpha A theta D sigma], CONVENTION)
% 	L =LINK([alpha A theta D sigma offset], CONVENTION)
%
% If sigma or offset are not provided they default to zero.  Offset is a
% constant amount added to the joint angle variable before forward kinematics
% and is useful if you want the robot to adopt a 'sensible' pose for zero
% joint angle configuration.
%
% The optional CONVENTION argument is 'standard' for standard D&H parameters 
% or 'modified' for modified D&H parameters.  If not specified the default
% 'standard'.
% Handling the different kinematic conventions is now hidden within the LINK
% object.
%
%
% SEE ALSO: LINK/SUBSREF, LINK/SUBSASGN, SHOWLINK, ROBOT.

% Copyright (C) 1999-2008, by Peter I. Corke
%
% This file is part of The Robotics Toolbox for Matlab (RTB).
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

function l = link(dh, convention)


	if nargin == 0,
		% create an 'empty' link
		l.alpha = 0;
		l.A = 0;
		l.theta = 0;
		l.D = 0;
		l.sigma = 0;
		l.mdh = 0;
		l.offset = 0;
		
    	l = class(l, 'link');

	elseif isa(dh, 'link')
		% clone passed link
		l = dh;
	elseif length(dh) <= 6,
		% legacy DH matrix
		% link([alpha A theta D sigma])

		if length(dh) < 4,
				error('must provide <alpha A theta D> params');
		end
		l.alpha = dh(1);
		l.A = dh(2);
		l.theta = dh(3);
		l.D = dh(4);
		l.sigma = 0;
		if length(dh) >= 5,
			l.sigma = dh(5);
		end
		if nargin > 1
			if strncmp(convention, 'mod', 3) == 1,
				l.mdh = 1;
			elseif strncmp(convention, 'sta', 3) == 1,
				l.mdh = 0;
			else
				error('convention must be modified or standard');
			end
		else
				l.mdh = 0;	% default to standard D&H
		end
		l.offset = 0;
		if length(dh) >= 6,
			l.offset = dh(6);
		end

		l = class(l, 'link');
	
	end
