function [ macbeth ] = extract_macbeth_from_sg140( sg140 )
%EXTRACT_MACBETH_FROM_SG140 Extract the Macbeth sub-colour chart from SG140
%colour chart.

% Copy the 1D vector to the 2D matrix
sg140_2d = zeros(12,8,3);

row = 1;
col = 1;
for i = 1:96
    sg140_2d(col, row, :) = sg140(i, :);
    if mod(col, 12)
        col = col + 1;
    else
        row = row + 1;
        col = 1;
    end
end

% Extract the Macbeh sub-colour chart
macbeth_2d = zeros(6,4,3);
for i = 1:6
    for j = 1:4
        x = i + 3;
        y = j + 0;
        macbeth_2d(i,j,:) = sg140_2d(x,y,:);
    end
end

% Convert the 2D colour checker back to 1D
macbeth = zeros(24,3);
k = 1;
for i = 1:4
    for j = 1:6
        macbeth(k, :) = macbeth_2d(j,i,:);
        k = k + 1;
    end
end

end

