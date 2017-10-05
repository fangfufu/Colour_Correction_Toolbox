function [ checker_rgb ] = ProcessColourChecker( checker_img, dark_img, ...
    shading_img )
%PROCESSCOLOURCHECKER Process a set colour checker images
%   Parameters: 
%       dark_img : the dark current image
%       checker_img : the colour checker image

% Remove dark current
if exist('dark_img', 'var')
    checker_img = checker_img - dark_img;
    checker_img = im2double(checker_img);
else
    warning('Dark current image does not exist!');
end

if exist('shading_img', 'var')
    % If shading image exists, remove dark current, remove shading from
    % colour checker image.
    shading_img = im2double(shading_img);
    checker_img = checker_img ./ shading_img;
end

% Initial image crop
[~, rect] = imcrop(checker_img.^0.5);
checker_img = imcrop(checker_img, rect);

% Untransform the image
[checker_img] = UntransformImg(checker_img);

% Second image crop;
[~, rect] = imcrop(checker_img.^0.5);
checker_img = imcrop(checker_img, rect);

% Get colour chart rgb
checker_rgb = GetColourChartRGB(checker_img);

end

