function [ meanCielabE ] = CalcMeanCielabE(rgb, xyz, wp, genCC, ...
    applyCC, tFactor)
%% Calculate the mean CIELAB error given a Tikhonov parameter
nPatch = size(rgb, 1);
cielabMat = size(rgb, 1);
thisGenCC = @(rgb, xyz) genCC(rgb, xyz, tFactor);
for i = 1:nPatch
    ind = GenLeaveOneOutInd(nPatch, i);
    cielabMat(i) = EvalCCRGBXYZ(rgb, xyz, wp, thisGenCC, applyCC, ind);
end
meanCielabE = mean(cielabMat);
end