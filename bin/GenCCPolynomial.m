function [ ccm ] = GenCCPolynomial( rgb, xyz, deg )
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

if ndims(rgb)
    rgb = reshape(rgb, [], 3);
end

rgb_x = SPolynomialMat(rgb, deg);
ccm = rgb_x\xyz;

end

