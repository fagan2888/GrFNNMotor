function [ r_star, psi_star ] = getSS(f_osc, f_input, alpha, beta1, beta2, epsilon, F, print_flag)
% 
% getSS: Calculate steady state amplitude and phase 
%        for a given oscillator under periodic forcing
% Author: Wisam Reid
% Email: wisam@ccrma.stanford.edu
% 
% Arguments: 
% 
%           f_osc:  Oscillator Frequency
%         f_input:  Forcing Input Frequency
%           alpha: (Hopf Oscillator Parameter)
%           beta1: (Hopf Oscillator Parameter)
%           beta2: (Hopf Oscillator Parameter)
%         epsilon: (Hopf Oscillator Parameter)
%               F: Forcing Amplitude
%      print_flag: optional
% 
% Returns:
% 
%          r_star: A float, steady state gain
%        psi_star: A float, steady state phase

switch nargin
    case nargin == 7
        print_flag = 1;
    case nargin ~= 8 ||  nargin ~= 7       
        disp('Error running getSS')
        disp('Please provide the right number of arguments')
        disp('Function Call: ')
        disp('getSS(f_osc, f_input, alpha, beta1, beta2, epsilon, F, print_flag)')
        fprintf('\n')
        disp('type "help getSS" for more details')
        fprintf('\n')
        return
end 

if print_flag
    % Display
    disp(['Running getFP:'])
    fprintf('\n')
    disp(['The Oscillator Frequency is: ',num2str(f_osc), ' Hz'])
    disp(['The Input Frequency is: ',num2str(f_input), ' Hz'])
    fprintf('\n')
    disp(['alpha is: ',num2str(alpha)])
    disp(['beta1 is: ',num2str(beta1)])
    disp(['beta2 is: ',num2str(beta2)])
    disp(['epsilon is: ',num2str(epsilon)])
    disp(['F is: ',num2str(F)])
    fprintf('\n')
end    

% calculate Omega
Omega = 2*pi*(f_osc - f_input);

syms r Psi
r_dot = alpha*r + beta1*r^3 + ((epsilon*beta2*r^5)/(1 - epsilon*r^2)) + F*cos(Psi) == 0;
psi_dot = Omega - (F/r)*sin(Psi) == 0;

sol = vpasolve([r_dot, psi_dot], [r, Psi]);

r_star = double(sol.r);
psi_star = double(eval(mod(sol.Psi, 2*pi))); % wrap the phase

% Now we handle each quadrant correctly

% first quadrant
% do nothing

% second quadrant
if psi_star > pi/2 && psi_star < pi
    % do nothing
end

% third quadrant 
if psi_star > pi && psi_star < 3*pi/2
    psi_star = psi_star - pi;
    r_star = -1*r_star;
end

% fourth quadrant 
if psi_star > 3*pi/2
    psi_star = mod(psi_star + pi, 2*pi);
    r_star = -1*r_star;
end

% edge cases
% if psi_star == 0 || psi_star == pi
%    r_star = -1*r_star; 
% end

% % print
% r_star
% psi_star

end

