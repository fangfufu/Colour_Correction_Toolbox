function [ xyz ] = ApplyCCRootPolynomial( rgb, ccm )
%% ApplyCCRootPolynomial Apply root-polynomial colour correction on data
%   Parameters : 
%       rgb : n-times-3 array containing colour triplets, or an 
%             n-times-m-times-3 array containing an image. 
%       ccm : The colour correction matrix.
%
%   Output :
%       xyz : The same dimension as rgb, containing the colour corrected
%             data. 
%
%   References:
%   Finlayson, Graham D., Michal Mackiewicz, and Anya Hurlbert. 
%   "Color Correction Using Root-Polynomial Regression." 
%   IEEE Transactions on Image Processing 24.5 (2015): 1460-1470.
%
%   Copyright (c) 2016 Fufu Fang <f.fang@uea.ac.uk>, 
%   University of East Anglia
%   Licensed under the MIT License

e_invalid_ccm_size = struct();
e_invalid_ccm_size.identifier = 'ApplyCCRootPolynomial:invalid_ccm_size';
e_invalid_ccm_size.message = ...
    ['The dimension of the colour correction matrix is ', ...
    'incorrect, are you sure you want to use root polynomail ', ...
    'colour correction?'];


din_size = size(rgb);

if ndims(rgb)
    rgb = reshape(rgb, [], 3);
end

if size(ccm, 2) == 3
    switch size(ccm, 1)
        case 3
            deg = 1;
        case 6
            deg = 2;
        case 13
            deg = 3;
        case 22
            deg = 4;
        otherwise
            error(e_invalid_ccm_size);
    end
else
    error(e_invalid_ccm_size);
end

rgb_x = SRootPolynomialMat(rgb, deg);

xyz = rgb_x * ccm;

xyz = reshape(xyz, din_size);

end
