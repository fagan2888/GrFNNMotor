function [output] = unitpulseSB(time,timeInstantON,timeInstantOFF);
% unitpulseSB: This function can be used in models to implement parameter
%   switches at certain time-instants, allowing the simulation of
%   experimental setups.
% 
% USAGE:
% ======
% [output] = unitpulseSB(time,timeInstantON,timeInstantOFF)
%
% time: momentary simulation time
% timeInstantON: time instant at which the output switches from 0 to 1
% timeInstantOFF: time instant at which the output switches back from 1 to 0
%
% Output Arguments:
% =================
% output: = 0 if time < timeInstantON or time > timeInstantOFF
%         = 1 if timeInstantON <= time <= timeInstant

% Information:
% ============
% Systems Biology Toolbox for MATLAB
% Copyright (C) 2005-2007 Fraunhofer-Chalmers Research Centre
% Author of the toolbox: Henning Schmidt, henning@hschmidt.de
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details. 
% 
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

output = 0;
if time >= timeInstantON && time <= timeInstantOFF,
    output = 1;
end
return