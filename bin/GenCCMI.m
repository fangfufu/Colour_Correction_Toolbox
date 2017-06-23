function [ ccm ] = GenCCMI( cssf, cmf )
%GENCCMI Generate colour correction matrix using Maximum Ignorance Colour
%Correction
%   Basically a wrapper function for GenCCLinear, for function name
%   consistency

cssf = cssf./max(cssf(:));
cmf = cmf ./ max(cmf(:));

ccm = GenCCLinear(cssf, cmf);

end

