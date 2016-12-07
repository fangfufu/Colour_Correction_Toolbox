function [ cielabE ] = EvalCCRGBXYZ( varargin )
%EVALCCFUNC Evaluate a colour correction function given RGB and XYZ
%   [ cielabE ] = EvalCCRGBXYZ(rgb, xyz, wp, genCC, applyCC);
%   [ cielabE ] = EvalCCRGBXYZ(rgb, xyz, wp, genCC, applyCC, foldCount);
%
%   Required parameters:
%       rgb : A n-times-3 matrix containing RGB response of the cameras, 
%           n being the
%       xyz : A n-times-3 matrix containing the  corresponding tristimulus
%           values. 
%       wp : The white point for the illuminant
%       genCC : The function for generation colour correction matrix
%       applyCC : The function for applying colour correction matrix
%
%   Optional parameters:
%       foldCount : The number of fold required for cross-validation

% Debug only
debug = 1;

%% Set up the input parser
p = inputParser;

% Required parameters
% The matrix which contains the camera responses
addRequired(p, 'rgb', @(x) ismatrix(x) && size(x, 2) == 3);
% The matrix which contains the corresponding tristimulus values
addRequired(p, 'xyz', @(x) ismatrix(x) && size(x, 2) == 3);
% The whitepoint of the illuminant
addRequired(p, 'wp', @(x) isvector(x) && numel(x) == 3);
% genCC, the function for generation the colour correction matrix
addRequired(p, 'genCC', @(x) isa(x, 'function_handle'));
% applyCC, the function for applying the colour correction matrix
addRequired(p, 'applyCC', @(x) isa(x, 'function_handle'));

% Optional parameters
% foldCount the number of folds in cross validation
addOptional(p, 'foldCount', 3, @(x) numel(x) == 1 && rem(x,1) == 0);

% Parse the varargin
parse(p, varargin{:});

%% Initial variable assignment
% Assign the things came out from the input parser (saves me from typing)
rgb = p.Results.rgb;
xyz = p.Results.xyz;
genCC = p.Results.genCC;
applyCC = p.Results.applyCC;
wp = p.Results.wp;
foldCount = p.Results.foldCount;

if size(rgb, 1) ~= size(xyz,1)
    error('EvalCCRGBXYZ:input_size_mismatch', ... 
        'RGB matrix and XYZ matrix differ in size');
end

% normalise exposure by dividing G of white patch
% xyz = xyz./wp(2);
% wp = wp./wp(2);

% CIELAB error matrix
cielabE = [];

% The number of colour signals we actually have
Nrgb = size(rgb, 1);

% The true CIELAB 
lab = xyz2lab(xyz, 'WhitePoint', wp);
% lab = HGxyz2lab(xyz, wp);



%% The main loop
% This implements cross validation
for i = 1:foldCount
    % Note that we use 't' for training, 'v' for validation.
    
    % Setting the indices
    tInd = i:foldCount:Nrgb;
    vInd = setdiff(1:Nrgb, tInd);
    
    % Handle foldCount == 1 (no cross-validation)
    if isempty(vInd)
        vInd = tInd;
    end
    
    % Extracting the training data for this fold
    tRGB = rgb(tInd, :);
    tXYZ = xyz(tInd, :);
    
    % Training the colour correction matrix
    ccm = genCC(tRGB, tXYZ);
    
    % Generate the validation set
    vRGB = rgb(vInd, :);
    vRGB(end+1,:) = vRGB(40,:);
    
    vTrueLab = lab(vInd, :);
    
    % Apply colour correction
    vCamXYZ = applyCC(vRGB, ccm);
    vWp = vCamXYZ(end,:);
    vCamXYZ = vCamXYZ(1:end-1,:);
    
    % normalise exposure by dividing G of white patch
%     vCamXYZ = vCamXYZ ./ vCamXYZ(end, 2);

    vCamLab = xyz2lab(vCamXYZ, 'WhitePoint', wp);
%     vCamLab = xyz2lab(vCamXYZ, 'WhitePoint', vWp);
%     vCamLab = HGxyz2lab(vCamXYZ, vCamXYZ(40,:));

    
    vCielabE = sqrt(sum((vCamLab - vTrueLab).^2, 2));
    cielabE = [cielabE; vCielabE]; %#ok<AGROW>
    
%     if debug
%         figure;
%         txy = tXYZ./repmat(sum(tXYZ, 2),1,3);
%         plot(txy(:,1), txy(:,2));
%         title(['xy chromaticity for fold ' num2str(i)]);
%         xlabel(
%     end
end

end

