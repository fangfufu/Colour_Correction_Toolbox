function [ xyz ] = ApplyCCPolynomial( rgb, ccm )
%% ApplyCCPolynomial Apply colour correction matrix on an image
% Apple colour correction algorithm on a data matrix
%   Parameters : 
%       rgb : n-times-3 array containing colour triplets, or an 
%             n-times-m-times-3 array containing an image. 
%       xyz : The same dimension as rgb, containing the colour corrected
%             data. 
%       ccm : The colour correction matrix.
%
% References:
% Hong, Guowei, M. Ronnier Luo, and Peter A. Rhodes. 
% "A study of digital camera colorimetric characterisation based on 
% polynomial modelling." (2001).
%
% Copyright (c) 2016 Fufu Fang <f.fang@uea.ac.uk>, 
% University of East Anglia
% Licensed under the MIT License

e_invalid_ccm_size = struct();
e_invalid_ccm_size.identifier = 'ApplyCCPolynomial:invalid_ccm_size';
e_invalid_ccm_size.message = ...
    ['The dimension of the colour correction matrix is ', ...
    'incorrect, are you sure you want to use polynomail ', ...
    'colour correction?'];


din_size = size(rgb);

if ndims(rgb)
    rgb = reshape(rgb, [], 3);
end

if size(ccm, 2) == 3
    switch size(ccm, 1)
        case 3
            deg = 1;
        case 9
            deg = 2;
        case 19
            deg = 3;
        case 34
            deg = 4;
        otherwise
            error(e_invalid_ccm_size);
    end
else
    error(e_invalid_ccm_size);
end

rgb_x = SPolynomialMat(rgb, deg);

xyz = rgb_x * ccm;

xyz = reshape(xyz, din_size);

end
