function lab = HGxyz2lab(xyz,wp)
% HGXYZ2LAB converts XYZs to LABs
%
% INPUT
% xyz - XYZs
% wp - white point triple
% 
% OUTPUT
% lab - LABs
%
% Copyright 2015 Han Gong, University of East Anglia

if nargin<2, wp = [0.950456,1,1.088754]; end

X = xyz(:,1)/wp(1);
Y = xyz(:,2)/wp(2);
Z = xyz(:,3)/wp(3);
fX = f(X);
fY = f(Y);
fZ = f(Z);

lab = zeros(size(xyz));
lab(:,1) = 116*fY - 16;    % L*
lab(:,2) = 500*(fX - fY);  % a*
lab(:,3) = 200*(fY - fZ);  % b*

function fY = f(Y)
    fY = real(Y.^(1/3));
    i = (Y < 0.008856);
    fY(i) = Y(i)*(841/108) + (4/29);
end

end
