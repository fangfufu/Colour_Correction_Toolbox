function [ tFactor ] = GenCCReguSearch( varargin )
%% REGUSEARCH Find the best Tikhonov Regularisation parameter for a colour 
% correction method. 
%
%   This function searchs for the best Tikhonov Regularisation factor in
%   the context of colour correction. The idea is to calculate CIELAB error
%   under leave-one-out cross-validation, and search for the t-factor that
%   provides the minimum CIELAB error. 
%
%   We are stuck with this until I learn how to do regularisation properly,
%   and write something better. 
%
%   Mandatory Parameters:
%       rgb : a nx3 matric containing the rgb values from a camera
%       xyz : a nx3 matric containing the corresponding xyz
%       genCC : the function handle for the function for generating the
%           colour correction matrix, this function handle must have the
%           following format: 
%               genCC(rgb, xyz, tFactor), 
%                   where tFactor is the Tikhonov Regularisation parameter.
%       applyCC : the function handle for applying the colour correction
%           matrix
%
%   Optional Positional Parameters: 
%       wp : The whitepoint of the illuminant
%
%   Optional name-value pair parameters
%       lim : The stopping limit for the binary search
%       initT : The initial Tikhonov factor to try
%

%% Variable initial setup
% set up the input parser
p = inputParser;

%%% Required parameters
% The matrix which contains the camera responses
addRequired(p, 'rgb', @(x) ismatrix(x) && size(x, 2) == 3);
% The matrix which contains the corresponding tristimulus values
addRequired(p, 'xyz', @(x) ismatrix(x) && size(x, 2) == 3);
% genCC, the function for generation the colour correction matrix
addRequired(p, 'genCC', @(x) isa(x, 'function_handle'));
% applyCC, the function for applying the colour correction matrix
addRequired(p, 'applyCC', @(x) isa(x, 'function_handle'));

%%% Optional parameters
% The whitepoint of the illuminant
addOptional(p, 'wp', [], @(x) isvector(x) && numel(x) == 3);
% The stopping limit of the binary search

%%% Optional name-value pair parameters
% The stopping limit for the search.
addParameter(p, 'lim', 0.001, @(x) isnumeric(x));
% The initial Tikhonov factor to try
addParameter(p, 'initT', 0.1, @(x) isnumeric(x));

% Parse the varargin
parse(p, varargin{:});

%%% Initial variable assignments
rgb = p.Results.rgb;
xyz = p.Results.xyz;
genCC = p.Results.genCC;
applyCC = p.Results.applyCC;
wp = p.Results.wp;
lim = p.Results.lim;
initT = p.Results.initT;

% Debug settings
debug = 1;

% If rgb and xyz don't have the same size, throw an error. 
if size(rgb, 1) ~= size(xyz,1)
    error('EvalCCRGBXYZ:input_size_mismatch', ... 
        'RGB matrix and XYZ matrix differ in size');
end

% If white point is not specified, we get it from the xyz matrix. 
if isempty(wp)
    wp = GetWpFromColourChecker(xyz);
end

%% Compute the smallest tFactor
% The objective function for optimisation
objFunc = @(t) CalcMeanCielabE(rgb, xyz, wp, genCC, applyCC, t);
% Intial tFactor
tFactor = initT; 
% Previous CIELAB error, initialise to the largest positive number
prevErr = realmax; 
% Current CIELAB error, initialise using the initial tFactor
currErr = objFunc(tFactor);

% While the previous error is bigger than the current error, we decrease
% the size of the tFactor

if debug
    disp('Initial logarithmic search');
    disp(' ');
end
while prevErr > currErr
    tFactor = tFactor / 10;
    prevErr = currErr;
    currErr = objFunc(tFactor);
    if debug
        disp(['tFactor:', num2str(tFactor)]);
        disp(['currErr:', num2str(currErr)]);
        disp(' ');
    end
end

% The starting end ending position for the binary search
sEnd = tFactor;
sStart = tFactor * 100;

if debug
    disp(['sStart: ', num2str(sStart)]);
    disp(['sEnd: ', num2str(sEnd)]);
    disp(' ');
end

% Entering binary search
if debug
    disp('Entering binary search');
    disp(' ');
end
tFactor = FindStationaryPoints(objFunc, sStart, sEnd, lim, debug);

end

function [ c ] = FindStationaryPoints( func, a, b, lim, debug )
%BINSEARCH Find the stationary point of a function by binary search
%
%   Parameters:
%       func : a function
%       a : the initial start point of the search
%       b : the initial end point of the search
%

% Initialise limits to max
fac = realmax; 
fbc = realmax;

while (fac > lim || fbc > lim)
    c = (a + b) / 2;
    fa = func(a);
    fb = func(b);
    fc = func(c);

    fac = abs(fa - fc);
    fbc = abs(fb - fc);
    
    if exist('debug', 'var') && debug
        disp(['c: ', num2str(c)]);
        disp(['fac: ', num2str(fac)]);
        disp(['fbc: ', num2str(fbc)]);
        disp(' ');
    end

% Select which branch to shrink
if fac < fbc
    b = c;
else
    a = c;
end
    
end

end
