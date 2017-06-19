function [ cielabE ] = EvalCCRGBXYZMI( varargin )
%% EVALCCRGBXYZMI Evaluate a maximum ignorance colour correction function
%   [ cielabE ] = EvalCCRGBXYZMI( rgb, xyz, cssf, cmf, genCC, applyCC)
%
%   Required parameters:
%       rgb : A n-times-3 matrix containing RGB response of the cameras, 
%           n being the
%       xyz : A n-times-3 matrix containing the  corresponding tristimulus
%           values. 
%       cssf : Camera spectral sensitivity function
%       cmf :   Colour matching function
%       genCC : The function for generation colour correction matrix
%       applyCC : The function for applying colour correction matrix
%
%   Name-value parameters:
%       cssfWl : The sampling wavelength for the camera spectral
%       sensitivity function
%       cmfWl : The sampling wavelength for the colour matching function

%% Set up the input parser
p = inputParser; 

% Required parameters
% The matrix which contains the camera responses
addRequired(p, 'rgb', @(x) ismatrix(x) && size(x, 2));
% The matrix which contains the corresponding tristimulus values
addRequired(p, 'xyz', @(x) ismatrix(x) && size(x, 2) == 3);
% The camera spectral sensitivity response function
addRequired(p, 'cssf', @(x) ismatrix(x) && size(x,2) == 3);
% The colour matching function
addRequired(p, 'cmf', @(x) ismatrix(x) && size(x,2) == 3);
% genCC, the function for generation the colour correction matrix
addRequired(p, 'genCC', @(x) isa(x, 'function_handle'));
% applyCC, the function for applying the colour correction matrix
addRequired(p, 'applyCC', @(x) isa(x, 'function_handle'));

% Name-value parameters
% The sampling wavelength for the camera spectral sensitivity function
addParameter(p, 'cssfWl', [], @(x) ismatrix(x) && size(x,2) == 3);
% The sampling wavelength for the colour matching function
addParameter(p, 'cmfWl', [], @(x) ismatrix(x) && size(x,2) == 3);

% Parse the varargin
parse(p, varargin{:});

%% Initial variable assignment
% Assign the output of the input parser
RGB = p.Results.rgb;
XYZ = p.Results.xyz;
cssf = p.Results.cssf;
cmf = p.Results.cmf;
genCC = p.Results.genCC;
applyCC = p.Results.applyCC; 
cssfWl = p.Results.cssfWl;
cmfWl = p.Results.cmfWl;

% Re-interpolate cmf or cssf
if ~isempty(cssfWl) && ~isemtpy(cmfWl)
    if size(cmf,1) > size(cssf,1)
        cmf = InterpData(cmf, cmfWl, cssfWl);
    else
        cssf = InterpData(cssf, cssfWl, cmfWl);
    end
end

% Additional sanity check
% Make sure that cmf and cssf have the same dimension
if ~isequal(size(cmf), size(cssf))
    error('EvalCCCSSFCMF:cssf_cmf_dimensional_mismatch', ...
        ['Dimensional mismatch between camera spectral sensitiviy', ...
        'function and colour matching function, please supply both', ...
        'cssfWl and cmfWl']);
end
%% The main part

% Get the whitepoints
wpXYZ = GetWpFromColourChecker(XYZ);
wpRGB = GetWpFromColourChecker(RGB);

% The true CIELAB values
LAB = xyz2lab(XYZ, 'WhitePoint', wpXYZ);

% Compute colour correction matrix
ccm = genCC(cssf, cmf);

% Compute the estimated XYZ and CIELAB values (e for estimated)
eXYZ = applyCC(RGB, ccm); 
eLAB = xyz2lab(eXYZ, 'WhitePoint', wpXYZ);

% Calculate the CIELAB error
cielabE = sqrt(sum((LAB - eLAB).^2,2));

end

