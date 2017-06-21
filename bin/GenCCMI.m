function [ ccm ] = GenCCMI( rgb, xyz )
%GENCCMI Generate colour correction matrix using Maximum Ignorance Colour
%Correction
%   Basically a wrapper function for GenCCLinear, for function name
%   consistency

ccm = GenCCLinear(rgb, xyz);

end

