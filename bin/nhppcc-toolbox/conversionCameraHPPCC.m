function [XYZ] = conversionCameraHPPCC(T,ind,RGB)

%Q - number of hue partitions in HPPCC
%T - Q*3 x 3 matrix containing Q 3x3 colour correction matrices
%ind - 1 x Q cell array containing respective RGB indices
%RGB - N x 3 input RGBs (white balanced)
%XYZ - N x 3 output XYZs

dim = size(RGB,2);
partitions = size(T,1)/dim;

if partitions ==1
    XYZ = RGB*T;
    return
end

for i=0:partitions-1
    M{i+1} = T(i*dim+1:i*dim+dim,:);
end
XYZ = zeros(size(RGB,1),3);
for j=1:partitions
    XYZ(ind{j},:) = RGB(ind{j},:)*M{j};
end


