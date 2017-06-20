function [ M, XtX, XtY ] = MIPP( Din, Xin, deg )
%% MIPP Maximum Ignorance Polynomial Colour Correction with Positivity
% This function implements an analytical closed form solution.
%   Din is the device reponse curve
%   Xin is the standard observer colour matching function
%   Din and Xin are both wavelength-times-channel matrices.
%
%   The output format is a 3xn matrice, where n is the number of 
%   polynomial terms.

%% Sanity check
if size(Din) ~= size(Xin)
    error('The size of Din and the size of Xin are different.');
end

%% Variable initialisation
X = Din';
Y = Xin';
clear Din;
clear Xin;

%% Calculating XtX and XtY for degree 1

% Linear entires
for i = 1:3
    for j = 1:3
        XtX(i,j) = II(X(i,:), X(j,:));
        XtY(i,j) = II(X(i,:), Y(j,:));
    end
end

if deg == 1
    % Do nothing, because it had already been done! 
elseif deg ==2
    %% Calculating XtX and XtY for degree 2
    %Top right entries
    disp('     ');
    for i = 1:3
        l = 0;
        for j = 1:3
            fprintf('\b\b\b\b\b\b%05.2f%%', ((i-1)*3+j)/9*50);
            for k = j:3
                l = l + 1;
                top_right(i,l) = III(X(i,:),X(j,:),X(k,:));
                XtY(l+3, i) = III(Y(i,:),X(j,:),X(k,:));
            end
        end
    end
%     disp(' ');
    XtX(1:3, 4:9) = top_right;
    
    %Bottom left entries
    bottom_left = top_right';
    XtX(4:9, 1:3) = bottom_left;
    
    %Bulding index look up table
    k = 0;
    for i = 1:3
        for j = i:3
            k = k+1;
            ind(k,1) = i;
            ind(k,2) = j;
        end
    end
    
%     disp('     ');
    for i = 1:6
        for j =1:6
            fprintf('\b\b\b\b\b\b%05.2f%%', ((i-1)*6+j)/36*50+50);
            bottom_right(i,j) = IV(X(ind(i,1),:), X(ind(i,2),:), ...
                X(ind(j,1),:), X(ind(j,2),:));
        end
    end
    disp(' ');
    
    XtX(4:9, 4:9) = bottom_right;
else
    error('Invalid deg, only 1 or 2 are supported');
end

%% Final matrix multiplication
M = (inv(XtX) * XtY)';

end

function [out] = II(X,Y)
n = numel(X);
C = ones(1, n);
out = linear_entry(X, Y, C.*1) - linear_entry(X, Y, C.*0);
end

function [out] = III(X,Y,Z)
n = numel(X);
C = ones(1, n);
out = polynomial_3_entry(X, Y, Z, C.*1) - polynomial_3_entry(X, Y, Z, C.*0);
end

function [out] = IV(W,X,Y,Z)
n = numel(X);
C = ones(1, n);
out = polynomial_4_entry(W, X, Y, Z, C.*1) - polynomial_4_entry(W, X, Y, Z, C.*0);
end


function [out] = polynomial_3_entry(X, Y, Z, C)
%POLYNOMIAL_3_ENTRY 3-variable entries for polynomial colour correction

if ~isvector(C) || ~isvector(X) || ~isvector(Y) || ~isvector(Z)
    error('X, Y and C should all be vectors, check your input');
end

if numel(C) ~= numel(X) || numel(X) ~= numel(Y) || numel(Y) ~= numel(Z)
    error('X, Y and C should have the same element count.');
end

%% Variable initialisation
n = numel(C);

%% calculate c_m
part_a = 1;
for l = 1:n
    part_a = C(l) * part_a;
end

%% calculate the summation
part_b = 0;
parfor i = 1:n
    for j = 1:n
        for k = 1:n
            part_ba = C(i)*X(i) * C(j) * Y(j) * C(k)*Z(k);
            
            % This is the actual equation, it works.
            part_bb = 1;
            for m = 1:n
                % This is the kronecker delta part
                part_bb = part_bb * ((m == i) + (m == j) + (m == k) + 1);
            end

            part_b = part_b + part_ba/part_bb;
        end
    end
end

out = part_a * part_b;

end

function [out] = polynomial_4_entry(W, X, Y, Z, C)
%POLYNOMIAL_4_ENTRY 4-variable entries for polynomial colour correction

if ~isvector(C) || ~isvector(W) || ~isvector(X) || ~isvector(Y) || ~isvector(Z)
    error('X, Y and C should all be vectors, check your input');
end

if numel(C) ~= numel(X) || numel(W) ~= numel(X) || numel(X) ~= numel(Y) || numel(Y) ~= numel(Z)
    error('X, Y and C should have the same element count.');
end

%% Variable initialisation
n = numel(C);

%% calculate c_m
part_a = prod(C);

%% calculate the summation
part_b = 0;
parfor i = 1:n
    for j = 1:n
        for k = 1:n
            for l = 1:n
                part_ba = C(i)*W(i) * C(j)*X(j) * C(k)*Y(k) * C(l)*Z(l);

                % This is the actual equation, it works. 
                part_bb = 1;
                for p = 1:n
                    % This is the kronecker delta part
                    part_bb = part_bb * ((p == i) + (p == j) + (p == k) + (p == l) + 1);
                end

                part_b = part_b + part_ba/part_bb;
            
            end
        end
    end
end

out = part_a * part_b;

end


