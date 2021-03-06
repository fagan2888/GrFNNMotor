function [regime, r_local_max, drdt_local_max] = getOscParamRegime(alpha, beta1, beta2, epsilon)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
% getOscParamRegime: 
%         Calculate the bifurcation parameter regime of 
%         an autonomous oscillator 
% 
% Author: Wisam Reid
%  Email: wisam@ccrma.stanford.edu
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
% Function Definition:
% 
%   getOscParamRegime(alpha, beta1, beta2, epsilon)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% 
% Arguments: 
% 
%           alpha:  (float) Hopf Oscillator Parameter
%           beta1:  (float) Hopf Oscillator Parameter
%           beta2:  (float) Hopf Oscillator Parameter
%         epsilon:  (float) Hopf Oscillator Parameter
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% 
% Returns:  [regime, r_local_max, drdt_local_max]
% 
%          regime: integer (0-4)
%                   1: critical Hopf
%                   2: super critical Hopf
%                   3: super critical double limit cycle
%                   4: subcritical double limit cycle 
%                   0: could not be identified
%     r_local_max: (float) r value at the local max 
%  drdt_local_max: (float) dr/dt value at the local max 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%% Handle Arguments

switch nargin
    case nargin ~= 4       
        disp('Error running getOscParamRegime')
        disp('Please provide the right number of arguments')
        disp('Function Call: ')
        disp('getOscParamRegime(alpha, beta1, beta2, epsilon)')
        fprintf('\n')
        disp('type "help getOscParamRegime" for more details')
        fprintf('\n')
        return
end 

if beta2 == 0 && epsilon ~= 0
    % set epsilon = 0 when b2 = 0 to avoid problem in root finding
    epsilon = 0; 
end

%% Determine parameter regime

% initialize at the lowest possible value
local_max = -1*realmax('double');

% Set the derivative of r_dot wrt r equal to zero
local_ext = sqrt(roots([3*epsilon^2*(beta1-beta2),... % local extrema
             epsilon*(epsilon*alpha-6*beta1+5*beta2),...
             -2*epsilon*alpha+3*beta1, ... 
             alpha]));

ind = intersect(find(imag(local_ext)==0),find(local_ext >= 0));
% r value at extremas
r = sort(local_ext(ind)); % use only real values > 0

% Use values within bound for nonzero beta2, epsilon
if epsilon && beta2 
  r = r((r < 1/sqrt(epsilon)));
end

% r
drdt = alpha*r + beta1*r.^3 + beta2*epsilon*r.^5./(1-epsilon*r.^2);

if ~isempty(drdt)
    % find the largest drdt at the extrema
    for i = 1:length(drdt)
        % plug in the largest
        local_max = max(local_max,drdt(i));
    end 
    drdt_local_max = local_max;
    r_local_max = r(1);
else
    drdt_local_max = -1; 
    if isempty(r)
        r_local_max = -1;
    end
    regime = 0;
    fprintf('\n')
    display('Warning: Parameter regime could not be classified')
    display('Use values within bound for nonzero beta2, epsilon')
    return % stop right here  
end 

%% Evaluate Regime

if alpha == 0 && beta1 < 0 && beta2 == 0
    if local_max == 0    
        regime = 1;
    else
        display('Warning: critical Hopf Regime does not have')
        display('a fixed point at 0')
        regime = 0; 
    end
elseif alpha > 0 && beta1 < 0 && beta2 == 0
    if local_max > 0    
        regime = 2;
    else
        display('Warning: supercritical Hopf regime does not have')
        display('a fixed point greater than 0')
        regime = 0; 
    end
elseif alpha < 0 && beta1 > 0 && beta2 < 0
    if local_max > 0    
        regime = 3;
    elseif local_max < 0
        regime = 4;
    else
        display('Warning: Parameter regime could not be classified')
        regime = 0; 
    end
else
   display('Warning: Parameter regime could not be classified')
   regime = 0; 
end

end

