function [r_star, psi_star, stability_type, regime] = getFP(f_osc, f_input, alpha, beta1, beta2, epsilon, F, display_flag)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
%     getFP: Calculate fixed points for a given oscillator
%            under periodic forcing
% 
%    Author: Wisam Reid
%     Email: wisam@ccrma.stanford.edu
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
% Function Definition:
% 
%   getFP(f_osc, f_input, alpha, beta1, beta2, epsilon, F, display_flag)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
% Arguments: 
% 
%           f_osc:  (float) Oscillator Frequency
%         f_input:  (float) Forcing Input Frequency
%           alpha:  (float) Hopf Oscillator Parameter
%           beta1:  (float) Hopf Oscillator Parameter
%           beta2:  (float) Hopf Oscillator Parameter
%         epsilon:  (float) Hopf Oscillator Parameter
%               F:  (float) Forcing Amplitude
%    display_flag:  [optional] (boolean) print to console
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
%   Returns: [r_star, psi_star, stability_type, regime]
% 
%          r_star: (float) steady state gain
%        psi_star: (float) steady state phase
%  stability_type: (integer) [0-5]
%                   1: stable node
%                   2: stable spiral
%                   3: unstable node
%                   4: unstable spiral
%                   5: a saddle point
%                   0: could not be identified
%          regime: (integer) [0-4]
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Handle arguments

switch nargin 
    case nargin < 7 || nargin > 8
        disp('Error running getFP')
        disp('Please provide the right number of arguments')
        disp('Function Call: ')
        disp('getFP(f_osc, f_input, alpha, beta1, beta2, epsilon, F, display_flag [optional])')
        fprintf('\n')
        disp('type "help getFP" for more details')
        fprintf('\n')
        return
end 

if nargin == 7
    display_flag = 0; % display default
end 

%% Parameter Displays   
 
if display_flag
    fprintf('\n')
    disp(['----------------'])
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

%% Oscillator Parameter Regime

% type 'help getOscParamRegime' for more info
regime = getOscParamRegime(alpha, beta1, beta2, epsilon);

%% Calculate the steady state amplitude and phase values

[r_star, psi_star] = getSS(f_osc, f_input, alpha, beta1, beta2, epsilon, F, 0);

numFP = length(r_star);
stability_type = zeros(length(r_star),1);

%% Calculate the Jacobian
%  Trace, Determinant, and Discriminant 
% See Kim & Large 2015 pg 4
% 
% partial derivative r_dot wrt r
if F
    dpdr = alpha + 3*beta1*r_star.^2 + ...
            ((epsilon*beta2*r_star.^4.*(5 - 3*epsilon*r_star.^2))./ ...
            (1 - epsilon*r_star.^2).^2); 
    % partial derivative r_dot wrt psi
    dpdP = -F*sin(psi_star);
    % partial derivative psi_dot wrt r
    dqdr = (F./r_star.^2).*sin(psi_star);
    % partial derivative psi_dot wrt psi
    dqdP = -1*(F./r_star).*cos(psi_star);

    % the Jacobian
    J = [dpdr, dpdP; ...
                dqdr, dqdP];

    Delta = dpdr.*dqdP - dpdP.*dqdr; % determinant of J
    T = dpdr + dqdP; % trace of J
    chDet = T.^2 - 4*Delta; % determinant of characteristic eq

else
    
    %%%%%% Characterize stability at r* for autonomous oscillators %%%%%%
    
    %%% Find Stable Nodes
    
    % r_dot/dr neg slopes : stable FP
    ind_stable = find(getDrdotdr(r_star,alpha,beta1,beta2,epsilon) < 0);
    % r_dot/dr zero slopes with surrounding neg: marginally stable FP
    ind_stable_zero_slope = find(getDrdotdr(r_star,alpha,beta1,beta2,epsilon) == 0);
    ind_marginally_stable_left = find(getDrdotdr(r_star-eps('single'),alpha,beta1,beta2,epsilon) < 0);
    ind_marginally_stable_right = find(getDrdotdr(r_star+eps('single'),alpha,beta1,beta2,epsilon) < 0);
    % keep the 
    ind_marginally_stable = intersect(ind_stable_zero_slope, ...
                            intersect(ind_marginally_stable_left,ind_marginally_stable_right));
    
    ind_stable = union(ind_stable,ind_marginally_stable); 
%     r_stable = r_star([ind_stable; ind_marginally_stable]);
%     r_stable = sort(r_stable,'descend'); % final sorted indices for stable FPs
    
    %%% Find Unstable Nodes
    
    ind_unstable = find(getDrdotdr(r_star-eps('single'),alpha,beta1,beta2,epsilon) > 0);
%     r_unstable = r_star(ind_unstable);
%     r_unstable = sort(r_unstable,'descend'); % final sorted indices for unstable FPs

    
end

%% Displays

for i = 1:numFP
    if F
        if Delta(i) > 0 && chDet(i) > 0 && T(i) < 0;
            stability_type(i) = 1;
            if display_flag
                disp(['R_Star is: ', num2str(r_star(i))])
                disp(['Psi_Star is: ', num2str(psi_star(i))])
                disp(['The fixed point ',num2str(i),' is a stable node'])
                fprintf('\n')
            end
        elseif Delta(i) > 0 && chDet(i) < 0 && T(i) < 0;
            stability_type(i) = 2;
            if display_flag
                disp(['R_Star is: ', num2str(r_star(i))])
                disp(['Psi_Star is: ', num2str(psi_star(i))])        
                disp(['The fixed point ',num2str(i),' is a stable spiral'])
                fprintf('\n')
            end
        elseif Delta(i) > 0 && chDet(i) > 0 && T(i) > 0;
            stability_type(i) = 3;
            if display_flag
                disp(['R_Star is: ', num2str(r_star(i))])
                disp(['Psi_Star is: ', num2str(psi_star(i))])        
                disp(['The fixed point ',num2str(i),' is a unstable node'])
                fprintf('\n')
            end
        elseif Delta(i) > 0 && chDet(i) < 0 && T(i) > 0;
            stability_type(i) = 4;
            if display_flag
                disp(['R_Star is: ', num2str(r_star(i))])
                disp(['Psi_Star is: ', num2str(psi_star(i))])        
                disp(['The fixed point ',num2str(i),' is a unstable spiral'])
                fprintf('\n')
            end
        elseif Delta(i) < 0;
            stability_type(i) = 5;
            if display_flag        
                disp(['R_Star is: ', num2str(r_star(i))])
                disp(['Psi_Star is: ', num2str(psi_star(i))])
                disp(['The fixed point ',num2str(i),' is a saddle point'])
                disp('<< See Strogatz 1994 >>')
                fprintf('\n')
            end
        else 
            stability_type(i) = 0;
            if display_flag
                disp(['R_Star is: ', num2str(r_star(i))])
                disp(['Psi_Star is: ', num2str(psi_star(i))])
                disp(['The fixed point ',num2str(i),' could not be identified'])
                fprintf('\n')
            end
        end
    
    else
        % assign stabile/unstable values for autonomous osc FPs
        % 1 = stable, 3 = unstable
        stability_type(ind_stable) = 1;
        stability_type(ind_unstable) = 3;
        
    end
end

if display_flag
    disp('----------------')
end
% %% Prepare output
% if All % both stable and unstable fixed points
%   rStar = r;
%   psiStar = psi;
% else % only stable fixed points
%   indStab = find(stability);
%   rStar = r(indStab);
%   psiStar = psi(indStab);
%   stability = stability(indStab);
%   stabType = stabType(indStab);
% end

% ========================================================
function drdotdr = getDrdotdr(r, a, b1, b2, e)
    % function for finding the slope of the amplitude vector field (r_dot vs r) 
    drdotdr = a + 3*b1*r.^2 + (5*e*b2*r.^4-3*e^2*b2*r.^6)./((1-e*r.^2).^2);
end
end

