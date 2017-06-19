function [ cielabE ] = EvalCCCSSFCMF( varargin )
%% EVALCCCSSFCMF Evaluate a colour correction function, given a camera's 
%spectral response, colour matching function, illuminant spectrum and 
%reflectance spectrum
%   
%   Required parameters:
%       cssf : Camera spectral sensitivity function
%       cmf :   Colour matching function
%       illuminant : The illuminant spectrum
%       genCC : The function for generation colour correction matrix
%       applyCC : The function for applying colour correction matrix
%
%   Optional parameters:
%       foldCount : The number of fold required for cross-validation
%
%   Name-value parameters:
%       cssfWl : The sampling wavelength for the camera spectral
%       sensitivity function
%       cmfWl : The sampling wavelength for the colour matching function
%
%       Note that colour matching function should always have finer
%       sampling resolution than the camera sensitvity function
%       

%% Set up the input parser
p = inputParser; 

% Required parameters
% The camera spectral sensitivity response function
addRequired(p, 'cssf', @(x) ismatrix(x) && size(x,2) == 3);
% The colour matching function
addRequired(p, 'cmf', @(x) ismatrix(x) && size(x,2) == 3);
% The illuminant spectrum
addRequired(p, 'illuminant', @(x) iscolumn(x));
% The reflectance spectra
addRequired(p, 'reflectance', @(x) ismatrix(x));
% genCC, the function for generation the colour correction matrix
addRequired(p, 'genCC', @(x) isa(x, 'function_handle'));
% applyCC, the function for applying the colour correction matrix
addRequired(p, 'applyCC', @(x) isa(x, 'function_handle'));

% Optional parameters
% foldCount the number of folds in cross validation
addOptional(p, 'foldCount', 3, @(x) numel(x) == 1 && rem(x,1) == 0);

% Name-value parameters
% The sampling wavelength for the camera spectral sensitivity function
addParameter(p, 'cssfWl', [], @(x) ismatrix(x) && size(x,2) == 3);
% The sampling wavelength for the colour matching function
addParameter(p, 'cmfWl', [], @(x) ismatrix(x) && size(x,2) == 3);

% Parse the varargin
parse(p, varargin{:});

%% Initial variable assignment
% Assign the output of the input parser
cssf = p.Results.cssf;
cmf = p.Results.cmf;
illuminant = p.Results.illuminant;
reflectance = p.Results.reflectance; 
genCC = p.Results.genCC;
applyCC = p.Results.applyCC; 
foldCount = p.Results.foldCount;
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

%% Calculate the rgb and xyz
colourSignal = reflectance .* repmat(illuminant, 1, size(reflectance, 2));
rgb = colourSignal' * cssf; 
xyz = colourSignal' * cmf;
wp = ones(size(cmf,1),1)' * cmf;


%% Pass the rgb and xyz to another evaluator
[ cielabE ] = EvalCCRGBXYZ(rgb, xyz, wp, genCC, applyCC, foldCount);

end

