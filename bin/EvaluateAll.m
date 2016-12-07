function [ t ] = EvaluateAll(  )
%EVALUATEALL Evaluate all colour correction methods.

% The prototype of the functions used 
%  [ cielabE ] = EvalCCFunc(rgb, xyz, genCC, applyCC, wp, foldInd);

%% Load data
% The XYZ
load('/home/fangfufu/UEA/Colour_Correction_Toolbox/data/D65_SG_Colour_Chart.mat');

% The RGB
% Integrating sphere
% load('/home/fangfufu/UEA/Colour_Correction_Toolbox/data/Nikon/DSC_0005.mat');

% Casper's data
load('/home/fangfufu/UEA/Colour_Correction_Toolbox/data/Casper/DSC_0002.mat');
% load('/home/fangfufu/UEA/Colour_Correction_Toolbox/data/Casper/DSC_0004.mat');
% load('/home/fangfufu/UEA/Colour_Correction_Toolbox/data/Casper/DSC_0007.mat');
% load('/home/fangfufu/UEA/Colour_Correction_Toolbox/data/Casper/DSC_0008.mat');
% load('/home/fangfufu/UEA/Colour_Correction_Toolbox/data/Casper/DSC_0010.mat');

% Recomputing wp, if Casper's data is used
wp = wp_radiance' * InterpData(cmf_xyz, cmf_wl, 400:4:400+4*75);

% Print off which data set we are using
disp(checker_img_shading_name);

%% Run the evaluation functions
% Cross-validation setting
foldInd = crossvalind('KFold',size(new_xyz,1),3 ); %#ok<NODEF>
% foldInd = GenSquentialFoldInd(size(new_xyz,1),3 ); %#ok<NODEF>
% foldInd = [];

% wp = new_xyz(40,:);

% Create an empty table
t = table();
i = 1;

% Linear least squared
[ cielabE ] = EvalCCRGBXYZ(rgb_shading, new_xyz, wp, @GenCCLinear, @ApplyCCLinear, foldInd);
t(i,:) = GenerateTableRow(cielabE, 'Linear least squared');
i = i + 1;

% Second degree polynomial
GenCCPoly2 = @(rgb, xyz) GenCCPolynomial(rgb, xyz, 2);
[ cielabE ] = EvalCCRGBXYZ(rgb_shading, new_xyz, wp, GenCCPoly2, @ApplyCCPolynomial, foldInd);
t(i,:) = GenerateTableRow(cielabE, 'Second order polynomial');
i = i + 1;

% Second degree polynomial
GenCCPoly3 = @(rgb, xyz) GenCCPolynomial(rgb, xyz, 3);
[ cielabE ] = EvalCCRGBXYZ(rgb_shading, new_xyz, wp, GenCCPoly3, @ApplyCCPolynomial, foldInd);
t(i,:) = GenerateTableRow(cielabE, 'Third order polynomial');
i = i + 1;


GenCCRP2 = @(rgb, xyz) GenCCRootPolynomial(rgb, xyz, 2);
[ cielabE ] = EvalCCRGBXYZ(rgb_shading, new_xyz, wp, GenCCRP2, @ApplyCCRootPolynomial, foldInd);
t(i,:) = GenerateTableRow(cielabE, 'Second order root-polynomial');
i = i + 1;

GenCCRP3 = @(rgb, xyz) GenCCRootPolynomial(rgb, xyz, 3);
[ cielabE ] = EvalCCRGBXYZ(rgb_shading, new_xyz, wp, GenCCRP3, @ApplyCCRootPolynomial, foldInd);
t(i,:) = GenerateTableRow(cielabE, 'Third order root-polynomial');
i = i + 1;

[ cielabE ] = EvalCCRGBXYZ(rgb_shading, new_xyz, wp, @GenCCALS, @ApplyCCLinear, foldInd);
t(i,:) = GenerateTableRow(cielabE, 'Alternating Least Squared');
i = i + 1;

[ cielabE ] = EvalCCRGBXYZ(rgb_shading, new_xyz, wp, @GenCCHomo, @ApplyCCLinear, foldInd);
t(i,:) = GenerateTableRow(cielabE, '2D homography');
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