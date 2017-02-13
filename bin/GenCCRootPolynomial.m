function [ ccm ] = GenCCRootPolynomial( rgb, xyz, deg, t_factor )
%% GenCCRootPolynomial Generate root Polynomial Colour Correction Matrix
%   Parameters :
%       rgb : n-times-3 array containing colour triplets, or an 
%             n-times-m-times-3 array containing an image. 
%       xyz : The same dimension as Din, containing the colour corrected
%             data. 
%       deg : The degree of polynomial
%
%   Output : 
%       ccm : The colour correction matrix
%
%
%   References:
%   Finlayson, Graham D., Michal Mackiewicz, and Anya Hurlbert. 
%   "Color Correction Using Root-Polynomial Regression." 
%   IEEE Transactions on Image Processing 24.5 (2015): 1460-1470.
%
%   Copyright (c) 2016 Fufu Fang <f.fang@uea.ac.uk>, 
%   University of East Anglia
%   Licensed under the MIT License

if ndims(rgb)
    rgb = reshape(rgb, [], 3);
end

if ~exist('t_factor', 'var')
    t_factor = 0;
end

rgb = SRootPolynomialMat(rgb, deg);
ccm = (rgb' * rgb + t_factor * eye(size(rgb,2)) ) \ (rgb' * xyz);

end
