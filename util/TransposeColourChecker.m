function [ out_mat ] = TransposeColourChecker( in_mat, ncol, nrow)
%TRANSPOSE_COLOUR_CHART_VECTOR Transpose a colour chart vector
%   In my own implementation, I read colour chart row then column, and
%   store it in a nx3 matrix

% Note the col / row convention here.
tmp = zeros(ncol, nrow, 3);

patch_count = size(in_mat, 1);

% Current row and column
row = 1;
col = 1;
for i = 1:patch_count
    % Actual transposition happens here, note the row/col convention here
    tmp(row, col, :) = in_mat(i, :);
    if ~mod(col, nrow)
        row = row + 1;
        col = 1;
    else
        col = col + 1;
    end
end

out_mat = zeros(size(in_mat));
k = 1;
for i = 1:nrow
    for j = 1:ncol
        out_mat(k, :) = tmp(j,i,:);
        k = k + 1;
    end
end

end
