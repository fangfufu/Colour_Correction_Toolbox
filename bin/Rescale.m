function [ B ] = Rescale( B,A )
%RESCALE Rescale B so it has the same scaling as A.

sf = GetScale(B,A);
B = B./sf;

end

