function [ ccm ] = GenCCMI( cssf, cmf, varargin)
%GENCCMI Generate colour correction matrix using Maximum Ignorance Colour
%Correction
%   Basically a wrapper function for GenCCLinear, for function name
%   consistency
%
%   Name-value parameters:
%       cssfWl : The sampling wavelength for the camera spectral
%       sensitivity function
%       cmfWl : The sampling wavelength for the colour matching function

%% Set up the input parser, for sanity check
p = inputParser;
addParameter(p, 'cssfWl', [], @(x) isvector(x));
addParameter(p, 'cmfWl', [], @(x) isvector(x));
parse(p, varargin{:});
cssfWl = p.Results.cssfWl;
cmfWl = p.Results.cmfWl;

% Re-interpolate cmf or cssf
if ~isempty(cssfWl) && ~isempty(cmfWl)
    if size(cmf,1) > size(cssf,1)
        cmf = InterpData(cmf, cmfWl, cssfWl);
    else
        cssf = InterpData(cssf, cssfWl, cmfWl);
    end
end

% Additional sanity check
% Make sure that cmf and cssf have the same dimension
if ~isequal(size(cmf), size(cssf))
    error('GenCCMI:cssf_cmf_dimensional_mismatch', ...
        ['Dimensional mismatch between camera spectral sensitiviy', ...
        'function and colour matching function, please supply both ', ...
        'cssfWl and cmfWl']);
end

%% Generate colour correction matrix

cssf = cssf./max(cssf(:));
cmf = cmf ./ max(cmf(:));

ccm = GenCCLinear(cssf, cmf);

end

