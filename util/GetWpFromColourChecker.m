function [ wp, ind ] = GetWpFromColourChecker( mat )
%% GET_WP_FROM_COLOUR_CHART_MAT 
% Get the whitepoint from a matrix containing colour checker data.

matsum = sum(mat, 2);
ind = find(matsum == max(matsum));
% Make sure that we only output a unique whitepoint
ind = ind(1);
wp = mat(ind,:);
end

