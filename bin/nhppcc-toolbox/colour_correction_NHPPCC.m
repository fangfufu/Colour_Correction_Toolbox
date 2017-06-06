function [T,HA,ind,boundaryH] = colour_correction_NHPPCC(RGB,XYZ,w_idx,Q,WPP_flag,sep_deg,reqNoPatches)
% Michal Mackiewicz, University of East Anglia, UK, 15/12/16
% NHPPCC implementation as described in
% J Opt Soc Am A; 2016 Nov 1; 33(11):2166-2177. doi: 10.1364/JOSAA.33.002166.
%INPUTS:
% RGB - N x 3 input RGBs
% XYZ - N x 3 corresponding XYZs
% w_idx - index to the white patch sample
% Q - number of hue partitions in NHPPCC
% WPP_flag - white point preserving flag (1 or 0)
% sep_deg - minimum hue angle [degrees] of each hue region
% reqNoPatches - minimum number of colour samples in each hue region
%OUTPUTS:
% T    - Q*3 x 3 matrix containing Q 3x3 colour correction matrices
% HA   - N x 1 colour sample hue angles 
% ind  - 1 x Q cell array containing RGB indices
% boundaryH - 1 x Q hue region boundaries
[HA,RGB] = RGB2HueAngle(RGB,w_idx);
if Q ==1 % linear colour correction
    if WPP_flag
        A = RGB;
        C = RGB(w_idx,:);
        T = solve_ConLSQ(A,XYZ,C,XYZ(w_idx,:));
        T = T(1:3,:);
    else
        T = RGB\XYZ;
    end
    HA=[]; ind=[]; boundaryH=[];
    return
else
        %x - initial partitions
        if Q==2
            steps = 100;
            x = 2*pi/steps:2*pi/steps:2*pi-.0001;
            x = [x' x'+pi];
        else
            ns = round(200/Q);
            step = 100/Q;
            x = zeros(ns,Q);
            for i=1:ns
                x(i,:) = prctile(HA,step/ns*i:step:100);
            end
        end
        
            if sep_deg>0
                opts = optimoptions('fmincon');
                x = sort(x,2);
                A = diag(ones(Q,1))+diag(-ones(Q-1,1),1);
                A(end,1)=-1;
                b = -ones(Q,1)*sep_deg/360*2*pi;
                b(end) = b(end)+2*pi;
                if Q>2
                    [~,col] = find(A*x'-repmat(b,1,size(x,1))>opts.TolCon);
                else
                    [~,col] = find(x(:,2)'>=2*pi);
                end
                idx = setdiff(1:size(x,1),unique(col));
                if reqNoPatches>0
                    idx2del = [];
                    for i=idx
                        Cineq = conReqNoPatches(x(i,:),RGB,HA,reqNoPatches);
                        if max(Cineq)>0
                            idx2del = [idx2del i];
                        end
                    end
                    idx = setdiff(idx,idx2del);
                end
            else
                idx = 1:size(x,1);
            end
            errorf = ones(size(x,1),1)*Inf;
            for i=idx
                [errorf(i)] = optimiseBoundaries(x(i,:),HA,RGB,XYZ,w_idx, WPP_flag);
            end
            [minv,mini]=min(errorf);
            display(['Q=',int2str(Q),', error after initial exhaustive search:',num2str(minv)]);
            startPositions = x(mini,:);
            if Q>2
                A = diag(ones(Q,1))+diag(-ones(Q-1,1),1);
                A(end,1)=-1;
                b = -ones(Q,1)*sep_deg/360*2*pi;
                b(end) = b(end)+2*pi;
                Aeq = [];
                beq = [];
            else %partions=2
                A=[];
                b=[];
                Aeq = [1 -1];
                beq = -pi;
            end
            lb = zeros(Q,1);
            ub = ones(Q,1)*2*pi;
            [Hset,error] = fmincon(@(x) optimiseBoundaries(x,HA,RGB,XYZ,w_idx,WPP_flag),startPositions,A,b,Aeq,beq,lb,ub,@(x) conReqNoPatches(x,RGB,HA,reqNoPatches),opts);
            display(['Q=',int2str(Q),', error after finetuning:',num2str(error)]); 
    [~,T,ind,boundaryH] = optimiseBoundaries(Hset,HA,RGB,XYZ,w_idx,WPP_flag); 
end
end

function [error,T,ind,boundaryH] = optimiseBoundaries(H,HA,RGB,XYZ,w_idx,WPP_flag)
Q = numel(H);
for i=1:Q
    if H(i)<0
        H(i) = H(i)+2*pi;
    end
end
if Q == 2
   H(2) = H(1)+pi;
end
H = rem(H,2*pi);
H = sort(H);
idx_train = 1:size(RGB,1);
idx_validate = 1:size(RGB,1);
for i=0:Q-1
    if i==0
        ind{i+1} = find(HA<=H(1)|HA>H(end));
    else
        ind{i+1} = find(HA<=H(i+1)&HA>H(i));
    end
    ind2{i+1} = intersect(ind{i+1},idx_train);
    ind3{i+1} = intersect(ind{i+1},idx_validate);
end
A = zeros(size(RGB(idx_train,:),1),3*Q);
C = zeros(Q,3*Q);
C2 = zeros(Q-1,3*Q);

count = 0;
XYZ2 = zeros(size(XYZ(idx_train,:)));
for i=0:Q-1
    if i==Q-1
        rgtmp = hueAngle2rg(H(i+1));
        rgbtmp = [rgtmp 1-rgtmp(1)-rgtmp(2)];
        C(i+1,1:3) = rgbtmp; 
        C(i+1,end-3+1:end) = -rgbtmp; 
        if Q==2
           C(i+1,:) = []; 
        end
    else
        rgtmp = hueAngle2rg(H(i+1));
        rgbtmp = [rgtmp 1-rgtmp(1)-rgtmp(2)];
        C(i+1,i*3+1:i*3+2*3) = [rgbtmp, -rgbtmp]; 
        C2(i+1,i*3+1:i*3+2*3) = [RGB(w_idx,:), -RGB(w_idx,:)]; 
    end
    A(count+1:count+numel(ind2{i+1}),3*i+1:3*i+3) = RGB(ind2{i+1},:);
    XYZ2(count+1:count+numel(ind2{i+1}),:) = XYZ(ind2{i+1},:);
    count = count+numel(ind2{i+1});
end
    C = [C;C2];

if WPP_flag
    C3 = zeros(1,3*Q);
    C3(1,1:3) = RGB(w_idx,:);
    ro_c = [C;C3];
    x_c = [zeros(size(C,1),3);XYZ(w_idx,:)];
else
    ro_c = C;
    x_c = zeros(size(C,1),3);
end
T = solve_ConLSQ(A,XYZ2,ro_c,x_c);
T = T(1:Q*3,:);

white = XYZ(w_idx,:);
converted_XYZ_test = conversionCameraHPPCC(T,ind3,RGB);

Lab_test_ref=xyz2lab(XYZ(idx_validate,:),'Whitepoint', white);
Lab_test=xyz2lab(converted_XYZ_test(idx_validate,:),'Whitepoint', white);

error = mean(sqrt(sum((Lab_test-Lab_test_ref).^2,2)));
boundaryH = H;
end

function [C,Ceq] = conReqNoPatches(H,RGB,HA,reqNoPatches)
Q = numel(H);
for i=1:Q
    if H(i)<0
        H(i) = H(i)+2*pi;
    end
end
if Q == 2
   H(2) = H(1)+pi;
end
H = rem(H,2*pi);
H = sort(H);
idx_train = 1:size(RGB,1);
C = zeros(Q,1);
for i=0:Q-1
    if i==0
        ind{i+1} = find(HA<=H(1)|HA>H(end));
    else
        ind{i+1} = find(HA<=H(i+1)&HA>H(i));
    end
    ind2{i+1} = intersect(ind{i+1},idx_train);
    C(i+1) = reqNoPatches-numel(ind2{i+1});
        if i==0
            ind{i+1} = find(HA<=H(1)|HA>H(end));
            C(i+1) = C(i+1) - (2*pi - H(end) + H(1))/(2*pi);
        else
            C(i+1) = C(i+1) - (H(i+1)-H(i))/(2*pi);
        end
end
Ceq=[];
end
