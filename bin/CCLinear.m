function [ M ] = CCLinear( X, Y )
%CCLINEAR Generate linear colour correction matrix
%   Solve M for XM = Y
%       where M is a 3x3 matrix,
%             X is a 3xn matrix,
%             Y is a 3xn matrix.

M = X\Y;

end

