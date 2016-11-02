function [ data_out ] = parse_dataset(data, data_wl, cam_wl)
%PARSE_DATASET Obtain the data points at wavelength specified by the
%camera's sensitivity curve
%   This is basically a wrapper for interp1
%
%   - data is a n-times-m array, where n is the number of wavelength in 
%   which measurements were taken
%   - data_wl is a vector containing the wavelength for the data
%   - cam_wl is a vector containing the wavelength for the camera
%   sensitivity curve

if ~isvector(data_wl) || ~isvector(cam_wl)
    error('data_wl and cam_wl must both be vectors');
end

n_dout = size(cam_wl, 1);
m = size(data, 2);
data_out = zeros(n_dout, m);

for i = 1:m
    data_out(:,i) = interp1(data_wl, data(:,i), cam_wl, 'pchip');
end


end

