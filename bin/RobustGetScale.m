function [ S ] = RobustGetScale( B, A )
%ROBUSTGETSCALE Obtain the scaling factor between A and B

method = 1;
switch method
    case 1
        %% Graham's method - Method 1
        A = reshape(A, 1, []);
        B = reshape(B, 1, []);
        S = inv(A * A') * A * B';
    case 2
        %% Scale by the maximum value
        i = find(A == max(A(:)));
        S = max(B(i)) / max(A(i));
    case 3
        %% Scale by the mean value
        S = mean(B(:)) / mean(A(:));
end

end

