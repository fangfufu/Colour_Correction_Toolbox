function [ ccm ] = GenCCHPP( rgb, xyz )
%% GENCCHPP Wrapper function for Hue Plane Preserving Colour Correction
%   Detailed explanation goes here

%% Load settings
load('/home/fangfufu/UEA/Colour_Correction_Toolbox/bin/nhppcc-toolbox/settings.mat', ...
	'partitions', 'WPP_flag', 'sep_deg', 'reqNoPatches');

%% Reshape input file
if ndims(rgb)
    rgb = reshape(rgb, [], 3);
end

%% Generate colour correction matrix
[ccm.wp, w_idx] = GetWpFromColourChecker(rgb);
[mat, ~, ind] = colour_correction_NHPPCC(rgb, xyz, w_idx, partitions, WPP_flag, ...
    sep_deg, reqNoPatches);
ccm.mat = mat;
ccm.ind = ind;

end

