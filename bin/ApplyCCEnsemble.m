function [ xyz ] = ApplyCCEnsemble( rgb, ccm )
%% APPLYCCENSEMBLE Apply the method of ensemble colour correction

ALSXyz = ApplyCCLinear(rgb, ccm.ccmALS);
HomoXyz = ApplyCCLinear(rgb, ccm.ccmHomo);
LinearXyz = ApplyCCLinear(rgb, ccm.ccmLinear);
RPXyz = ApplyCCRootPolynomial(rgb, ccm.ccmRP);

ensembleXyz = [ALSXyz, HomoXyz, LinearXyz, RPXyz];

xyz = ensembleXyz * ccm.ensemble;

end

