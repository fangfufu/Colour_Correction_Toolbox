clear

load anonymousTestData RGB XYZ w_idx
WPP_flag = 1;
sep_deg = 5;
reqNoPatches = 5;
partitions=4;

[T,~,~,boundaryHA] = colour_correction_NHPPCC(RGB,XYZ,w_idx,partitions,WPP_flag,sep_deg,reqNoPatches);

%% calculate XYZs from RGBs and their hue region indices
RGBwb = RGB./repmat(RGB(w_idx,:),size(RGB,1),1);

HAv = RGB2HueAngleWithoutNorm(RGBwb);
ind = HA2Partition(HAv,boundaryHA);

[XYZ1] = conversionCameraHPPCC(T,ind,RGBwb);

%% and lab error
Lab_ref=xyz2lab(XYZ,'Whitepoint', XYZ(w_idx,:));
Lab=xyz2lab(XYZ1,'Whitepoint', XYZ(w_idx,:));
error = mean(sqrt(sum((Lab-Lab_ref).^2,2)));