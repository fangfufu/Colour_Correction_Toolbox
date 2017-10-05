function [ ccm ] = GenCCPolynomial( varargin )
%% GenCCPolynomial Generate Polynomial Colour Correction Matrix
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
%   Hong, Guowei, M. Ronnier Luo, and Peter A. Rhodes. 
%   "A study of digital camera colorimetric characterisation based on 
%   polynomial modelling." (2001).
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
    
    rgb_x = SPolynomialMat(rgb, deg);
    ccm = (rgb_x' * rgb_x + t_factor * eye(size(rgb_x,2)) ) \ (rgb_x' * xyz);
else
    disp([mfilename ' ' num2str(deg)]);
    disp('Search for Tikhonov factor...');
    gencc = @(rgb, xyz, tFactor)GenCCPolynomial(rgb,xyz,deg,tFactor);
    t_factor = CalcTFactor(rgb, xyz, gencc, @ApplyCCPolynomial);
    disp(t_factor);
    ccm = GenCCPolynomial( rgb, xyz, deg, t_factor);
end

end

