function [ tFactor ] = CalcTFactor( varargin )
%% REGUSEARCH Find the best Tikhonov Regularisation parameter for a colour 
% correction method. 
%
%   This function searchs for the best Tikhonov Regularisation factor in
%   the context of colour correction. The idea is to calculate CIELAB error
%   under leave-one-out cross-validation, and search for the t-factor that
%   provides the minimum CIELAB error. 
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
%   Optional name-value pair parameters
%       lim : The stopping limit for the binary search
%       initT : The initial Tikhonov factor to try
%

%% Variable initial setup
% set up the input parser
p = inputParser;

%%% Required parameters
% The matrix which contains the camera responses
addRequired(p, 'rgb', @(x) ismatrix(x) && size(x, 2));
% The matrix which contains the corresponding tristimulus values
addRequired(p, 'xyz', @(x) ismatrix(x) && size(x, 2) == 3);
% genCC, the function for generation the colour correction matrix
addRequired(p, 'genCC', @(x) isa(x, 'function_handle'));
% applyCC, the function for applying the colour correction matrix
addRequired(p, 'applyCC', @(x) isa(x, 'function_handle'));

%%% Optional name-value pair parameters
% The stopping limit for the search.
addParameter(p, 'lim', 0.000001, @(x) isnumeric(x));
% The initial Tikhonov factor to try
addParameter(p, 'initT', 0.1, @(x) isnumeric(x));

% Parse the varargin
parse(p, varargin{:});

%%% Initial variable assignments
rgb = p.Results.rgb;
xyz = p.Results.xyz;
genCC = p.Results.genCC;
applyCC = p.Results.applyCC;
lim = p.Results.lim;
initT = p.Results.initT;

% Debug settings
debug = 0;

% plot the process?
eplot = 0;
xvals = [];
yvals = [];

% If rgb and xyz don't have the same size, throw an error. 
if size(rgb, 1) ~= size(xyz,1)
    error('EvalCCRGBXYZ:input_size_mismatch', ... 
        'RGB matrix and XYZ matrix differ in size');
end

%% Compute the smallest tFactor
% The objective function for optimisation
objFunc = @(t) CalcMeanCielabE(rgb, xyz, genCC, applyCC, t);

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
    % eplots entry
    if eplot
        xvals = [xvals tFactor];
        yvals = [yvals currErr];
    end

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

[tFactor, xvals, yvals] = FindStationaryPoints(objFunc, sStart, sEnd, ...
    lim, debug, eplot);

if eplot
    figure; plot(xvals, yvals);
end

end

function [ c, xvals, yvals] = FindStationaryPoints( func, a, b, lim, debug, eplot )
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
xvals = [];
yvals = [];

while (fac > lim || fbc > lim)
    c = (a + b) / 2;
    fa = func(a);
    fb = func(b);
    fc = func(c);

    if eplot
        xvals = [xvals a b c];
        yvals = [yvals fa fb fc];
    end

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
