function [ t ] = EvaluateAll()
%EVALUATEALL Evaluate all colour correction methods.

% The prototype of the functions used 
%  [ cielabE ] = EvalCCFunc(rgb, XYZ, genCC, applyCC, wp, foldInd);

%% Load data

% load('/home/fangfufu/UEA/Colour_Correction_Toolbox/data/AppleDemo/100AA___/D65_Standard_Exposure/D65_standard.mat');
% 
% load(...
%     '/home/fangfufu/UEA/Colour_Correction_Toolbox/data/HanGongCollection/HanGong24Macbeter_cc_capture/extracted_rgb_xyz_fufu.mat', ...
%     'rgb_2015', 'xyz_2015', 'xyz_2017');
% 
% load(...
%     '/home/fangfufu/UEA/Colour_Correction_Toolbox/data/Images taken in Newcastle for RootPoly/extracted_rgb_xyz.mat', ...
%     'new_castle_macbeth_xyz', 'new_castle_xyz_transposed', 'new_castle_rgb_transposed');
% 
% RGB = new_castle_xyz_transposed;
% XYZ = new_castle_rgb_transposed;
load('/home/fangfufu/UEA/Colour_Correction_Toolbox/bin/nhppcc-toolbox/anonymousTestData.mat')

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

% GenCCPoly2 = @(rgb, XYZ) GenCCPolynomial(rgb, XYZ, 2);
% [ cielabE ] = EvalCCRGBXYZ(RGB, XYZ, GenCCPoly2, @ApplyCCPolynomial, foldInd);
% t(i,:) = GenerateTableRow(cielabE, 'Second order polynomial');
% i = i + 1;
% 
GenCCPoly3 = @(rgb, XYZ) GenCCPolynomial(rgb, XYZ, 3);
[ cielabE ] = EvalCCRGBXYZ(RGB, XYZ, GenCCPoly3, @ApplyCCPolynomial, foldInd);
t(i,:) = GenerateTableRow(cielabE, 'Third order polynomial');
i = i + 1;
% 
% GenCCRP2 = @(rgb, XYZ) GenCCRootPolynomial(rgb, XYZ, 2);
% [ cielabE ] = EvalCCRGBXYZ(RGB, XYZ, GenCCRP2, @ApplyCCRootPolynomial, foldInd);
% t(i,:) = GenerateTableRow(cielabE, 'Second order root-polynomial');
% i = i + 1;
% 
GenCCRP3 = @(rgb, XYZ) GenCCRootPolynomial(rgb, XYZ, 3);
[ cielabE ] = EvalCCRGBXYZ(RGB, XYZ, GenCCRP3, @ApplyCCRootPolynomial, foldInd);
t(i,:) = GenerateTableRow(cielabE, 'Third order root-polynomial');
i = i + 1;
% 
% [ cielabE ] = EvalCCRGBXYZ(RGB, XYZ, @GenCCHomo, @ApplyCCLinear, foldInd);
% t(i,:) = GenerateTableRow(cielabE, '2D homography');
% i = i + 1;
% 
% [ cielabE ] = EvalCCRGBXYZ(RGB, XYZ, @GenCCEnsemble, @ApplyCCEnsemble, foldInd);
% t(i,:) = GenerateTableRow(cielabE, 'Ensemble method');
% i = i + 1;

[ cielabE ] = EvalCCRGBXYZ(RGB, XYZ, @GenCCHPP, @ApplyCCHPP, foldInd);
t(i,:) = GenerateTableRow(cielabE, 'Hue Plane Preserving');
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