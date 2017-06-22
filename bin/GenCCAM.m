function M = GenCCAM(rgb,xyz)
% AMCAL computes the colour correction matrix by using
% angular minimisation.
%
% Input:
% rgb - RGBs (N-by-3)
% xyz - XYZs (N-by-3)

% Copyright 2016 Han Gong <gong@fedoraproject.org>,
% University of East Anglia

% Refrence:
% Funt, B., and P. Bastani. "Intensity independent rgb-to-xyz colour
% camera calibration." AIC (International Colour Association) Conference.
% Vol. 5. 2012.

M0 = rgb\xyz;
opt = optimset('MaxFunEvals',50000,'MaxIter',50000);
M = fminsearch(@(x) AM(rgb,xyz,x),M0,opt);
%M = fminsearch(@(x) LSM(rgb,xyz,x),M0,opt);
M = M/sum(M(:))*3; % rescale the matrix

%% Resolve scaling ambiguity
M = ResolveScalingAmbiguity(M, rgb, xyz);

end

function err = AM(RGB,XYZ,M)
% FUNTANDBASTANI computes the angular error
%
% INPUT
% RGB - RGBs
% XYZ - XYZs
% M - colour correction matrix

    Npatch = size(RGB,1);
    FB = zeros(Npatch,1);

    eXYZ = RGB*M; % apply colour correction

    for j = 1:Npatch
        F1 = eXYZ(j,:)/norm(eXYZ(j,:));
        F2 = XYZ(j,:)/norm(XYZ(j,:));
        FB(j) = sum(F1.*F2);
    end

    err = sum(acos(FB));
end
