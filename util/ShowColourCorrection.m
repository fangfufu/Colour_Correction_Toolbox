function [ cimgs, ccms ] = ShowColourCorrection( varargin )
%% SHOWCOLOURCORRECTION show the results of colour correction functions
% [cimgs, ccms] = DemoColourCorrection(rgb, xyz, genCC, applyCC, img);
%   
%   This function calculates the colour correction matrix for the given set
%   of colour correction function, using the given set of rgb and the
%   corresponding xyz values. 
%
%   Mandatory parameters: 
%       rgb : a nx3 matrix containing the rgb values from a camera
%       xyz : a nx3 matrix containing the corresponding xyz values
%       genCC : a cell array containing the function for generating colour
%           correction matrix using rgb and xyz
%       applyCC : a cell array containing the function for applying colour
%           correction matrix to images
%       img : the image to be colour corrected
%       
%   Optional parameters: 
%       img : an image to be colour corrected. 
%       windowConfig : The number of subplots to be created in the main
%          subplot window, by default it is [2, 3]
%
%   Output parameters:
%       cimgs : a cell array containing the colour corrected images
%       ccms : a cell array containing all the colour correction matrices
%
%% Intial variable assignments

% Set up the input parser
p = inputParser;

%%% Required parameters 
% The matrix which contains the camera responses
addRequired(p, 'rgb', @(x) ismatrix(x) && size(x, 2) == 3);
% The matrix which contains the corresponding tristimulus values
addRequired(p, 'xyz', @(x) ismatrix(x) && size(x, 2) == 3);
% genCC, the function for generation the colour correction matrix
addRequired(p, 'genCC', @(x) iscell(x));
% applyCC, the function for applying the colour correction matrix
addRequired(p, 'applyCC', @(x) iscell(x));

%%% Optional parametrs 
% The image to be colour corrected. 
addOptional(p, 'img', [], ...
    @(x) ndims(x) == 3 && size(x, 3) == 3)
% The configuration of the plotting window
addOptional(p, 'windowConfig', [2, 3], @(x) isvector(x) && numel(x) == 2);

%%% Pairwise parameters
addParameter(p, 'plotTitles', {}, @(x) iscell(x));

% Parse the varargin
parse(p, varargin{:});

rgb = p.Results.rgb;
xyz = p.Results.xyz;
genCC = p.Results.genCC;
applyCC = p.Results.applyCC;
img = p.Results.img;
windowConfig = p.Results.windowConfig;
plotTitles = p.Results.plotTitles;

if numel(genCC) ~= numel(applyCC)
    error(['The number of genCC function should be the same as the ' ...
        'number of applyCC functions']);
end

if ~isempty(plotTitles)
    if numel(plotTitles) ~= numel(genCC)
        error(['The number of plotTitiles should be the same as the' ...
            'number of applyCC functions']);
    end
end

% The number of methods used in colour correction
nMethods = numel(genCC);

% Normalise input values
rgb = rgb./max(rgb(:));
xyz = xyz./max(xyz(:));
img = img./max(img(:));

%% Calculate all the colour correction matrix
% Note that we aren't doing cross-validation here

% The colour correction matrix
ccms = cell(nMethods, 1);
cimgs = cell(nMethods, 1);
% Display the raw image
subplot(windowConfig(1), windowConfig(2), 1);
imshow(real(img.^0.5));
title('Raw');

for i = 1:nMethods
    ccms{i} = genCC{i}(rgb, xyz);
    % Generate the corrected image, if such thing exists
    if ~isempty(img)
        cimgs{i} = applyCC{i}(img, ccms{i});
        cimgs{i} = real(cimgs{i});
        cimgs{i}(cimgs{i} < 0 | isinf(cimgs{i}) | isnan(cimgs{i})) = 0;
        cimgs{i} = xyz2rgb(real(cimgs{i}), 'WhitePoint', ...
            GetWpFromColourChecker(xyz));
        subplot(windowConfig(1), windowConfig(2), i+1);
        imshow(cimgs{i});
        if ~isempty(plotTitles)
            title(plotTitles{i});
        end
    end
end

end

