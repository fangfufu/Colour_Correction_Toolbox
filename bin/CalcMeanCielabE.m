function [ meanCielabE ] = CalcMeanCielabE(rgb, xyz, wp, genCC, ...
    applyCC, tFactor)
%% Calculate the mean CIELAB error given a Tikhonov parameter
nPatch = size(rgb, 1);
cielabMat = [];
thisGenCC = @(rgb, xyz) genCC(rgb, xyz, tFactor);
for i = 1:nPatch
    ind = GenLeaveOneOutMask(nPatch, i);
    cielabMat = [cielabMat ; ...
        EvalCCRGBXYZ(rgb, xyz, wp, thisGenCC, applyCC, ind)]; %#ok<AGROW>
end
meanCielabE = mean(cielabMat);
end