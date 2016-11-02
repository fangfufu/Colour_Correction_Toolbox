function [ xyz ] = ApplyCCLinear( rgb, ccm )
%% APPLYCC Apply colour correction matrix on an image
% Apple colour correction algorithm on a data matrix
%   Parameters : 
%       Din : n-times-3 array containing colour triplets, or an 
%             n-times-m-times-3 array containing an image. 
%       Dout : The same dimension as Din, containing the colour corrected
%             data. 
%       ccm : The colour correction matrix.
%
% Copyright (c) 2016 Fufu Fang <f.fang@uea.ac.uk>, 
% University of East Anglia
% Licensed under the MIT License

din_size = size(rgb);

if ndims(rgb)
    rgb = reshape(rgb, [], 3);
end

xyz = rgb * ccm;

xyz = reshape(xyz, din_size);

end
