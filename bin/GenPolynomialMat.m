function [ N ] = GenPolynomialMat( M, deg )
%GENPOLYNOMIALMAT Generate a polynomial matrix

r = M(:,1);
g = M(:,2);
b = M(:,3);

switch deg
    case 1
        N = [r, g, b];
    case 2
        N = [r, g, b, [r.*r, r.*g, r.*b, g.*g, g.*b, b.*b]];
    case 3
        N = [r, g, b, [r.*r, r.*g, r.*b, g.*g, g.*b, b.*b], ...
            [r.*r.*r, r.*r.*g, r.*r.*b, r.*g.*g, r.*g.*b, ...
            r.*b.*b, g.*g.*g, g.*g.*b, g.*b.*b, b.*b.*b]];
    case 4
        N = [r, g, b, [r.*r, r.*g, r.*b, g.*g, g.*b, b.*b], ...
            [r.*r.*r, r.*r.*g, r.*r.*b, r.*g.*g, r.*g.*b, r.*b.*b, ...
            g.*g.*g, g.*g.*b, g.*b.*b, b.*b.*b], [b.*b.*b.*b, ...
            g.*b.*b.*b, g.*g.*b.*b, g.*g.*g.*b, g.*g.*g.*g, r.*b.*b.*b, ...
            r.*g.*b.*b, r.*g.*g.*b, r.*g.*g.*g, r.*r.*b.*b, r.*r.*g.*b, ...
            r.*r.*g.*g, r.*r.*r.*b, r.*r.*r.*g, r.*r.*r.*r]];
    otherwise
        error('GEN_POLYNOMIAL_VECTOR:: Invalid degree count!');
end

end
