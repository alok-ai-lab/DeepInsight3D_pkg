function Genes = findGenes_sub(IND_xyp,index)

q = (IND_xyp==index);
if sum(q)~=0
    [r,gn]=sort(q,'descend');
    Genes = gn(1:sum(r));
else
    Genes = [];
end
end