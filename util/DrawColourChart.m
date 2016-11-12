function [ ] = DrawColourChart( triplets, ncols, nrows, wp)
%% DrawColourChart Given XYZ values, draw a colour chart
%   Mandatory Parameters : 
%       triplets : The triplets that describe a colour checker - could be 
%                   RGB or XYZ
%       ncols : The number of columns in this colour checker
%       nrows : The nubmer of rows in this colour checker
%
%   Optional Parameter :
%       wp : The white point of the illuminant, supplying this parameter
%               triggers the conversion from XYZ to sRGB.


%% Sanity checks
if size(triplets, 1) ~= ncols * nrows
    error('Invalid matrix dimension.');
end

%% Convert XYZ to sRGB
% Note that we needed the whitepoint reading off the tiles
if exist('wp', 'var')
    rgb = xyz2rgb(triplets, 'WhitePoint', wp);
    rgb(rgb < 0) = 0;
else
    rgb = triplets;
end

%% Draw the rectangles
axis equal;
k = 1;
for j = 1:nrows
    for i = 1:ncols
        rectangle('Position', [i * 10, -j * 10, 10, 10], 'FaceColor', ...
            rgb(k,:));
        k = k + 1;
    end
end
axis off;

end
