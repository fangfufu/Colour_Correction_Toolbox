function [ g, f ] = imshowGammaAdjust( img )
%% IMSHOWGAMMAADJUST Determine a desired gamma value for an image
img = im2double(img);
while(true)
    str = inputdlg('Please input a gamma value:',...
                 'Gamma', 1, {'0.5'});
    if isempty(str)
        error('imshowGammaAdjust:cancelled', ...
            'Cancelled by user.');
    end
    g = str2double(str);
    f = figure;
    imshow(img.^g);
    choice = questdlg('Are you happy with the current gamma value?', ...
	'Gamma Correction', ...
	'Yes', 'No', 'Yes');
    if strcmp(choice, 'Yes')
        break;
    else
        close(f);
    end
end

end

