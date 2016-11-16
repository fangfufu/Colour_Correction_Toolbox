function [ MI_emat, MI_pos_emat] = MI_evaluation( set_name )

load([set_name, '_MI_ccms.mat']);
load([set_name, '_combined_set']);

% Uncomment here to use MIP code from Graham
% MI_pos_ccm = MIP(cam_resp, eye_resp);

% Uncomment here to use raw illumination
% load('data/illumination_raw.mat');
% illumination = parse_dataset(illumination, [380:4:780]',wavelength); %#ok<NODEF>

illum_count = size(illumination, 2); %#ok<NODEF>
ref_count = size(reflectance, 2); 

MI_emat = zeros(ref_count, illum_count);
MI_pos_emat = zeros(ref_count, illum_count);
MI_pos_poly_emat = zeros(ref_count, illum_count);


disp('     ');
for i = 1:illum_count
    fprintf('\b\b\b\b\b\b%05.2f%%', i/illum_count*100);
    MI_emat(:,i) = MI_evaluation_single(illumination(:,i), reflectance, cam_resp, ...
        eye_resp, @gen_polynomial_matrix, MI_ccm, 1);
end
disp(' ');

% CHECKPOINT
% MI_pos_ccm = MIP(cam_resp, eye_resp);
disp('     ');
for i = 1:illum_count
    fprintf('\b\b\b\b\b\b%05.2f%%', i/illum_count*100);
    MI_pos_emat(:,i) = MI_evaluation_single(illumination(:,i), reflectance, cam_resp, ...
        eye_resp, @gen_polynomial_matrix, MI_pos_ccm, 1);
end
disp(' ');

disp('     ');
for i = 1:illum_count
    fprintf('\b\b\b\b\b\b%05.2f%%', i/illum_count*100);
    MI_pos_poly_emat(:,i) = MI_evaluation_single(illumination(:,i), reflectance, cam_resp, ...
        eye_resp, @gen_polynomial_matrix, MI_pos_poly_ccm, 2);
end
disp(' ');

disp('MI');
disp(mean(MI_emat(:)));
disp('MIP');
disp(mean(MI_pos_emat(:)));
disp('MIPP');
disp(mean(MI_pos_poly_emat(:)));

save([set_name,'_MI_errors.mat'], 'MI_emat', 'MI_pos_emat', 'MI_pos_poly_emat', 'set_name');

end

