function [ M ] = GenCCRootPolynomial( rgb, xyz, deg )
%CCROOTPOLYNOMIAL Summary of this function goes here
%   Solve M for XM = Y
%
% Copyright (c) 2016 Fufu Fang <f.fang@uea.ac.uk>, 
% University of East Anglia
% Licensed under the MIT License

rgb = SRootPolynomialMat(rgb, deg);
M = rgb\xyz;

end
