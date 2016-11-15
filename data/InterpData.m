function [ data_out ] = InterpData(data, in_wl, out_wl)
%PARSE_DATASET Obtain the data points at wavelength specified by the
%camera's sensitivity curve
%   This is basically a wrapper for interp1
%
%   - data is a n-times-m array, where n is the number of wavelength in 
%   which measurements were taken
%   - in_wl is the sample wavelength
%   - out_wl is the query wavelength

if ~isvector(in_wl) || ~isvector(out_wl)
    error('data_wl and cam_wl must both be vectors');
end

n_dout = size(out_wl, 2);
m = size(data, 2);
data_out = zeros(n_dout, m);

for i = 1:m
    data_out(:,i) = interp1(in_wl, data(:,i), out_wl, 'pchip');
end


end

