function [ M ] = CCRootPolynomial( X, Y, deg )
%CCROOTPOLYNOMIAL Summary of this function goes here
%   Solve M for XM = Y

X = GenRootPolynomialMat(X, deg);
M = X\Y;

end

