function [ M ] = GenCCLinear( rgb, xyz )
%CCLINEAR Generate linear colour correction matrix
%   Solve M for XM = Y
%       where M is a 3x3 matrix,
%             X is a 3xn matrix,
%             Y is a 3xn matrix.
%
% Copyright (c) 2016 Fufu Fang <f.fang@uea.ac.uk>, 
% University of East Anglia
% Licensed under the MIT License

M = rgb\xyz;

end

