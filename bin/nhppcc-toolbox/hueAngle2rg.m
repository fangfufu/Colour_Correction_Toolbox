function [rg] =hueAngle2rg(hue)
rg = [cos(hue) sin(hue)]*.1+[1/3 1/3];
end

