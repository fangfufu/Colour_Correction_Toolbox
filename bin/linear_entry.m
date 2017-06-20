function [out] = linear_entry(X, Y, C)
%LINEAR_ENTRY Linear entries in MI Colour Correction matrix

% When the maths was derived, we assumed that only the spectral sensitity 
% function is affected by multiplication. 

if ~isvector(C) || ~isvector(X) || ~isvector(Y)
    error('X, Y and C should all be vectors, check your input');
end

if numel(C) ~= numel(X) || numel(X) ~= numel(Y)
    error('X, Y and C should have the same element count.');
end

n = numel(X);
part_a = 0;
part_b = 0';
part_prod = 1;

% The 1/4 part (part_a)
for j = 1:(n-1)
    for k = (j+1):n
        part_a = part_a + C(j)*C(k)*(X(j)*Y(k)+X(k)*Y(j));
    end
end

% The 1/3 part (part_b)
for i = 1:n
    part_b = part_b + C(i)^2*X(i)*Y(i);
end

% The product part
part_prod = prod(C);

out = part_prod * part_a / 4 + part_prod * part_b /3;

end