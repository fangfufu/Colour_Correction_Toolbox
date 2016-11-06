function [ rgb ] = get_colour_chart_rgb( img, rs, cs, sz)
%% get_colour_chart_rgb Get the RGB values from a colour chart
%   The main purpose of this program is to draw rectangle to indicate
%   colour patches. 
%   Parameters:
%       img - image to be shown
%       tl - top left corner of the colour checker
%       br - bottom right corner of the colour checker
%       tl and br are in the format of (row, col)

% Debug flag
dbg = 1;

% Debug only.
if dbg == 1
    imshow(img.^0.5*5);
    hold on;
end

col_factor = size(img, 2) / 14;
row_factor = size(img, 1) / 10;
rgb = zeros(3,140);
k = 1;
for j = 1:10
    for i = 1:14
        row = round(j * row_factor + rs);
        col = round(i * col_factor + cs);
        % Debug only
        if dbg == 1
            rectangle('Position', [col, row, sz, sz], 'EdgeColor', 'r');
%             pause;
        end
        rgb(:,k) = mean(mean(img(row:row+sz, col:col+sz,:)));
        k = k + 1;
    end
end

end

