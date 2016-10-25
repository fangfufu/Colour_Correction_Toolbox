function [ M ] = CCPolynomial( X, Y, deg )
%CCPOLYNOMIAL Summary of this function goes here
%   Solve M for XM = Y

X = GenPolynomialMat(X, deg);
M = X\Y;

end

