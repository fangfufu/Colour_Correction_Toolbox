function M = GenCCHomo(rgb,xyz,max_iter,tol)
%% ALSHOMOCAL computes the colour correction matrix by using
% the homogrpahy based method
%
% rgb - RGBs (N-by-3)
% xyz - XYZs (N-by-3)
% Niter - number of iteration (default 100)

% Copyright 2016 Han Gong <gong@fedoraproject.org>,
% University of East Anglia

% Refrence:
% Finlayson, G. D., Gong, H., Fisher, B. R. (2016), Color homography,
% Progress in Colour Studies.

if nargin<3, max_iter = 50; end
if nargin<4, tol = 1e-20; end

M = uea_H_from_x_als(rgb',xyz',max_iter,tol);

M = M';

%% Resolve scaling ambiguity
M = ResolveScalingAmbiguity(M, rgb, xyz);

end

function [H,err,pD] = uea_H_from_x_als(p1,p2,max_iter,tol)

% [H,rms,pa] = uea_H_from_x_als(H0,p1,p2,max_iter,tol)
%
%% Compute H using alternating least square

% An initial estimate of
% H is required, which would usually be obtained using
% vgg_H_from_x_linear. It is not necessary to precondition the
% supplied points.
%
% The format of the xs is
% [x1 x2 x3 ... xn ; 
%  y1 y2 y3 ... yn ;
%  w1 w2 w3 ... wn]

if nargin<3, max_iter = 50; end
if nargin<4, tol = 1e-20; end

[Nch,Npx] = size(p1);

ind1 = sum(p1>0 & p1<Inf,1)==Nch;
ind2 = sum(p2>0 & p2<Inf,1)==Nch;
vind = ind1 & ind2;
kind = find(vind);

if (size(p1) ~= size(p2))
 error ('Input point sets are different sizes!')
end

N = p1;
D = speye(Npx);

errs = Inf(max_iter+1,1); % error history

% solve the homography using ALS
n_it = 1; d_err = Inf;
while ( n_it-1<max_iter && d_err>tol )
    n_it = n_it+1; % increase number of iteration

    D = SolveD1(N,p2);

    P_d = p1*D; % apply shading correction
    H = p2(:,vind)/P_d(:,vind); % update M
    N = H*p1;

    NDiff = (N*D-p2).^2; % difference
    errs(n_it) = mean(mean(NDiff(:,vind))); % mean square error
    d_err = errs(n_it-1) - errs(n_it); % 1 order error
end

err = errs(n_it);
pD = D;

%plot(errs); hold on;
%fprintf('ALS %d: %f\n',n_it,errs(n_it));

%figure; imagesc(reshape(diag(D),4,6));

end

% improved D1 solver, needs testing.
function D = SolveD1(p,q)
    [nCh,nPx] = size(p);
    d = (ones(1,nCh)*(p.*q))./(ones(1,nCh)*(p.*p));
    D = spdiags(d',0,nPx,nPx);
end
