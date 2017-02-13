function [ wp ] = GetWpFromColourChecker( mat )
%% GET_WP_FROM_COLOUR_CHART_MAT 
% Get the whitepoint from a matrix containing colour checker data.
%
% In CIEXYZ, the Y channel is normally used as an estimation for luminance.
% Therefore we are getting the brightest colour patch using using the 
% second channel.

wp = mat(mat(:,2) == max(mat(:,2)),:);
end

