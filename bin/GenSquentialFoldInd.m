function [ out ] = GenSquentialFoldInd( n, k )
%GENSQUENTIALFOLDIND Generate sequential cross validation fold indices

out = zeros(n,1);
j = 1;
for i = 1:n
    out(i) = j;
    j = j + 1;
    if (j > k)
        j = 1;
    end
end

end

