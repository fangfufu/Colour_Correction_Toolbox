function [ ind ] = GenLeaveOneOutMask(n, m)
%% Generate the indices for leave-one-out crossvalidation
ind = true(n, 1);
ind(m) = false;
end