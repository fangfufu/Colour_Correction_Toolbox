function [ M ] = GenCCPolynomial( rgb, xyz, deg )
%% GenCCPolynomial Summary of this function goes here
%   Solve M for XM = Y
%
% References:
% Hong, Guowei, M. Ronnier Luo, and Peter A. Rhodes. 
% "A study of digital camera colorimetric characterisation based on 
% polynomial modelling." (2001).
%
% Copyright (c) 2016 Fufu Fang <f.fang@uea.ac.uk>, 
% University of East Anglia
% Licensed under the MIT License

if ndims(rgb)
    rgb = reshape(rgb, [], 3);
end

rgb = SPolynomialMat(rgb, deg);
M = rgb\xyz;

end

