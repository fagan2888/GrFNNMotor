% Multi-variable linear auto-regression.
% By solving Yule–Walker equation.
% Using covariances R = [R(0), R(1),..., R(m)], R(j)=E( X(t)*X(t-j)' )
%
% Time cost: O((p*m)^3)
% RAM  cost: O((p*m)^2)

function [Aall, Deps] = ARregression(R)

[p, m] = size(R);
m = round(m/p)-1;

RR = zeros(p,p*(2*m-1));
RR(:, m*p-p+1:end) = R(:,1:m*p);
for k = 1 : m-1
    RR(:,(m-k)*p-p+1:(m-k)*p) = R(:,k*p+1:k*p+p)';
end
% construct the big covariance matrix
covz = zeros(p*m, p*m);
for k = 0 : m-1
    covz(k*p+1:k*p+p, :) = RR(:, (m-k)*p-p+1 : (m+m-k)*p-p );
end

Rb = -R(:,1+p:p+p*m)';           % nonhomogeneous item
Aall = (covz \ Rb)';             % solve all-jointed regression, covz * Aall' = Rb
Deps = R(:,1:p) - Aall*Rb;       % variance matrix of noise term
if (p>1)
  bad_id = Deps<0 & eye(p)==1;
  if sum(bad_id(:)) > 0
    warning('GC_clean: ARregression(): non-positive defined!');
  end
end

end
