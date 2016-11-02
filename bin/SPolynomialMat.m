function [ N ] = SPolynomialMat( M, deg )
%% SPolynomialMat Generate a polynomial matrix
% Support function for generating polynomial matrices, it is used by
% GenCCPolynomial() and ApplyCCPolynomial(). The user is not expected to
% call this function directly.
%
%   References:
%   Hong, Guowei, M. Ronnier Luo, and Peter A. Rhodes. 
%   "A study of digital camera colorimetric characterisation based on 
%   polynomial modelling." (2001).
%
%   Copyright (c) 2016 Fufu Fang <f.fang@uea.ac.uk>, 
%   University of East Anglia
%   Licensed under the MIT License

r = M(:,1);
g = M(:,2);
b = M(:,3);

switch deg
    case 1
        N = [r, g, b];
    case 2
        N = [r, g, b, [r.*r, r.*g, r.*b, g.*g, g.*b, b.*b]];
    case 3
        N = [r, g, b, [r.*r, r.*g, r.*b, g.*g, g.*b, b.*b], ...
            [r.*r.*r, r.*r.*g, r.*r.*b, r.*g.*g, r.*g.*b, ...
            r.*b.*b, g.*g.*g, g.*g.*b, g.*b.*b, b.*b.*b]];
    case 4
        N = [r, g, b, [r.*r, r.*g, r.*b, g.*g, g.*b, b.*b], ...
            [r.*r.*r, r.*r.*g, r.*r.*b, r.*g.*g, r.*g.*b, r.*b.*b, ...
            g.*g.*g, g.*g.*b, g.*b.*b, b.*b.*b], [b.*b.*b.*b, ...
            g.*b.*b.*b, g.*g.*b.*b, g.*g.*g.*b, g.*g.*g.*g, r.*b.*b.*b, ...
            r.*g.*b.*b, r.*g.*g.*b, r.*g.*g.*g, r.*r.*b.*b, r.*r.*g.*b, ...
            r.*r.*g.*g, r.*r.*r.*b, r.*r.*r.*g, r.*r.*r.*r]];
    otherwise
        error('GEN_POLYNOMIAL_VECTOR:: Invalid degree count!');
end

end
