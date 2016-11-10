function [ ] = DrawColourChart( XYZ, wp )
%% DRAW_COLOUR_CHART Draw the Macbeth Colour Chart
%   The purpose of this function is to determine how the Macbeth colour
%   chart was oriented, when we measured it using the spectroradiometer
%   Parameters:
%       spectrum - 3x140 matrix containing the xyz chromaticity readings

%% Sanity checks
if size(XYZ, 2) ~= 140
    error('Invalid xyz matrix.');
end

%% Convert XYZ to sRGB
% Note that we needed the whitepoint reading off the tiles
rgb = xyz2rgb(XYZ', 'WhitePoint', wp);
rgb(rgb < 0) = 0;

%% Draw the rectangles
axis equal; 
for j = 1:10
    for i = 1:14
        num = (j-1)*14 + i;
        rectangle('Position', [i * 10, -j * 10, 10, 10], 'FaceColor', ...
            rgb(num,:));
    end
end

axis off;

end
