function [cielab_e] = MI_evaluation_single(illum, reflectance, ...
    cam_resp, eye_resp, matrix_gen_func, rpp, deg)
%%MI_EVALUATION This function evaluates Maximum Ignorance algorithm 
% by outputting CIELAB error for a single illuminant
%   Let n be the number of wavelength samples
%   - light is a n-vector representing the illuminant intensity at each
%   wavelength
%   - reflectance is a n-times-m matrix, with reflectance of m material
%   samples at n wavelength. 
%   - cam_resp is a n-times-3 matrix representing the camera response 
%   at n-wavelength
%   - eye_resp is a n-times-3 matrix representing the colour matching
%   fucntion
%   - rpp is the MI colour correction function

% The colour signal
colour = reflectance.*repmat(illum,1,size(reflectance, 2));

%the true xyz of the colour patch
true_xyz = colour' * eye_resp;

%the whitepoint of the light source
wp = calc_whitepoint(illum, eye_resp);

true_lab = xyz2lab(true_xyz, 'WhitePoint', wp);

rgb = colour'*cam_resp;

rgb_x = matrix_gen_func(rgb, deg);

cam_xyz = (rpp * rgb_x')';

cam_lab = xyz2lab(cam_xyz, 'WhitePoint', wp);

cielab_e = sqrt(sum(((cam_lab - true_lab).^2),2));

end
