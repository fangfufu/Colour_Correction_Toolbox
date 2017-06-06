function [HA,rg] = RGB2HueAngleWithoutNorm(RGB)
rg = RGB(:,1:2)./repmat(sum(RGB,2),1,2);
for i=1:size(rg,1)
    if rg(i,1)==1/3 && rg(i,2)==1/3
        HA(i) = 0;
    elseif rg(i,1)==1/3 && rg(i,2)>1/3
        HA(i)=pi/2;
    elseif rg(i,1)==1/3 && rg(i,2)<1/3
        HA(i)=3*pi/2;
    else 
        if rg(i,1)>=1/3 && rg(i,2)>=1/3
            m=0;
        elseif rg(i,1)<1/3
            m=1;
        else %if rg(i,1)>1/3 && rg(i,2)<1/3
            m=2;
        end
        HA(i) = atan((rg(i,2)-1/3)/(rg(i,1)-1/3))+m*pi;
    end
end
end

