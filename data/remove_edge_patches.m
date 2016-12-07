function [ new_xyz ] = remove_edge_patches( old_xyz )
%REMOVE_EDGE_PATCHES Remove the patches on the edge for a colour chart
%measurement matrix

col_max = 14;
row_max = 10;
old_ind = 0;
new_ind = 0;

new_xyz = zeros((col_max - 2) * (row_max - 2), size(old_xyz,2));

for row = 1:row_max
    for col = 1:col_max
        old_ind = old_ind + 1;
        if (row == 1) || (row == row_max) || (col == 1) || (col == col_max)
            continue;
        end
        new_ind = new_ind + 1;
        new_xyz(new_ind,:) = old_xyz(old_ind, :);
    end
end

end

