function GeneNames(rows,Comprss,GeneFileNames)


current_dir=pwd;
cd /home/aloks/data/MoliData
cd(GeneFileNames)
genes = load([GeneFileNames,'_genes.txt']);
% genes{1}=[];
% genes(cellfun('isempty',genes))=[];
cd(current_dir)

if iscell(rows)==0
    if Comprss==1
        fid=fopen('GeneList.txt','w+');
    else
        fid=fopen('GeneList_UnCmprss.txt','w+');
    end

    for j=1:length(rows)
        fprintf(fid,'%d\n',genes(rows(j)));
    end
    fclose(fid);
else
    for k=1:length(rows)
        if Comprss==1
            fid=fopen(['GenePerClass_',num2str(k),'.txt'],'w+');
        else
            fid=fopen(['GeneUnCmprssPerClass_',num2str(k),'.txt'],'w+');
        end
        for j=1:length(rows{k})
            fprintf(fid,'%d\n',genes(rows{k}(j)));
        end
        fclose(fid);
    end
end

