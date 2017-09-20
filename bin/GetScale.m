function [ S ] = GetScale( B, A )
%ROBUSTGETSCALE Obtain the scaling factor that maps B to A
A = reshape(A, 1, []);
B = reshape(B, 1, []);
S = inv(A * A') * A * B';
end