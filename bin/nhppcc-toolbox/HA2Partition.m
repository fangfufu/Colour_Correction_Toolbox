function ind = HA2Partition(HA,boundaryHA)
ind = cell(numel(boundaryHA),1);
count = zeros(numel(ind),1);
for i=1:numel(ind)
    ind{i} = zeros(1,numel(HA));
    count(i)=0;
end
for i=1:numel(HA)
    for j=1:numel(boundaryHA)
        if HA(i)<boundaryHA(j)
            %ind{j}=[ind{j},i];
            ind{j}(count(j)+1)=i;
            count(j) = count(j)+1;
            break
        end
        if j==1 && HA(i)>=boundaryHA(end)
            %ind{j}=[ind{j},i];
            ind{j}(count(j)+1)=i;
            count(j) = count(j)+1;
            break
        end
    end
end
for j=1:numel(ind)
    if numel(ind{j})>count(j)
        ind{j}(count(j)+1:end)=[];
    end
end
