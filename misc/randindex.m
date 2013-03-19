function [rind] = randindex( y, esty )

rind = 0;
N = size(y,1);
for i = 1:N
    for j = i+1:N
        if y(i)==y(j)&&esty(i)==esty(j) || y(i)~=y(j)&&esty(i)~=esty(j)
            rind = rind+1;
        end
    end
end
rind = rind/nchoosek(N,2);

end