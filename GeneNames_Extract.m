clear all;
close all;

Out_Stages=1; % {1,2,3,4,5,...}
DatasetNum=1;
FileRun = ['Run',num2str(DatasetNum)]; %Run1, Run2, Run3, Run4, Run5, Run6,...
genesCompressed = 'no'; % 'no', 'yes'
Directory = ['Models/',FileRun,'/Stage1'];

FILES = {'PDX_Paclitaxel','PDX_Gemcitabine','PDX_Cetuximab','PDX_Erlotinib','TCGA_Docetaxel','TCGA_Cisplatin','TCGA_Gemcitabine'};
GeneFileNames=FILES{DatasetNum};

if Out_Stages > 0
    %RUN1 or Run2
    cd(Directory)
    if strcmp(lower(genesCompressed),'yes')==1
        Stage1 = load('Genes_compressed.mat');
        Genes_compressed = Stage1.Genes_compressed;
        if isfile('Genes_PerClass_compressed.mat')==1
            Gcomp = load('Genes_PerClass_compressed.mat');
            Gcomp = Gcomp.Gcomp;
        end
    else
        Stage1 = load('Genes.mat');
        Genes = Stage1.Genes;
        if isfile('Genes_PerClass.mat')==1
            G = load('Genes_PerClass.mat');
            G = G.G;
        end
    end
    % This is the output of Stage 1, using this line will execute Stage 2
    Num=1;
    
    if Out_Stages > 1  
        cd ../Stage2
        if strcmp(lower(genesCompressed),'yes')==1
            Stage2 = load('Genes_compressed.mat');
            Genes_compressed = Stage1.Genes_compressed(Stage2.Genes_compressed);
            if isfile('Genes_PerClass_compressed.mat')==1
                Gcomp = load('Genes_PerClass_compressed.mat');
                Gcomp = Gcomp.Gcomp;
                for j=1:length(Gcomp)
                    Gcomp{j} = Stage1.Genes_compressed(Gcomp{j});
                end
            end
        else
            Stage2 = load('Genes.mat');
            Genes = Stage1.Genes(Stage2.Genes);
            if isfile('Genes_PerClass.mat')==1
                G = load('Genes_PerClass.mat');
                G = G.G;
                for j=1:length(G)
                    G{j} = Stage1.Genes(G{j});
                end
            end       
        end
         % This is the output of Stage 2, using this line will execute Stage 3
        Num=2;
    end

    if Out_Stages > 2
        cd ../Stage3
        if strcmp(lower(genesCompressed),'yes')==1
            Stage3 = load('Genes_compressed.mat');
            Genes_compressed = Stage1.Genes_compressed(Stage2.Genes_compressed(Stage3.Genes_compressed));
            if isfile('Genes_PerClass_compressed.mat')==1
                Gcomp = load('Genes_PerClass_compressed.mat');
                Gcomp = Gcomp.Gcomp;
                for j=1:length(Gcomp)
                    Gcomp{j} = Stage1.Genes_compressed(Stage2.Genes_compressed(Gcomp{j}));
                end
            end
        else
            Stage3 = load('Genes.mat');
            Genes = Stage1.Genes(Stage2.Genes(Stage3.Genes));
            if isfile('Genes_PerClass.mat')==1
                G = load('Genes_PerClass.mat');
                G = G.G;
                for j=1:length(G)
                    G{j} = Stage1.Genes(Stage2.Genes(G{j}));
                end
            end
        end
         %This is the output of Stage 3, using this line will execute Stage 4 (NotTested)
        Num=3;
    end
    
    if Out_Stages > 3
        cd ../Stage4
        if strcmp(lower(genesCompressed),'yes')==1
            Stage4 = load('Genes_compressed.mat');
            Genes_compressed = Stage1.Genes_compressed(Stage2.Genes_compressed(Stage3.Genes_compressed(Stage4.Genes_compressed)));
            if isfile('Genes_PerClass_compressed.mat')==1
                Gcomp = load('Genes_PerClass_compressed.mat');
                Gcomp = Gcomp.Gcomp;
                for j=1:length(Gcomp)
                    Gcomp{j} = Stage1.Genes_compressed(Stage2.Genes_compressed(Stage3.Genes_compressed(Gcomp{j})));
                end
            end
        else
            Stage4 = load('Genes.mat');
            Genes = Stage1.Genes(Stage2.Genes(Stage3.Genes(Stage4.Genes)));
            if isfile('Genes_PerClass.mat')==1
                G = load('Genes_PerClass.mat');
                G = G.G;
                for j=1:length(G)
                    G{j} = Stage1.Genes(Stage2.Genes(Stage3.Genes(G{j})));
                end
            end
        end
         %This is the output of Stage 4, using this line will execute Stage 5 (NotTested)
        Num=4;
    end
    
    if Out_Stages > 4
        cd ../Stage5
        if strcmp(lower(genesCompressed),'yes')==1
            Stage5 = load('Genes_compressed.mat');
            Genes_compressed = Stage1.Genes_compressed(Stage2.Genes_compressed(Stage3.Genes_compressed(Stage4.Genes_compressed(Stage5.Genes_compressed))));
            if isfile('Genes_PerClass_compressed.mat')==1
                Gcomp = load('Genes_PerClass_compressed.mat');
                Gcomp = Gcomp.Gcomp;
                for j=1:length(Gcomp)
                    Gcomp{j} = Stage1.Genes_compressed(Stage2.Genes_compressed(Stage3.Genes_compressed(Stage4.Genes_compressed(Gcomp{j}))));
                end
            end
        else
            Stage5 = load('Genes.mat');
            Genes = Stage1.Genes(Stage2.Genes(Stage3.Genes(Stage4.Genes(Stage5.Genes))));
            if isfile('Genes_PerClass.mat')==1
                G = load('Genes_PerClass.mat');
                G = G.G;
                for j=1:length(G)
                    G{j} = Stage1.Genes(Stage2.Genes(Stage3.Genes(Stage4.Genes(G{j}))));
                end
            end
        end
         %This is the output of Stage 4, using this line will execute Stage 5 
        Num=5;
    end
    
    if Out_Stages > 5
        cd ../Stage6
        if strcmp(lower(genesCompressed),'yes')==1
            Stage6 = load('Genes_compressed.mat');
            Genes_compressed = Stage1.Genes_compressed(Stage2.Genes_compressed(Stage3.Genes_compressed(Stage4.Genes_compressed(Stage5.Genes_compressed(Stage6.Genes_compressed)))));
            if isfile('Genes_PerClass_compressed.mat')==1
                Gcomp = load('Genes_PerClass_compressed.mat');
                Gcomp = Gcomp.Gcomp;
                for j=1:length(Gcomp)
                    Gcomp{j} = Stage1.Genes_compressed(Stage2.Genes_compressed(Stage3.Genes_compressed(Stage4.Genes_compressed(Stage5.Genes_compressed(Gcomp{j})))));
                end
            end
        else
            Stage6 = load('Genes.mat');
            Genes = Stage1.Genes(Stage2.Genes(Stage3.Genes(Stage4.Genes(Stage5.Genes(Stage6.Genes)))));
            if isfile('Genes_PerClass.mat')==1
                G = load('Genes_PerClass.mat');
                G = G.G;
                for j=1:length(G)
                    G{j} = Stage1.Genes(Stage2.Genes(Stage3.Genes(Stage4.Genes(Stage5.Genes(G{j})))));
                end
            end
        end
         %This is the output of Stage 5, using this line will execute Stage 6 (NotTested)
        Num=6;
    end
    cd ../../../
end

%if strcmp(lower(genesCompressed),'yes')==1
%    unix(['mv GeneList.txt Unique_Genes.txt']);
%else
%    unix(['mv GeneList_UnCmprss.txt Unique_Genes.txt']);
%end

File = [Directory(1:end-1),num2str(Num)];

if strcmp(lower(genesCompressed),'yes')==1
    GeneNames(Genes_compressed,1,GeneFileNames);
    unix(['cp GeneList.txt ',File]);
    %unix(['cp Unique_Genes.txt ',File]);
    
    if exist('Gcomp')==1
        GeneNames(Gcomp,1,GeneFileNames);
        unix(['mv GenePerClass*.txt ',File]);
    end
else
    GeneNames(Genes,0,GeneFileNames);
    unix(['cp GeneList_UnCmprss.txt ',File]);
    %unix(['cp Unique_Genes.txt ',File]);[
    
    if exist('G')==1
        GeneNames(G,0,GeneFileNames);
        unix(['mv GeneUnCmprssPerClass_*.txt ',File]);
    end
end


unix(['mkdir ',File,'/',[FileRun,'Stage',num2str(Out_Stages)]]);
unix(['mv ',File,'/*.txt ',File,'/',[FileRun,'Stage',num2str(Out_Stages)],'/']);
unix(['tar -cvf ',File,'/',[FileRun,'Stage',num2str(Out_Stages)],'.tar ',File,'/',[FileRun,'Stage',num2str(Out_Stages)],'/']);
unix(['gzip ',File,'/',[FileRun,'Stage',num2str(Out_Stages)],'.tar']);
if exist('GeneFileNames')==1
    unix(['cp ',File,'/',[FileRun,'Stage',num2str(Out_Stages),'.tar.gz'],' ',File,'/',GeneFileNames,'.tar.gz']);
end
