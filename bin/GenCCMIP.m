function [ m ] = GenCCMIP( varargin )
%MIP Maximum Ignorance Colour Correction with Positivity
%   %   [ m ] = GenCCMIP(cssf, cmf)
%   
%   Parameters
%       cssf : camera spectral sensitivity function
%       cmf : standard observer colour matching function
%
%       Both cssf and cmf are in the format of wavelengths-times-channel
%
%   Name-value parameters:
%       cssfWl : The sampling wavelength for the camera spectral
%       sensitivity function
%       cmfWl : The sampling wavelength for the colour matching function
%
%   Reference:
%       Finlayson, Graham D., and Mark S. Drew. 
%       "The maximum ignorance assumption with positivity." 
%       Color and Imaging Conference. Vol. 1996. No. 1. 
%       Society for Imaging Science and Technology, 1996.
%
%   Linear regression while enforcing individual independent variable to 
%   be strictly positive
if numel(varargin) == 1
    varargin = varargin{1};
end
nargin = numel(varargin);

%% Set up the input parser, for sanity check
p = inputParser;
addRequired(p, 'cssf', @(x) ismatrix(x));
addRequired(p, 'cmf', @(x) ismatrix(x));
addParameter(p, 'cssfWl', [], @(x) isvector(x));
addParameter(p, 'cmfWl', [], @(x) isvector(x));
parse(p, varargin{:});
cssf = p.Results.cssf;
cmf = p.Results.cmf;
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

llt = pos_ident_mat(max(size(cmf)));
m = cmf' * llt * cssf * inv(cssf' * llt * cssf);

end

function [ mat ] = pos_ident_mat( s )
%POS_IDENT_MAT Construct a positive identiy matrix
mat = ones(s)/4;
mat(logical(eye(s))) = 1/3;
end
