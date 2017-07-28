function [ M ] = ResolveScalingAmbiguity(M, rgb, xyz)
%% RESOLVESCALINGAMBIGUITY Resolving scaling ambiguity for CCM
cam_xyz = rgb * M;
sf = GetScale(xyz, cam_xyz);
M = eye(3) * sf * M;
end
