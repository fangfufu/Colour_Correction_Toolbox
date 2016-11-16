function [cielab_e] = regression_evaluation_single(illumination, reflectance, ...
    cam_resp, eye_resp, fold_count, matrix_gen_func, deg)
%%MI_EVALUATION This function evaluates Maximum Ignorance algorithm 
% by outputting CIELAB error
%   Let n be the number of wavelength samples
%   - light is a n-vector representing the illuminant intensity at each
%   wavelength
%   - reflectance is a n-times-m matrix, with reflectance of m material
%   samples at n wavelength. 
%   - cam_resp is a n-times-3 matrix representing the camera response 
%   at n-wavelength
%   - eye_resp is a n-times-3 matrix representing the colour matching
%   fucntion

%% Variable initialisation

illum_count = size(illumination, 2);

colour = [];
for i = 1:illum_count
    illum = illumination(:,i);
    sub_colour = reflectance.*repmat(illum,1,size(reflectance, 2));
    colour = [colour, sub_colour];
end
colour = rand(size(colour));

% The colour signal

% the true xyz of the colour patch
true_xyz = colour' * eye_resp;

% the whitepoint of the light source
wp = calc_whitepoint(illum, eye_resp);

% the true CIELAB coordinate
true_lab = xyz2lab(true_xyz, 'WhitePoint', wp);

% the rgb responses from the camera
rgb = colour'*cam_resp;

% the polynomial expansion of the camera's rgb response
rgb_x = matrix_gen_func(rgb, deg);

% initialise loop variable
reflectance_size = size(colour, 2);
cielab_e = [];

%% Main loop
% This loop implements cross-validation.

for i = 1:fold_count
    % NOTE: 
    % tr_ for training
    % ts_ for testing
    
    % Training
    ts_ind = i:fold_count:reflectance_size;
    tr_ind = setdiff(1:reflectance_size, ts_ind);
    tr_rgb_x = rgb_x(tr_ind, :);
    tr_true_xyz = true_xyz(tr_ind, :);
    ccm = linear_regression(tr_rgb_x, tr_true_xyz);
    
    % Testing
    ts_rgb_x = rgb_x(ts_ind, :);
    ts_true_lab = true_lab(ts_ind, :);
    ts_cam_xyz = (ccm * ts_rgb_x')';
    ts_cam_lab = xyz2lab(ts_cam_xyz, 'WhitePoint', wp);
    ts_cielab_e = sqrt(sum(((ts_cam_lab - ts_true_lab).^2),2));
    
    % Note that we are appending the vector, hence the AGROW suppression. 
    cielab_e = [cielab_e; ts_cielab_e]; %#ok<AGROW>
end

end

