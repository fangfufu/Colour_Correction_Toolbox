function M = GenCCALS(rgb,xyz,Niter)
% GENCCALS computes the colour correction matrix by using
% the alternating least squares method with a diagnoal
% shading matrix
%
% rgb - RGBs (N-by-3)
% xyz - XYZs (N-by-3)
% Niter - number of iteration (default 100)

% Copyright 2016 Han Gong <gong@fedoraproject.org>,
% University of East Anglia

% Refrence:
% Finlayson, G. D., Mohammadzadeh Darrodi, M. and Mackiewicz, M. (2015),
% The alternating least squares technique for nonuniform intensity color
% correction. Color Res. Appl., 40: 232–242.

if nargin<3, Niter = 100; end

Npatch = size(rgb,1); % number of patches
D = speye(Npatch); % initialise shading matrix
urgb = rgb; % updated rgb values

for i = 1:Niter
    for j = 1:Npatch % update shading
        % can be optimised but left for clearity 
        D(j,j) = xyz(j,:)/urgb(j,:);
    end
   	M = (D*rgb)\xyz; % update correction matrix
    urgb = rgb*M; % update current approximation
end
