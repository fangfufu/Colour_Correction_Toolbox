function [HA,RGBw,rg] = RGB2HueAngle(RGB,w_idx)
%RGB  - N x 3 input RGBs
%w_idx- index to the white patch sample
%HA   - N x 1 hue angles 
%RGBw - N x 3 RGBs (white balanced)
%rg -   N x 2 rg chromaticities


RGBw = RGB./repmat(RGB(w_idx,:),size(RGB,1),1).*repmat(RGB(w_idx,2),size(RGB,1),3);
rg = RGBw(:,1:2)./repmat(sum(RGBw,2),1,2);
HA = zeros(size(RGB,1),1);
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

