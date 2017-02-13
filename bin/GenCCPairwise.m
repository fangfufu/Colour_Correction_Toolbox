function [ ccm ] = GenCCPairwise( rgb, xyz, gfunc1, gfunc2, ...
    afunc1, afunc2, t_factor )
%GENCCPAIRWISE Summary of this function goes here
%   Detailed explanation goes here
ccm.func1 = gfunc1(rgb, xyz);
ccm.func2 = gfunc2(rgb, xyz);
ccm.afunc1 = afunc1;
ccm.afunc2 = afunc2; 

func1Xyz = afunc1(rgb, ccm.func1);
func2Xyz = afunc2(rgb, ccm.func2);

eXyz = [func1Xyz, func2Xyz];

if ~exist('t_factor', 'var')
    t_factor = 0;
end

ccm.pairwise = (eXyz' * eXyz + t_factor * eye(size(eXyz, 2)) ) \ (eXyz' * xyz);

end

