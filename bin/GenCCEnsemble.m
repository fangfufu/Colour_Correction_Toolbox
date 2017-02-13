function [ ccm ] = GenCCEnsemble( rgb, xyz, t_factor )
%% GENCCENSEMBLE Generate the struct for ensemble colour correction
ccm.ccmALS = GenCCALS(rgb, xyz);
ccm.ccmHomo = GenCCHomo(rgb, xyz);
ccm.ccmLinear = GenCCLinear(rgb, xyz);
ccm.ccmRP =  GenCCRootPolynomial(rgb, xyz, 2);

ALSXyz = ApplyCCLinear(rgb, ccm.ccmALS);
HomoXyz = ApplyCCLinear(rgb, ccm.ccmHomo);
LinearXyz = ApplyCCLinear(rgb, ccm.ccmLinear);
RPXyz = ApplyCCRootPolynomial(rgb, ccm.ccmRP);

eXyz = [ALSXyz, HomoXyz, LinearXyz, RPXyz];

if ~exist('t_factor', 'var')
    t_factor = 0;
end

ccm.ensemble = (eXyz' * eXyz + t_factor * eye(size(eXyz, 2)) ) \ (eXyz' * xyz);

end

