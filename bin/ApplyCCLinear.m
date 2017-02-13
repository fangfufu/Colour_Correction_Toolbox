function [ xyz ] = ApplyCCLinear( rgb, ccm )
%% ApplyCCLinear Apply linear colour correction matrix on data
%   Parameters : 
%       rgb : n-times-3 array containing colour triplets, or an 
%             n-times-m-times-3 array containing an image. 
%       ccm : The colour correction matrix.
%
%   Output :
%       xyz : The same dimension as Din, containing the colour corrected
%             data. 
%
%   Reference: 
%   Horn, Berthold KP. "Exact reproduction of colored images." 
%   Computer Vision, Graphics, and Image Processing 26.2 (1984): 135-167.
%
%   Copyright (c) 2016 Fufu Fang <f.fang@uea.ac.uk>, 
%   University of East Anglia
%   Licensed under the MIT License
%

din_size = size(rgb);

if ndims(rgb) == 3
    rgb = reshape(rgb, [], 3);
end

xyz = rgb * ccm;

xyz = reshape(xyz, din_size);

end
