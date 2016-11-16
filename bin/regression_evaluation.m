function [ regression_emat ] = regression_evaluation( set_name )

load([set_name, '_combined_set']);

illum_count = size(illumination, 2);
fold_count = 10;

% Format of this matrix:
%   [surface, illuminant, polynomial degree]
regression_emat = [];

for j = 1:2
    disp('     ');
%     for i = 1:illum_count
%         fprintf('\b\b\b\b\b\b%05.2f%%', i/illum_count*100);
        regression_emat(:,j) = ...
            regression_evaluation_single(illumination, ...
            reflectance, cam_resp, eye_resp, fold_count, ...
            @gen_polynomial_matrix, j); %#ok<AGROW>
%     end
    disp(' ');
end

save([set_name,'_regression_errors_rand.mat'], 'regression_emat', 'set_name');


end
