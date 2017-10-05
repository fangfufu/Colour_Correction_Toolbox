function H = GenCCHomoRansac(varargin)
% GenCCHomoRansac computes the colour correction matrix by using
% the homography based method plus RANSAC

% Arguments:
%    rgb   - Nx3 matrix for RGB
%    xyz   - Nx3 matrix for XYZ
%    white - white point XYZ values, 1x3 vector

% Returns:
%    H - 3x3 homography colour correction matrix

% Please note that the results are not stable due to its randomness.
% We thus recommend you to try it for many runs and pick the best.

% Reference:
% 'Color Homography Color Correction', Graham Finlayson, Han Gong,
% Robert Fisher, Color and Imaging Conference (CIC), 2016 

% Han Gong <gong@fedoraproject.org>
% School of Computing Sciences
% University of East Anglia

if numel(varargin) == 1
    varargin = varargin{1};
end
nargin = numel(varargin);
rgb = varargin{1};
xyz = varargin{2};
white = varargin{3};


[H,inliers] = uea_alsransac_luv(rgb',xyz',white',0.2);
% print in for debug
% inliers
H = H';

end

% UEA_RANSACFITHOMOGRAPHY - fits MD homography using RANSAC
%
% Usage:   [H,inlier] = uea_alsransac_luv(x1, x2, t, mit)
%
% Arguments:
%          x1  - 2xN or MxN set of homogeneous points.  If the data is
%                2xN it is assumed the homogeneous scale factor is 1.
%          x2  - 2xN or MxN set of homogeneous points such that x1<->x2.
%          t   - The distance threshold between data point and the model
%                used to decide whether a point is an inlier or not. 
%                Note that point coordinates are normalised to that their
%                mean distance from the origin is sqrt(2).  The value of
%                t should be set relative to this, say in the range 
%                0.001 - 0.01
%          mit - Max number of iteration
%
% Note that it is assumed that the matching of x1 and x2 are putative and it
% is expected that a percentage of matches will be wrong.
%
% Returns:
%          inliers - An array of indices of the elements of x1, x2 that were
%                    the inliers for the best model.
%          H       - The MxM homography such that x2 = H*x1.
%
% See Also: ransac, uea_H_from_x_als

% Han Gong <gong@fedoraproject.org>
% School of Computing Sciences
% University of East Anglia

function [H,inliers] = uea_alsransac_luv(x1, x2, white, t, mit)

    if nargin<5, mit = 5000; end

    if ~all(size(x1)==size(x2))
        error('Data sets x1 and x2 must have the same dimension');
    end
    
    [nd,npts] = size(x1);
    if nd < 3
        error('x1 and x2 must have at least 3 rows');
    end

    s = nd+1; % minmum number of points to solve homography
    if npts < s
        error('Must have at least %d points to fit homography',s);
    end

    % generate points combinations
    xcomb = combnk(1:s,3);
    ncomb = size(xcomb,1);

    fittingfn = @wrap_als;
    distfn    = @homogdist;
    degenfn   = @isdegenerate;

    % x1 and x2 are 'stacked' to create a 6xN array for ransac
    [~,inliers] = ransac([x1;x2], fittingfn, distfn,...
                         degenfn, s, t, 0, 100, mit);

    % Now do a final least squares fit on the data points considered to
    % be inliers.
    if numel(inliers)>=4
        H = uea_H_from_x_als(x1(:,inliers),x2(:,inliers));
    else
        H = uea_H_from_x_als(x1,x2);
    end

%----------------------------------------------------------------------
% Function to evaluate the forward transfer error of a homography with
% respect to a set of matched points as needed by RANSAC.

    function [inliers, H] = homogdist(H, x, t)

        lx1 = x(1:nd,:);   % Extract x1 and x2 from x
        lx2 = x((nd+1):end,:);

        % Calculate, in both directions, the transfered points    
        Hx1 = H*lx1;

        % Calculate lab distance
        luv_ref = HGxyz2luv(lx2',white)'; % reference LUV
        luv_est = HGxyz2luv(Hx1',white)'; % reference LUV

        uv_ref = bsxfun(@rdivide,luv_ref(2:3,:),max(luv_ref(1,:),eps));
        uv_est = bsxfun(@rdivide,luv_est(2:3,:),max(luv_est(1,:),eps));

        d = sqrt(sum((uv_ref-uv_est).^2,1));
        inliers = find(d<t);
    end

%----------------------------------------------------------------------
% Function to determine if a set of 4 pairs of matched points give rise
% to a degeneracy in the calculation of a homography as needed by RANSAC.
% This involves testing whether any 3 of the 4 points in each set is
% colinear. 
     
    function r = isdegenerate(x)
        lx1 = x(1:nd,:);   % Extract x1 and x2 from x
        lx2 = x((nd+1):end,:);

        ir1 = arrayfun(@(i) iscolinear_n(lx1(:,xcomb(i,:))), 1:ncomb);
        ir2 = arrayfun(@(i) iscolinear_n(lx2(:,xcomb(i,:))), 1:ncomb);

        r = any([ir1,ir2]);
    end

    function H = wrap_als(x)
        H = uea_H_from_x_als(x(1:nd,:),x((nd+1):end,:));
    end

end

% ISCOLINEAR_N - are 3 points colinear (ND version)
%
% Usage:  r = iscolinear_n(P)
%
% Arguments:
%        P - Points in ND (Nx3).

%
% Returns:
%        r = 1 if points are co-linear, 0 otherwise

% Copyright (c) 2015 Han Gong 
% University of East Anglia
% 

function r = iscolinear_n(P)

    if ~(size(P,1)>=3)                              
        error('points must have the same dimension of at least 3');
    end
    
	r =  norm(cross(P(:,2)-P(:,1), P(:,3)-P(:,1))) < eps;
end

% RANSAC - Robustly fits a model to data with the RANSAC algorithm
%
% Usage:
%
% [M, inliers] = ransac(x, fittingfn, distfn, degenfn s, t, feedback, ...
%                       maxDataTrials, maxTrials)
%
% Arguments:
%     x         - Data sets to which we are seeking to fit a model M
%                 It is assumed that x is of size [d x Npts]
%                 where d is the dimensionality of the data and Npts is
%                 the number of data points.
%
%     fittingfn - Handle to a function that fits a model to s
%                 data from x.  It is assumed that the function is of the
%                 form: 
%                    M = fittingfn(x)
%                 Note it is possible that the fitting function can return
%                 multiple models (for example up to 3 fundamental matrices
%                 can be fitted to 7 matched points).  In this case it is
%                 assumed that the fitting function returns a cell array of
%                 models.
%                 If this function cannot fit a model it should return M as
%                 an empty matrix.
%
%     distfn    - Handle to a function that evaluates the
%                 distances from the model to data x.
%                 It is assumed that the function is of the form:
%                    [inliers, M] = distfn(M, x, t)
%                 This function must evaluate the distances between points
%                 and the model returning the indices of elements in x that
%                 are inliers, that is, the points that are within distance
%                 't' of the model.  Additionally, if M is a cell array of
%                 possible models 'distfn' will return the model that has the
%                 most inliers.  If there is only one model this function
%                 must still copy the model to the output.  After this call M
%                 will be a non-cell object representing only one model. 
%
%     degenfn   - Handle to a function that determines whether a
%                 set of datapoints will produce a degenerate model.
%                 This is used to discard random samples that do not
%                 result in useful models.
%                 It is assumed that degenfn is a boolean function of
%                 the form: 
%                    r = degenfn(x)
%                 It may be that you cannot devise a test for degeneracy in
%                 which case you should write a dummy function that always
%                 returns a value of 1 (true) and rely on 'fittingfn' to return
%                 an empty model should the data set be degenerate.
%
%     s         - The minimum number of samples from x required by
%                 fittingfn to fit a model.
%
%     t         - The distance threshold between a data point and the model
%                 used to decide whether the point is an inlier or not.
%
%     feedback  - An optional flag 0/1. If set to one the trial count and the
%                 estimated total number of trials required is printed out at
%                 each step.  Defaults to 0.
%
%     maxDataTrials - Maximum number of attempts to select a non-degenerate
%                     data set. This parameter is optional and defaults to 100.
%
%     maxTrials - Maximum number of iterations. This parameter is optional and
%                 defaults to 1000.
%     p         - Desired probability of choosing at least one sample
%                 free from outliers (probably should be a parameter)
%
% Returns:
%     M         - The model having the greatest number of inliers.
%     inliers   - An array of indices of the elements of x that were
%                 the inliers for the best model.
%
%
% Note that the desired probability of choosing at least one sample free from
% outliers is set at 0.99.  You will need to edit the code should you wish to
% change this (it should probably be a parameter)
%
% For an example of the use of this function see RANSACFITHOMOGRAPHY or
% RANSACFITPLANE 

% References:
%    M.A. Fishler and  R.C. Boles. "Random sample concensus: A paradigm
%    for model fitting with applications to image analysis and automated
%    cartography". Comm. Assoc. Comp, Mach., Vol 24, No 6, pp 381-395, 1981
%
%    Richard Hartley and Andrew Zisserman. "Multiple View Geometry in
%    Computer Vision". pp 101-113. Cambridge University Press, 2001

% Copyright (c) 2003-2013 Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au    
% http://www.csse.uwa.edu.au/~pk
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.
%
% May      2003 - Original version
% February 2004 - Tidied up.
% August   2005 - Specification of distfn changed to allow model fitter to
%                 return multiple models from which the best must be selected
% Sept     2006 - Random selection of data points changed to ensure duplicate
%                 points are not selected.
% February 2007 - Jordi Ferrer: Arranged warning printout.
%                               Allow maximum trials as optional parameters.
%                               Patch the problem when non-generated data
%                               set is not given in the first iteration.
% August   2008 - 'feedback' parameter restored to argument list and other
%                 breaks in code introduced in last update fixed.
% December 2008 - Octave compatibility mods
% June     2009 - Argument 'MaxTrials' corrected to 'maxTrials'!
% January  2013 - Separate code path for Octave no longer needed

function [M, inliers] = ransac(x, fittingfn, distfn, degenfn, s, t, feedback, ...
                               maxDataTrials, maxTrials, p)

    % Test number of parameters
    narginchk ( 6, 9 ) ;
    
    if nargin <10; p = 0.99; end;
    if nargin < 9; maxTrials = 1000;    end;
    if nargin < 8; maxDataTrials = 100; end;
    if nargin < 7; feedback = 0;        end;
    
    [~, npts] = size(x);
    
    bestM = [];      % Sentinel value allowing detection of solution failure.
    trialcount = 0;
    bestscore =  0;
    N = 1;            % Dummy initialisation for number of trials.
    
    while N > trialcount
        
        % Select at random s datapoints to form a trial model, M.
        % In selecting these points we have to check that they are not in
        % a degenerate configuration.
        degenerate = 1;
        count = 1;
        while degenerate
            % Generate s random indicies in the range 1..npts
            % (If you do not have the statistics toolbox with randsample(),
            % use the function RANDOMSAMPLE from my webpage)
            if ~exist('randsample', 'file')
                ind = randomsample(npts, s);
            else
                ind = randsample(npts, s);
            end

            % Test that these points are not a degenerate configuration.
            degenerate = feval(degenfn, x(:,ind));
            
            if ~degenerate
                % Fit model to this random selection of data points.
                % Note that M may represent a set of models that fit the data in
                % this case M will be a cell array of models
                M = feval(fittingfn, x(:,ind));
                
                % Depending on your problem it might be that the only way you
                % can determine whether a data set is degenerate or not is to
                % try to fit a model and see if it succeeds.  If it fails we
                % reset degenerate to true.
                if isempty(M)
                    degenerate = 1;
                end
            end

            % Safeguard against being stuck in this loop forever
            count = count + 1;
            if count > maxDataTrials
                if feedback
                    warning('Unable to select a nondegenerate data set');
                end
                break
            end
        end

        if ~degenerate
            % Once we are out here we should have some kind of model...
            % Evaluate distances between points and model returning the indices
            % of elements in x that are inliers.  Additionally, if M is a cell
            % array of possible models 'distfn' will return the model that has
            % the most inliers.  After this call M will be a non-cell object
            % representing only one model.
            [inliers, M] = feval(distfn, M, x, t);
        else
            inliers = [];
        end
        
        % Find the number of inliers to this model.
        ninliers = length(inliers);
        
        if ninliers > bestscore    % Largest set of inliers so far...
            bestscore = ninliers;  % Record data for this model
            bestinliers = inliers;
            bestM = M;
            
            % Update estimate of N, the number of trials to ensure we pick,
            % with probability p, a data set with no outliers.
            fracinliers =  ninliers/npts;
            pNoOutliers = 1 - fracinliers^s;
            pNoOutliers = max(eps, pNoOutliers);  % Avoid division by -Inf
            pNoOutliers = min(1-eps, pNoOutliers);% Avoid division by 0.
            N = log(1-p)/log(pNoOutliers);
        end
        
        trialcount = trialcount+1;
        if feedback
            fprintf('trial %d out of %d         \r',trialcount, ceil(N));
        end

        % Safeguard against being stuck in this loop forever
        if trialcount > maxTrials
            warning('ransac reached the maximum number of %d trials',...
                    maxTrials);
            break
        end
    end
    
    if feedback, fprintf('\n'); end
    
    if ~isempty(bestM)   % We got a solution
        M = bestM;
        inliers = bestinliers;
    else
        M = [];
        inliers = [];
        warning('ransac was unable to find a useful solution');
    end
end

function [H,err,pD] = uea_H_from_x_als(p1,p2,max_iter,tol,k)

% [H,rms,pa] = uea_H_from_x_als(H0,p1,p2,max_iter,tol,k)
%
% Compute H using alternating least square

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
if nargin<5, k = 'lin'; end

[Nch,Npx] = size(p1);

ind1 = sum(p1>0 & p1<Inf,1)==Nch;
ind2 = sum(p2>0 & p2<Inf,1)==Nch;
vind = ind1 & ind2;

if (size(p1) ~= size(p2))
 error ('Input point sets are different sizes!')
end

% definition for Graham
P = p1;
Q = p2;
N = P;
D = speye(Npx);

errs = Inf(max_iter+1,1); % error history

% solve the homography using ALS
n_it = 1; d_err = Inf;
while ( n_it-1<max_iter && d_err>tol )
    n_it = n_it+1; % increase number of iteration

    D = SolveD1(N,Q);

    P_d = P*D;
    if strcmp(k,'lin')
        M = Q(:,vind)/P_d(:,vind); % update M
    else
        K = mean(diag(P_d*P_d'))./1e3;
        M = ((P_d*P_d'+K*eye(Nch))\P_d*(Q'))';
    end
    N = M*P;

    NDiff = (N*D-Q).^2; % difference
    errs(n_it) = mean(mean(NDiff(:,vind))); % mean square error
    d_err = errs(n_it-1) - errs(n_it); % 1 order error
end

H = M;
err = errs(n_it);

pD = D;

%plot(errs); hold on;
%fprintf('ALS %d: %f\n',n_it,errs(n_it));

%figure; imagesc(reshape(diag(D),4,6));

    function D = SolveD1(p,q)
        [nCh,nPx] = size(p);
        d = (ones(1,nCh)*(p.*q))./(ones(1,nCh)*(p.*p));
        D = spdiags(d',0,nPx,nPx);
    end

end

% HGxyz2luv converts XYZ to LUV
% Arguments:
%          xyz   - Nx3 matrix for XYZ
%          white - white point XYZ values, 1x3 vector

% Returns:
%          luv - Nx3 matrix for LUV
%          up  - u'.
%          vp  - v'.

% See Also: https://en.wikipedia.org/wiki/CIELUV

% Han Gong 2017 <gong@fedoraproject.org>
% School of Computing Sciences
% University of East Anglia

function [luv,up,vp] = HGxyz2luv(xyz,white)

if (size(xyz,2)~=3)
   disp('xyz must be n by 3'); return;   
end
luv = zeros(size(xyz,1),size(xyz,2));

% compute u' v' for sample
up = 4*xyz(:,1)./(xyz(:,1) + 15*xyz(:,2) + 3*xyz(:,3));
vp = 9*xyz(:,2)./(xyz(:,1) + 15*xyz(:,2) + 3*xyz(:,3));
% compute u' v' for white
upw = 4*white(1)/(white(1) + 15*white(2) + 3*white(3));
vpw = 9*white(2)/(white(1) + 15*white(2) + 3*white(3));

index = (xyz(:,2)/white(2) > 0.008856);
luv(:,1) = luv(:,1) + index.*(116*(xyz(:,2)/white(2)).^(1/3) - 16);  
luv(:,1) = luv(:,1) + (1-index).*(903.3*(xyz(:,2)/white(2)));  

luv(:,2) = 13*luv(:,1).*(up - upw);
luv(:,3) = 13*luv(:,1).*(vp - vpw);

end
