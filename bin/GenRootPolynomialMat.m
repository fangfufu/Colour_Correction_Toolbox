function [ N ] = GenRootPolynomialMat( M, deg )
%GENROOTPOLYNOMIALMAT Generate a root-polynomial matrix

r = M(:,1);
g = M(:,2);
b = M(:,3);

switch deg
    case 1
        N = [r, g, b];
    case 2
        N = [r, g, b, [r.*g, r.*b, g.*b].^(1/2)];
    case 3
        N = [r, g, b, [r.*g, r.*b, g.*b].^(1/2), ...
            [r.*r.*g, r.*r.*b, r.*g.*g, r.*g.*b, ...
            r.*b.*b, g.*g.*b, g.*b.*b].^(1/3)];
    case 4
        N = [r, g, b, [r.*g, r.*b, g.*b].^(1/2), ...
            [r.*r.*g, r.*r.*b, r.*g.*g, r.*g.*b, ...
            r.*b.*b, g.*g.*b, g.*b.*b].^(1/3), ...
            [g.*b.*b.*b, g.*g.*g.*b, r.*b.*b.*b,...
            r.*g.*b.*b, r.*g.*g.*b, r.*g.*g.*g, ...
            r.*r.*g.*b, r.*r.*r.*b, r.*r.*r.*g].^(1/4)];
    otherwise
        error('GEN_ROOT_POLYNOMIAL_VECTOR:: Invalid degree count!');
end

end
