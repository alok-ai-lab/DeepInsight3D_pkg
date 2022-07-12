function [Genes,Genes_compressed] = findGenes(IND,xp,yp,inputSize)

IND_xyp = sub2ind(inputSize,xp,yp);
parfor j=1:length(IND)
    Genes{j} = findGenes_sub(IND_xyp,IND(j));
    Genes_compressed{j} = findGenes_compressed(IND_xyp,IND(j));
end
Genes = cell2mat(Genes)';
Genes_compressed = cell2mat(Genes_compressed)';
end