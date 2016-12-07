function [ t ] = EvaluateAll(  )
%EVALUATEALL Evaluate all colour correction methods.

% The prototype of the functions used 
%  [ cielabE ] = EvalCCFunc(rgb, xyz, genCC, applyCC, wp, foldCount);

%% Load data
% The RGB
load('/home/fangfufu/UEA/Colour_Correction_Toolbox/data/Nikon/DSC_0005.mat');
% The XYZ
load('/home/fangfufu/UEA/Colour_Correction_Toolbox/data/D65_SG_Colour_Chart.mat');

%% Run the evaluation functions
% Cross-validation setting
foldCount = 3;
disp('foldCount');
disp(foldCount);
wp = new_xyz(40,:); %#ok<NODEF>

% Create an empty table
t = table();
i = 1;

% Linear least squared
[ cielabE ] = EvalCCRGBXYZ(rgb_shading, new_xyz, wp, @GenCCLinear, @ApplyCCLinear, foldCount);
t(i,:) = GenerateTableRow(cielabE, 'Linear least squared');
i = i + 1;

% Second degree polynomial
GenCCPoly2 = @(rgb, xyz) GenCCPolynomial(rgb, xyz, 2);
[ cielabE ] = EvalCCRGBXYZ(rgb_shading, new_xyz, wp, GenCCPoly2, @ApplyCCPolynomial, foldCount);
t(i,:) = GenerateTableRow(cielabE, 'Second order polynomial');
i = i + 1;

% Second degree polynomial
GenCCPoly3 = @(rgb, xyz) GenCCPolynomial(rgb, xyz, 3);
[ cielabE ] = EvalCCRGBXYZ(rgb_shading, new_xyz, wp, GenCCPoly3, @ApplyCCPolynomial, foldCount);
t(i,:) = GenerateTableRow(cielabE, 'Third order polynomial');
i = i + 1;


GenCCRP2 = @(rgb, xyz) GenCCRootPolynomial(rgb, xyz, 2);
[ cielabE ] = EvalCCRGBXYZ(rgb_shading, new_xyz, wp, GenCCRP2, @ApplyCCRootPolynomial, foldCount);
t(i,:) = GenerateTableRow(cielabE, 'Second order root-polynomial');
i = i + 1;

GenCCRP3 = @(rgb, xyz) GenCCRootPolynomial(rgb, xyz, 3);
[ cielabE ] = EvalCCRGBXYZ(rgb_shading, new_xyz, wp, GenCCRP3, @ApplyCCRootPolynomial, foldCount);
t(i,:) = GenerateTableRow(cielabE, 'Third order root-polynomial');
i = i + 1;

[ cielabE ] = EvalCCRGBXYZ(rgb_shading, new_xyz, wp, @GenCCALS, @ApplyCCLinear, foldCount);
t(i,:) = GenerateTableRow(cielabE, 'Alternating Least Squared');
i = i + 1;

% [ cielabE ] = EvalCCRGBXYZ(rgb_shading, new_xyz, wp, @GenCCAM, @ApplyCCLinear, foldCount);
% t(i,:) = GenerateTableRow(cielabE, 'Angular minimisation');
% i = i + 1;

[ cielabE ] = EvalCCRGBXYZ(rgb_shading, new_xyz, wp, @GenCCHomo, @ApplyCCLinear, foldCount);
t(i,:) = GenerateTableRow(cielabE, '3D homography');
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