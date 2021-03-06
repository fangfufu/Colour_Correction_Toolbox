%% Load data and settings
clear;
load anonymousTestData RGB XYZ w_idx
WPP_flag = 1;
sep_deg = 5;
reqNoPatches = 5;
partitions=4;

%% Set up training / verification folds
training_mask = rand(96,1) > 0.1;
verification_mask = ~training_mask;
XYZwpt = XYZ(w_idx,:);
RGBwpt = RGB(w_idx,:);

 %training_mask = true(96,1);
 %verification_mask = training_mask;

t_id = find(training_mask);
v_id = find(verification_mask);

disp(['Size of t_id: ', num2str(size(t_id,1)), ...
    ' size of v_id: ', num2str(size(v_id,1))]);

RGBt = RGB(t_id, :);
XYZt = XYZ(t_id, :);

%% Tag the white point on the end of training set. 
RGBt(end+1,:) = RGBwpt; 
XYZt(end+1,:) = XYZwpt;

RGBv = RGB(v_id, :);
XYZv = XYZ(v_id, :);

%% Generate Colour Correction Matrix
[mat,~,~,boundaryH] = colour_correction_NHPPCC(RGBt,XYZt,size(RGBt,1),partitions,WPP_flag,sep_deg,reqNoPatches);

%% calculate XYZs from RGBs and their hue region indices
RGBvwb = RGBv./repmat(RGB(w_idx,:),size(RGBv,1),1); %Regularise RGB readings
HAv = RGB2HueAngleWithoutNorm(RGBvwb); % Hue Angle for the verification set
indv = HA2Partition(HAv,boundaryH); % Indices for the verification set
[XYZe] = conversionCameraHPPCC(mat,indv,RGBvwb); %estimated XYZ

%% and lab error
Lab_ref=xyz2lab(XYZ,'Whitepoint', XYZwpt);
Lab_ref = Lab_ref(v_id, :);
Lab=xyz2lab(XYZe,'Whitepoint', XYZwpt);
error = mean(sqrt(sum((Lab-Lab_ref).^2,2)));
disp(['CIELAB Error:' num2str(error)]);

%% Draw the training set and verification set
nrows = 10;
ncols = 10;
XYZ_RGBt = xyz2rgb(XYZt, 'WhitePoint', XYZwpt);
XYZ_RGBv = xyz2rgb(XYZv, 'WhitePoint', XYZwpt);
XYZ_RGBt(isnan(XYZ_RGBt)) = 0;
XYZ_RGBv(isnan(XYZ_RGBv)) = 0;
XYZ_RGBt(XYZ_RGBt > 1) = 1;
XYZ_RGBt(XYZ_RGBt < 0) = 0;
XYZ_RGBv(XYZ_RGBv > 1) = 1;
XYZ_RGBv(XYZ_RGBv < 0) = 0;

figure;
axis equal;
title('RGB Training set');
k = 1;
for j = 1:nrows
    for i = 1:ncols
        rectangle('Position', [i * 10, -j * 10, 10, 10], 'FaceColor', ...
            XYZ_RGBt(k,:));
        k = k + 1;
        if k > size(XYZ_RGBt, 1)
            break;
        end
    end
    if k > size(XYZ_RGBt, 1)
        break;
    end
end

figure;
axis equal;
title('RGB verification set');
k = 1;
for j = 1:nrows
    for i = 1:ncols
        rectangle('Position', [i * 10, -j * 10, 10, 10], 'FaceColor', ...
            XYZ_RGBv(k,:));
        k = k + 1;
        if k > size(XYZ_RGBv, 1)
            break;
        end
    end
    if k > size(XYZ_RGBv, 1)
        break;
    end
end
