xlabels = 'RGB';
ylabels = 'XYZ';
for i = 1:3
    f = figure; 
    a = nikon_rgb(:,i); 
    b = XYZ(i,:)';
    
    a = a./max(a);
    b = b./max(b);
    
    plot(a, b,'.');
    axis([0,1,0,1]);
    axis equal;
    
    xlabel(['Nikon camera ',xlabels(i) ,' channel']);
    ylabel([ylabels(i), ' stimulus']);
    saveas(f, [num2str(i), '.png']);
end