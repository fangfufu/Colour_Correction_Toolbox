function [ t ] = EvaluateAll()
%EVALUATEALL Evaluate all colour correction methods.

%% Load data

load('Michal_New_Castle_Nikon_RGB.mat');
load('Michal_New_Castle_Nikon_XYZ.mat');

load('CIE1931-JuddVos-2-deg.mat');
load('Nikon_CSSF.mat');

%% Run the evaluation functions

% Cross-validation setting
foldInd = crossvalind('KFold',size(XYZ,1), 3); 
% foldInd = [1:size(XYZ,1)]';
% foldInd = GenSquentialFoldInd(size(XYZ,1),3 ); %#ok<NODEF>
% foldInd = [];

% Create an empty table
t = table();
i = 1;

[ cielabE ] = EvalCCRGBXYZ(RGB, XYZ, @GenCCLinear, @ApplyCCLinear, foldInd);
t(i,:) = GenerateTableRow(cielabE, 'Linear least squared');
i = i + 1;

GenCCPoly2 = @(rgb, XYZ) GenCCPolynomial(rgb, XYZ, 2, 0);
[ cielabE ] = EvalCCRGBXYZ(RGB, XYZ, GenCCPoly2, @ApplyCCPolynomial, foldInd);
t(i,:) = GenerateTableRow(cielabE, 'Second order polynomial');
i = i + 1;

GenCCPoly3 = @(rgb, XYZ) GenCCPolynomial(rgb, XYZ, 3);
[ cielabE ] = EvalCCRGBXYZ(RGB, XYZ, GenCCPoly3, @ApplyCCPolynomial, foldInd);
t(i,:) = GenerateTableRow(cielabE, 'Third order polynomial');
i = i + 1;

GenCCRP2 = @(rgb, XYZ) GenCCRootPolynomial(rgb, XYZ, 2, 0);
[ cielabE ] = EvalCCRGBXYZ(RGB, XYZ, GenCCRP2, @ApplyCCRootPolynomial, foldInd);
t(i,:) = GenerateTableRow(cielabE, 'Second order root-polynomial');
i = i + 1;

GenCCRP3 = @(rgb, XYZ) GenCCRootPolynomial(rgb, XYZ, 3);
[ cielabE ] = EvalCCRGBXYZ(RGB, XYZ, GenCCRP3, @ApplyCCRootPolynomial, foldInd);
t(i,:) = GenerateTableRow(cielabE, 'Third order root-polynomial');
i = i + 1;

[ cielabE ] = EvalCCRGBXYZ(RGB, XYZ, @GenCCHomo, @ApplyCCLinear, foldInd);
t(i,:) = GenerateTableRow(cielabE, '2D homography');
i = i + 1;

[ cielabE ] = EvalCCRGBXYZ(RGB, XYZ, @GenCCEnsemble, @ApplyCCEnsemble, foldInd);
t(i,:) = GenerateTableRow(cielabE, 'Ensemble method');
i = i + 1;

[ cielabE ] = EvalCCRGBXYZ(RGB, XYZ, @GenCCHPP, @ApplyCCHPP, foldInd);
t(i,:) = GenerateTableRow(cielabE, 'Hue Plane Preserving');
i = i + 1;

[ cielabE ] = EvalCCRGBXYZ(RGB, XYZ, @GenCCAM, @ApplyCCLinear, foldInd);
t(i,:) = GenerateTableRow(cielabE, 'Angular Minimisation');
i = i + 1;

%% Change data set for maximum ignorance colour correction
load('HanGong_2015_Outdoor_Cloudy_RGB.mat');
load('HanGong_2015_Outdoor_Cloudy_XYZ.mat');

[ cielabE ] = EvalCCRGBXYZMI(RGB, XYZ, cssf, cmf, @GenCCMIP, @ApplyCCLinear, 'cssfWl', cssfWl, 'cmfWl', cmfWl);
t(i,:) = GenerateTableRow(cielabE, 'Maximum Ignorance with Positivity');
i = i + 1;

[ cielabE ] = EvalCCRGBXYZMI(RGB, XYZ, cssf, cmf, @GenCCMI, @ApplyCCLinear, 'cssfWl', cssfWl, 'cmfWl', cmfWl);
t(i,:) = GenerateTableRow(cielabE, 'Maximum Ignorance');
i = i + 1;

%% Display the final table
disp(t);
end

function [t] = GenerateTableRow(cielabE, methodname)
t = table();
t.method(1) = {methodname};
t.mean(1) = mean(cielabE(:)); 
t.median(1) = median(cielabE(:)); 
t.quantile95 = quantile(cielabE(:),0.95); 
t.max = max(cielabE(:));
end
