function [ meanCielabE ] = CalcMeanCielabE(rgb, xyz, genCC, applyCC, ...
    tFactor)
%% Calculate the mean CIELAB error given a Tikhonov parameter
nPatch = size(rgb, 1);
cielabMat = [];
thisGenCC = @(rgb, xyz) genCC(rgb, xyz, tFactor);
for i = 1:nPatch
    ind = GenLeaveOneOutMask(nPatch, i);
    cielabMat = [cielabMat ; ...
        EvalCCRGBXYZ(rgb, xyz, thisGenCC, applyCC, ind)]; %#ok<AGROW>
end
meanCielabE = mean(cielabMat);
% disp(['t: ', num2str(tFactor), 'e: ', num2str(meanCielabE)]);
end