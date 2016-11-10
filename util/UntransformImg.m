function [ out_img, in_pts ] = UntransformImg( in_img, in_pts, ref_img, ...
    ref_pts )
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
%   Optional parameters: 
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
if exist('ref_img', 'var')
    if ~isempty(ref_img)
        if ~exist('ref_pts', 'var')
            % No ref_pts supplied
            ref_pts = get_img_coord_wrapper(ref_img);
        elseif ~isempty(ref_pts)
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
    % The user has supplied an empty ref_img.
end

% If ref_pts are still unset, these are the default ratio for the
% xrite colour chart
if ~exist('ref_pts', 'var') || isempty(ref_pts)
    ref_pts = REF_PTS;
end

%% Process the input image
if ~exist('in_pts', 'var') || isempty(in_pts)
    % The user hasn't supplied matching points (this should normally be the
    % case)
    imshowGammaAdjust(in_img);
    uiwait(msgbox('Please select the designated corners in the colour checker'));
    [in_pts, in_len] = GetCoordFromImg(4);
else
    in_len = mean([sqrt(sum((in_pts(1,:) - in_pts(2,:)).^2)), ...
                sqrt(sum((in_pts(3,:) - in_pts(4,:)).^2))]);
end

%% Calculate the geometric transform between two sets of points
% Scale up the ref_pts
ref_pts = ref_pts * in_len;
tform_in_to_ref = estimateGeometricTransform(in_pts, ref_pts(1:4,:), ...
    'projective');
out_img = imwarp(in_img, tform_in_to_ref);
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

