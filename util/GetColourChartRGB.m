function [rgb, ccs_struct] = GetColourChartRGB(img, ccs_struct)
%% GetColourChartRGB Get the RGB values off a colour chart
%   Parameters:
%       img - the raw image of a colour checker
%
%   Outputs:
%       ccs_struct : the struct which describes the configuration of the
%                    colour checker.
%       rgb : A matrix with the rgb values of the colour checker

%% Sanity check
if ndims(img) ~= 3
    error('The parameter img is not an image.');
end

if exist('ccs_struct', 'var')
    % The user supplied a colour checker settings struct
    if ~isa(ccs_struct, 'struct')
        % The supplied struct has a strong format.
        error('ccs_struct has a wrong format');
    end
    
    % We haven't errored out, so let's copy out ccs_struct's settings. 
    x_start = ccs_struct.x_start;
    x_spacing = ccs_struct.x_spacing;
    x_end = ccs_struct.x_end;
    
    y_start = ccs_struct.y_start;
    y_spacing = ccs_struct.y_spacing;
    y_end = ccs_struct.y_end;
    
    gamma_value = ccs_struct.gamma_value;
    ps = ccs_struct.ps;
    
    x_count = ccs_struct.x_count;
    y_count = ccs_struct.y_count;
    
    cpc = ccs_struct.cpc;
    
    figure_handle = figure;
    imshow(img.^gamma_value);
    
    hold on;
    for i = y_start:y_spacing:y_end
        for j = x_start:x_spacing:x_end
            rectangle('Position', [j-ps/2, i-ps/2, ps, ps], ...
                'EdgeColor', 'r', 'LineWidth', 2);
        end
    end
    plot(cpc(:,1), cpc(:,2), 'rx', 'MarkerSize', 15, 'LineWidth', 2);
    hold off;
    
else
    %% Adjust the gamma correction of the raw image
    [gamma_value, figure_handle] = imshowGammaAdjust(img);
    close(figure_handle);
    
    %% Gather some user input on how big the colour checker is.
    prompt = {'Please input the parameters for your colour chart:',...
        'Column:','Row:'};
    dlg_title = 'Input';
    num_lines = [0, 1, 1];
    defaultans = {'0','14','10'};
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    
    x_count = str2double(answer{2});
    y_count = str2double(answer{3});
    
    %% Start of colour patch selection loop
    while true
        %% Collecting coordinates of the corners of the colour checker.
        figure_handle = figure;
        imshow(img.^gamma_value);
        
        uiwait(msgbox(['Please select the centres of the colour '...
            'patches at the four corners']));
        
        % Note that the coordinates are in x,y format, even though the
        % matrices are addressed in y,x format!!!
        cpc = GetCoordFromImg(4); % Corner Patches Centre
        
        % Calculate the size of the colour chart
        x_size = mean([cpc(2,1) - cpc(1,1), cpc(3,1) - cpc(4,1)]);
        y_size = mean([cpc(3,2) - cpc(2,2), cpc(4,2) - cpc(1,2)]);
        
        % Calculate the size of spacing
        x_spacing = x_size / (x_count-1);
        y_spacing = y_size / (y_count-1);
        
        % Define the starting and ending positions
        x_start = cpc(1,1);
        y_start = cpc(1,2);
        x_end = cpc(3,1);
        y_end = cpc(4,2);
        
        %% Gather information on how big each colour patch is.
        uiwait(msgbox(['Please draw a rectangle around a colour'...
            ' patch for this region will be replicated across all'...
            ' colour patches for sampling purposes']));
        p_rect = getrect();
        ps = mean([p_rect(3), p_rect(4)]);
        
        %% Looping through the colour checker to draw the rectangles
        hold on;
        
        % Make sure that we draw enough rectangles
        if size(x_start:x_spacing:x_end) < x_count
            x_end = x_end + x_spacing;
        end
        
        if size(y_start:y_spacing:y_end) < y_count
            y_end = y_end + y_spacing;
        end
        
        % The actual drawing loop
        for i = y_start:y_spacing:y_end
            for j = x_start:x_spacing:x_end
                rectangle('Position', [j-ps/2, i-ps/2, ps, ps], ...
                    'EdgeColor', 'r','LineWidth', 2);
            end
        end
        hold off;
        choice = questdlg('Are you happy with the selection?', ...
            'Selection confirmation', ...
            'Yes', 'No', 'Yes');
        if strcmp(choice, 'Yes')
            break;
        else
            close(figure_handle);
        end
    end
    
    % Write the ccs_struct
    ccs_struct.x_start = x_start;
    ccs_struct.x_spacing = x_spacing;
    ccs_struct.x_end = x_end;
    
    ccs_struct.y_start = y_start;
    ccs_struct.y_spacing = y_spacing;
    ccs_struct.y_end = y_end;
    
    ccs_struct.gamma_value = gamma_value;
    ccs_struct.ps = ps;
    
    ccs_struct.x_count = x_count;
    ccs_struct.y_count = y_count;
    
    ccs_struct.cpc = cpc;
    
    %% End of Selection loop
end



%% Collecting colour patch samples
k = 1;
rgb = zeros(x_count * y_count, 3);
for i = y_start:y_spacing:y_end
    for j = x_start:x_spacing:x_end
        this_patch = img(floor(i-ps/2):ceil(i+ps/2), ..., 
            floor(j-ps/2):ceil(j+ps/2), :);
        patch_mean = mean(mean(this_patch,1),2);
        rgb(k,:) = patch_mean;
        k = k + 1;
    end
end


end

