% the probability density function of noncentral chi-squared distribution

function p = chi2_pdf(x,k,c)
  if ~exist('c','var') || c==0
    p = chi2pdf(x, k);
    return
  end
  p = 0.5*exp(-0.5*(x+c)) .* (x./c).^(k/4-1/2) .* besseli(k/2-1, sqrt(c*x));
end
