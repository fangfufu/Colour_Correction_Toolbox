function [ ] = DrawColourChecker( in_mat, ncol, nrow, wp)
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
if size(in_mat, 1) ~= ncol * nrow
    error('Invalid matrix dimension.');
end

%% Transpose colour checker 
% My own data set tends to be row-wise first, then column-wise. Whereas
% everyone else's data seems to be column-wise first, then row-wise. 
in_mat = TransposeColourChecker(in_mat, ncol, nrow);

%% Convert XYZ to sRGB
% Note that we needed the whitepoint reading off the tiles
wp = GetWpFromColourChecker(in_mat);
rgb = xyz2rgb(in_mat, 'WhitePoint', wp);
rgb(rgb < 0) = 0;
rgb(rgb > 1) = 1;


%% Draw the rectangles
axis equal;
axis off;
k = 1;
for j = 1:nrow
    for i = 1:ncol
        rectangle('Position', [i * 10, -j * 10, 10, 10], 'FaceColor', ...
            rgb(k,:));
        k = k + 1;
    end
end

end
