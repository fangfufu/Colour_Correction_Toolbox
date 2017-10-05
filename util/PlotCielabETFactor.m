function [ h, tTable ] = PlotCielabETFactor( varargin )
%% PLOTCIELABETFACTOR Plot how Tikhonov factor affects the CIELAB error
%   This function draws a graph showing how the CIELAB error changes as the
%   regularisation factor changes. This function effectively does what
%   GenCCReguSearch does, except the binary search part.
%
%   Mandatory parameters:
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
%   Optional positional parameters: 
%       wp : The whitepoint of the illuminant
%
%   Optional name-value pair parameters:
%       tStart : The starting point of the graph
%       tEnd : The stopping point of the graph
%       tInt : The interval of between two sampling points.
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

%%% Optional name-value pair parameters
% The starting point of the graph
addParameter(p, 'tStart', 1, @(x) isnumeric(x));
% The stopping point of the graph
addParameter(p, 'tEnd', 1e-5, @(x) isnumeric(x));
% The interval of between two sampling points.
addParameter(p, 'tInt', 0.5, @(x) isnumeric(x));

% Parse the varargin
parse(p, varargin{:});

%%% Initial variable assignments
rgb = p.Results.rgb;
xyz = p.Results.xyz;
genCC = p.Results.genCC;
applyCC = p.Results.applyCC;
wp = p.Results.wp;
tStart = p.Results.tStart;
tEnd = p.Results.tEnd;
tInt = p.Results.tInt;

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

%% Compute the tFactors
% The objective function
objFunc = @(t) CalcMeanCielabE(rgb, xyz, wp, genCC, applyCC, t);

% The loop for generating the CIELAB error table
tFactor = tStart;
tTableSize = ceil(log(tEnd / tStart)/log(tInt));
tTable = zeros(tTableSize, 2);
i = 1;
while tFactor > tEnd
%     disp(i/tTableSize * 100);
    tTable(i, 1) = tFactor;
    tTable(i, 2) = objFunc(tFactor);
    tFactor = tFactor * tInt;
    i = i + 1;
end

h = semilogx(tTable(:,1), tTable(:,2));
xlabel('Tikhonov regularisation factor');
ylabel('CIELAB error');

end
