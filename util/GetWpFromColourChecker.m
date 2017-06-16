function [ wp, ind ] = GetWpFromColourChecker( mat )
%% GET_WP_FROM_COLOUR_CHART_MAT 
% Get the whitepoint from a matrix containing colour checker data.
%
% In CIEXYZ, the Y channel is normally used as an estimation for luminance.
% Therefore we are getting the brightest colour patch using using the 
% second channel.
ind = find(mat(:,2) == max(mat(:,2)));
% Make sure that we only output a unique whitepoint
ind = ind(1);
wp = mat(ind,:);
end

