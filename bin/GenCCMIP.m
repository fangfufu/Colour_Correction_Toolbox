function [ m ] = GenCCMIP(cssf, cmf)
%MIP Maximum Ignorance Colour Correction with Positivity
%   %   [ m ] = GenCCMIP(cssf, cmf)
%   
%   Parameters
%       cssf : camera spectral sensitivity function
%       cmf : standard observer colour matching function
%
%       Both cssf and cmf are in the format of wavelengths-times-channel
%
%   Reference:
%       Finlayson, Graham D., and Mark S. Drew. 
%       "The maximum ignorance assumption with positivity." 
%       Color and Imaging Conference. Vol. 1996. No. 1. 
%       Society for Imaging Science and Technology, 1996.
%
%   Linear regression while enforcing individual independent variable to 
%   be strictly positive

cssf = cssf./max(cssf(:));
cmf = cmf ./ max(cmf(:));

llt = pos_ident_mat(max(size(cmf)));
m = cmf' * llt * cssf * inv(cssf' * llt * cssf);

end

function [ mat ] = pos_ident_mat( s )
%POS_IDENT_MAT Construct a positive identiy matrix
mat = ones(s)/4;
mat(logical(eye(s))) = 1/3;
end
