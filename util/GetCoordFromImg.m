function [ pts, len ] = GetCoordFromImg(npts)
%get_img_coord Get coordinates from an image.
%   Parameters
%       img : The input image
if ~exist('npts', 'var')
    npts = 4;
end

hold on;
pts = zeros(npts, 2);
for i = 1:npts
    this_pt = ginput(1);
    plot(this_pt(1), this_pt(2), 'rx', 'MarkerSize', 15, 'LineWidth', 2);
    pts(i, :) = this_pt;
end
hold off;

len = sqrt(sum((pts(1,:) - pts(2,:)).^2));

end
