function [ ind ] = GenLeaveOneOutMask(n, m)
%% Generate the indices for leave-one-out crossvalidation
ind = ones(n, 1);
ind(m) = 0;
end