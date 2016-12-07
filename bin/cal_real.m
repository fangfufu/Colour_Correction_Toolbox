addpath('../ultilities');
clear all
% configration
dbpath = '../'; % path of rawdata
%fmethod = {@alshomocal,@lscal,@alscal,...
           %@(p1,p2) alsDCTcal(p1,p2,[4,6]),@amcal,...
           %@rpcal, @alsRPcal, @nrpdEcal};
%Method = {'ALS_H';'LS';'ALS';'ALS_DCT';'AM';'RP';'ALS_RP';'NRPDE'};
fmethod = {@alshomocal;@alscal;@amcal;@lscal;...
           @(p1,p2) alsRPcal(p1,p2,[4,6]);@rpcal;@als3Dhomocal;...
           @DLT_lsqnonlin};
Method = {'ALS_H';'ALS';'AM';'LS';'ALS_RP';'RP';'ALS_H_R';...
    'DLT_LSQNONLIN'};

load([dbpath,'ref.mat']); % reference data

% discover a list of images for conversion
fl = getAll([dbpath,'patch_real'],'f'); % get all files
fn = {}; % empty file name

for i = 1:numel(fl)
    [~,ei] = regexp(fl{i},'\S_\d');
    if any(ei)
        fn{end+1} = fl{i}(1:ei);
    end
end

fn = fn(1:3); % for testing individual cases
Npic = numel(fn);
Npatch = size(ref.XYZ,1);
Nmethod = numel(fmethod);

% non-uniform shading errors
de00_n = zeros(Npatch,Npic,Nmethod);
de76_n = zeros(Npatch,Npic,Nmethod);
deluv_n = zeros(Npatch,Npic,Nmethod);

% uniform shading errors
de00_u = zeros(Npatch,Npic,Nmethod);
de76_u = zeros(Npatch,Npic,Nmethod);
deluv_u = zeros(Npatch,Npic,Nmethod);

% relative difference of correction matrix
md = zeros(1,Npic,Nmethod);

xyz_std = ref.XYZ./ref.XYZ(4,2); % refernece XYZ
%xyz_std = ref.XYZ; % refernece XYZ
lab_ref = HGxyz2lab(xyz_std,xyz_std(4,:)); % reference LAB
luv_ref = HGxyz2luv(xyz_std,xyz_std(4,:)); % reference LUV

for i = 1:Npic

    % load data
    load([dbpath,'patch_real/',fn{i},'.mat']);

    % compute colour correction matrix
    fsv = reshape(cap.sv,[],3);
    fsv_uniform = reshape(cap.sv_uniform,[],3);
    for m = [1,2,3,4,8]%1:Nmethod
        % compute the transform
        switch Method{m}
        case {'ALS_H_LUV_R','ALS_H_LUV'}
            M_n = fmethod{m}(fsv,xyz_std,xyz_std(4,:));
            M_u = fmethod{m}(fsv_uniform,xyz_std,xyz_std(4,:));
        otherwise
            %aa = true(24,1); aa([7,11,14,21,22,23,24]) = 0;
            M_n = fmethod{m}(fsv,xyz_std);
            M_u = fmethod{m}(fsv_uniform,xyz_std);
        end

        % compute xyz using ground truth RGB
        switch Method{m}
        case {'ALS_H','ALS_H_LUV','ALS_H_R','ALS_H_LUV_R', 'DLT_LSQNONLIN'} % ALS_H
            xyz_est_n = uea_homocvt(fsv_uniform,M_n);
            xyz_est_u = uea_homocvt(fsv_uniform,M_u);
        case {'ALS_RP'}
            xyz_est_n = M_n.cfun(fsv_uniform',M_n.matrix,M_n.terms)';
            xyz_est_u = M_u.cfun(fsv_uniform',M_u.matrix,M_u.terms)';
        case {'RP','NRPDE','ALS_H_RP'}
            xyz_est_n = M_n.cfun(fsv_uniform,M_n.matrix,M_n.terms);
            xyz_est_u = M_u.cfun(fsv_uniform,M_u.matrix,M_u.terms);
        otherwise
            xyz_est_n = fsv_uniform*M_n;
            xyz_est_u = fsv_uniform*M_u;
        end

        %sc_n = mean(xyz_est_n(4,:))/mean(xyz_std(4,:));
        %sc_u = mean(xyz_est_u(4,:))/mean(xyz_std(4,:));
        %XYZ_est_n = bsxfun(@rdivide, xyz_est_n, sc_n);
        %XYZ_est_u = bsxfun(@rdivide, xyz_est_u, sc_u);
        XYZ_est_n = xyz_est_n./xyz_est_u(4,2); % normalise
        XYZ_est_u = xyz_est_u./xyz_est_u(4,2); % normalise
        if strcmp(Method{m},'DLT_LSQNONLIN')
            disp('breakpoint');
        end
        % DEBUG INFORMATION
        %{
        %if (i==6 && (m==1)) % || m==5))
        figure('Name',Method{m});
        kk = reshape(xyz_est_n,[4,6,3]);
        kk = xyz2rgb(kk);
        kk = bsxfun(@rdivide, kk, kk(4,1,:));
        subplot(1,2,1);
        imagesc(kk);
        axis off; axis equal;
        %osz = size(cap.wc);
        %kk = xyz_std*(xyz_est_u(4,2)/xyz_std(4,2));
        %kk = reshape(kk,[4,6,3]);
        kk = bsxfun(@rdivide, xyz_est_n, xyz_est_n(4,:));
        kk = reshape(xyz_std,[4,6,3]);
        kk = xyz2rgb(kk);
        kk = bsxfun(@rdivide, kk, kk(4,1,:));
        %kk = imresize(kk,osz(1:2),'nearest');
        %imwrite(kk,'GT.tif');
        %rgb_est = xyz2rgb(reshape(xyz_est_n,[4,6,3]));
        %rgb_est = imresize(rgb_est,osz(1:2),'nearest');
        %imwrite(rgb_est,[num2str(m),'.tif']);
        %kk = kk./max(kk(:));
        subplot(1,2,2);
        imagesc(kk);
        axis off; axis equal;
        %end
        %}
        % Evaluation
        % non-uniform test DE
        lab_est_n = HGxyz2lab(XYZ_est_n,xyz_std(4,:));
        de00_n(:,i,m) = deltaE2000(lab_ref,lab_est_n);
        de76_n(:,i,m) = deltaE1976(lab_ref,lab_est_n);
        % uniform test DE
        lab_est_u = HGxyz2lab(XYZ_est_u,xyz_std(4,:));
        de00_u(:,i,m) = deltaE2000(lab_ref,lab_est_u);
        de76_u(:,i,m) = deltaE1976(lab_ref,lab_est_u);

        % LUV error
        luv_est_n = HGxyz2luv(XYZ_est_n,xyz_std(4,:));
        luv_est_u = HGxyz2luv(XYZ_est_u,xyz_std(4,:));

        deluv_n(:,i,m) = deltaE1976(luv_ref,luv_est_n);
        deluv_u(:,i,m) = deltaE1976(luv_ref,luv_est_u);
    end
end

% print evaluation results
%gentab(de00_n,Method,'DeltaE 2000 (Non-Uniform)');
t76_n = gentab(de76_n,Method,'DeltaE 1976 (Non-Uniform)');
tluv_n = gentab(deluv_n,Method,'DeltaE LUV (Non-Uniform)');
%gentab(de00_u,Method,'DeltaE 2000 (Uniform)');
%t76_u = gentab(de76_u,Method,'DeltaE 1976 (Uniform)');
%tluv_u = gentab(deluv_u,Method,'DeltaE LUV (Uniform)');

% save tables
%writetable(t76_n,'t76_n.csv','WriteRowNames',true);
%writetable(t76_u,'t76_u.csv','WriteRowNames',true);

rmpath('../ultilities');
