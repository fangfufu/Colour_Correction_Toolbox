function [ output_args ] = EvalPairWise( input_args )
%EVALPAIRWISE Summary of this function goes here
%   Detailed explanation goes here

%% Load data
% The XYZ
load('/home/fangfufu/UEA/Colour_Correction_Toolbox/data/D65_SG_Colour_Chart.mat');
% The RGB - Integrating sphere data set
load('/home/fangfufu/UEA/Colour_Correction_Toolbox/data/Nikon/DSC_0005.mat');

foldInd = GenSquentialFoldInd(size(new_xyz,1),3 ); %#ok<NODEF>

%% Defining all pairs for evaluation

genfuncvec = {@GenCCALS, @GenCCHomo, @GenCCLinear, @GenCCRootPolynomial};
n = numel(genfuncvec);
mean_table = zeros(n);
median_table = zeros(n);
quantile95_table = zeros(n);

%% Actual evaulation
for i = 1:n
    for j = 1:n
        thisPair = GenCCPairwise( rgb, xyz, gfunc1, gfunc2, ...
    afunc1, afunc2, t_factor )
        applyThisPair = 
        cielabE = EvalCCRGBXYZ(rgb_shading, new_xyz, wp, thisPair, ...
            applyThisPair, foldInd);
    end
end

