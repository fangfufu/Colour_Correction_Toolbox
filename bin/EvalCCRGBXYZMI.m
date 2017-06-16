function [ cie ] = EvalCCRGBXYZMI( varargin )
%% EVALCCRGBXYZMI Evaluate a maximum ignorance colour correction function
%   [ cielabE ] = EvalCCRGBXYZMI( rgb, xyz, cssf, cmf, genCC, applyCC)
%
%   Required parameters:
%       rgb : A n-times-3 matrix containing RGB response of the cameras, 
%           n being the
%       xyz : A n-times-3 matrix containing the  corresponding tristimulus
%           values. 
%       cssf : Camera spectral sensitivity function
%       cmf :   Colour matching function
%       genCC : The function for generation colour correction matrix
%       applyCC : The function for applying colour correction matrix
%
%   Name-value parameters:
%       cssfWl : The sampling wavelength for the camera spectral
%       sensitivity function
%       cmfWl : The sampling wavelength for the colour matching function


end

