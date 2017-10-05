function [ xyz ] = ApplyCCHPP( rgb, ccm )
%APPLYCCHPP Wrapper function 
%   Detailed explanation goes here

%% Load settings
load('/home/fangfufu/UEA/Colour_Correction_Toolbox/bin/nhppcc-toolbox/settings.mat', ...
    'partitions', 'WPP_flag', 'sep_deg', 'reqNoPatches');

%% Reshape input
din_size = size(rgb);

if ndims(rgb)
    rgb = reshape(rgb, [], 3);
end

%% Normalise RGB input
rgb = rgb ./ repmat(ccm.WP, size(rgb, 1), 1);

%% Apply colour correction algorithm
HA = RGB2HueAngleWithoutNorm(rgb);
ind = HA2Partition(HA, ccm.BH);
[xyz] = conversionCameraHPPCC(ccm.MAT, ind, rgb);

%% Reshape output
xyz = reshape(xyz, din_size);

end

