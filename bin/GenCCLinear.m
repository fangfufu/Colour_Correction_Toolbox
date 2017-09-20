function [ ccm ] = GenCCLinear(varargin)
%% CCLINEAR Generate linear colour correction matrix
%   Parameters : 
%       rgb : n-times-3 array containing colour triplets, or an 
%             n-times-m-times-3 array containing an image. 
%       xyz : The same dimension as Din, containing the colour corrected
%             data.
%
%   Output :
%       ccm : The colour correction matrix.
%
%   Reference: 
%   Horn, Berthold KP. "Exact reproduction of colored images." 
%   Computer Vision, Graphics, and Image Processing 26.2 (1984): 135-167.
%
%   Copyright (c) 2016 Fufu Fang <f.fang@uea.ac.uk>, 
%   University of East Anglia
%   Licensed under the MIT License

if numel(varargin) == 1
    varargin = varargin{1};
end
nargin = numel(varargin);
rgb = varargin{1};
xyz = varargin{2};

ccm = rgb\xyz;

end

