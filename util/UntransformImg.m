function [ out_img ] = UntransformImg( in_img, in_pts, ref_img, ref_pts )
%% UNTRANSFORM_IMG Transform an image so the camera is above the image.
%   Transform the input image in such a way so that the camera is 90
%   degrees above the image. 

%% Checking what the user has supplied
if exist('ref_img', 'var')
    if ~isempty(ref_img)
        if ~exist('ref_pts', 'var')
            % The user has supplied a non-empty ref_img, but hasn't
            % supplied ref_match_pts.
            [ref_pts, ref_len] = get_img_coord(ref_img);
            ref_pts = ref_pts ./ ref_len;
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
            % The user has supplied a non-empty ref_img, and supplied an
            % empty ref_match_pts. We need to get ref_match_pts off the
            % user
            [ref_pts, ref_len] = get_img_coord(ref_img);
            ref_pts = ref_pts ./ ref_len;
        end
    end
    % The user has supplied an empty ref_img.
end

% If ref_pts are still unset, these are the default ratio for the
% xrite colour chart
if ~exist('ref_pts', 'var')
    ref_pts = [ ...
        0.1014    0.0755; ...
        1.1014    0.0755; ...
        1.1025    0.7886; ...
        0.1025    0.7875; ...
        0.1586    0.1348; ...
        1.0453    0.1348; ...
        1.0442    0.7314; ...
        0.1597    0.7292
        ];
elseif isempty(ref_pts)
    ref_pts = [ ...
        0.1014    0.0755; ...
        1.1014    0.0755; ...
        1.1025    0.7886; ...
        0.1025    0.7875; ...
        0.1586    0.1348; ...
        1.0453    0.1348; ...
        1.0442    0.7314; ...
        0.1597    0.7292
        ];
end

%% Process the input image
if ~exist('in_pts', 'var')
    % The user hasn't supplied matching points (this should normally be the
    % case)
    [in_pts, in_len] = get_img_coord( in_img );
else
    in_len = sqrt(sum((in_pts(1,:) - in_pts(2,:)).^2));
end

%% Calculate the geometric transform between two sets of points
% Scale up the ref_pts
ref_pts = ref_pts * in_len;
tform_in_to_ref = estimateGeometricTransform(in_pts, ref_pts, ...
    'projective');
out_img = imwarp(in_img, tform_in_to_ref);
end

