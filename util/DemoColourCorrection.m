function [cimgs, ccms] = DemoColourCorrection( rgb, xyz, img, t_factor )
%DemoColourCorrection Demonstrate colour correction functions

%% The list of functions to be 
if ~exist('t_factor', 'var')
    t_factor = 0; 
end
GenCCPoly2 = @(rgb, XYZ) GenCCPolynomial(rgb, XYZ, 2, t_factor);
GenCCPoly3 = @(rgb, XYZ) GenCCPolynomial(rgb, XYZ, 3, t_factor);
GenCCRP2 = @(rgb, XYZ) GenCCRootPolynomial(rgb, XYZ, 2, 0);
GenCCRP3 = @(rgb, XYZ) GenCCRootPolynomial(rgb, XYZ, 3, t_factor);

genCCfuns = {@GenCCLinear, GenCCPoly2, GenCCPoly3, GenCCRP2, GenCCRP3};

applyCCfuncs = {@ApplyCCLinear, @ApplyCCPolynomial, @ApplyCCPolynomial, ...
    @ApplyCCRootPolynomial, @ApplyCCRootPolynomial};

plotTitles = {'Linear', 'Second order polynomial', ...
    'Third order polynomial', 'Second order root-polynomial', ...
    'Third order root-polynomial'};

%% Show the demo
img = im2double(img);
img = imresize(img, 0.25);
[cimgs, ccms] = ShowColourCorrection(rgb, xyz, genCCfuns, ... 
    applyCCfuncs, img, 'plotTitles', plotTitles);

tightfig;

end

