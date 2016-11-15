function [ outImg, inPts ] = UntransformImg( inImg, varargin)
%% UntransformImg Transform an image so the camera is above the image.
%   Transform a colour checker image in such a way so that the camera is 90
%   degrees above the plane being imaged. This function is designed to work
%   with colour checker boards. 
%
%   Example:
%       out_img = UntransformImg(in_img);
%       The in_img will be displayed. The user then has to select 8 corners
%       specified by the example image.
%
%   Mandatory parameters:
%       in_img : An image of the chequer board
%
%   Optional name-value pair parameters: 
%       in_pts : The coordinate of the specified corners on the colour 
%                checker.
%       ref_img : The optional reference colour checker board images. 
%       ref_pts : The coordinate of the corners in the reference tracker
%       board
%
%   Output:
%       out_img : The image of the colour checker board after
%       transformation.
%

%% Input Parser
p = inputParser; 
addParameter(p, 'inPts', [], @(x) isnumeric(x) && numel(x) == 8);
addParameter(p, 'refImg', [], @(x) isnumeric(x) && ndims(x) == 3);
addParameter(p, 'refPts', [], @(x) isnumeric(x) && numel(x) == 8);

parse(p, varargin{:});

inPts = p.Results.inPts;
ref_img = p.Results.refImg;
ref_pts = p.Results.refPts;


%% Constants
REF_PTS = [ ...
       94.521        70.42; ...
       1021.3       71.334; ...
       1021.3       731.24; ...
       93.607       731.24; ...
       146.62       124.35; ...
       969.21       126.17; ...
       969.21       677.31; ...
       149.36        676.4; ...
        ];
REF_LEN = mean([sqrt(sum((REF_PTS(1,:) - REF_PTS(2,:)).^2)), ...
                sqrt(sum((REF_PTS(3,:) - REF_PTS(4,:)).^2))]);
REF_PTS = REF_PTS./REF_LEN;            

%% Checking what the user has supplied
if ~isempty(ref_img)
    if ~isempty(ref_pts)
        % The user has supplied a non-empty ref_img, a non-empty
        % ref_match_pts, we are drawing the matched points on the
        % ref_img
        figure;
        imshow(ref_img);
        hold on;
        plot(ref_pts(:,1), ref_pts(:,2), ...
            'rx', 'MarkerSize', 15, 'LineWidth', 2);
        hold off;
    else
        % ref_pts exist, but empty
        ref_pts = get_img_coord_wrapper(ref_img);
    end
end

% If ref_pts are still unset, these are the default ratio for the
% xrite colour chart
if isempty(ref_pts)
    ref_pts = REF_PTS;
end

%% Process the input image
if isempty(inPts)
    % The user hasn't supplied matching points (this should normally be the
    % case)
    imshowGammaAdjust(inImg);
    uiwait(msgbox('Please select the designated corners in the colour checker'));
    [inPts, in_len] = GetCoordFromImg(4);
else
    in_len = mean([sqrt(sum((inPts(1,:) - inPts(2,:)).^2)), ...
                sqrt(sum((inPts(3,:) - inPts(4,:)).^2))]);
end

%% Calculate the geometric transform between two sets of points
% Scale up the ref_pts
ref_pts = ref_pts * in_len;
tform_in_to_ref = estimateGeometricTransform(inPts, ref_pts(1:4,:), ...
    'projective');
outImg = imwarp(inImg, tform_in_to_ref);
end

function [ref_pts, ref_len] = get_img_coord_wrapper(ref_img)
% The user has supplied a non-empty ref_img, and supplied an
% empty ref_match_pts. We need to get ref_match_pts off the
% user
imshowGammaAdjust(ref_img);
msgbox(['Please select the designated corners in the reference colour',...
    'checker']);
[ref_pts, ref_len] = GetCoordFromImg(4);
ref_pts = ref_pts ./ ref_len;
end

