function [ ccm ] = GenCCRootPolynomial( varargin )
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
%   References:
%   Finlayson, Graham D., Michal Mackiewicz, and Anya Hurlbert. 
%   "Color Correction Using Root-Polynomial Regression." 
%   IEEE Transactions on Image Processing 24.5 (2015): 1460-1470.
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
deg = varargin{3};

if nargin == 4
    t_factor = varargin{4};
    
    if ndims(rgb)
        rgb = reshape(rgb, [], 3);
    end

    rgb = SRootPolynomialMat(rgb, deg);
    ccm = (rgb' * rgb + t_factor * eye(size(rgb,2)) ) \ (rgb' * xyz);
else
    disp([mfilename ' ' num2str(deg)]);
    disp('Search for Tikhonov factor...');
    gencc = @(rgb, xyz, tFactor)GenCCRootPolynomial(rgb,xyz,deg,tFactor);
    t_factor = CalcTFactor(rgb, xyz, gencc, @ApplyCCRootPolynomial);
    disp(t_factor);
    ccm = GenCCRootPolynomial( rgb, xyz, deg, t_factor);
end

end
