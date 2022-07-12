function Genes_compressed = findGenes_compressed(IND_xyp,index)

q = (IND_xyp==index);
if sum(q)~=0
    [r,gn]=max(q);
    Genes_compressed = gn;
else
    Genes_compressed = [];
end
end