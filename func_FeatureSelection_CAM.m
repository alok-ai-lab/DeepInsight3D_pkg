function [Genes,Genes_compressed,G]= func_FeatureSelection_CAM(Parm)

% Feature selection of DeepInsight-FS

model = load('model.mat')
%netName = "squeezenet";
netName = Parm.NetName;
cd DeepResults
net = load(model.fileName);
cd ../

% netName = net.trainedNet.Layers(2).Name;
% Oblique = '|';
% [rmp,cmp] = max(netName==Oblique);
% if rmp==1
%     netName = netName(1:cmp-1);
% end

FileRun = Parm.FileRun;
Stages = Parm.Stage;
Threshold = Parm.Threshold;
Ask = Parm.SaveModels;

if strcmp(Parm.PATH{1}(end),'/')==0
    Parm.PATH{1} = [Parm.PATH{1},'/'];
end
if strcmp(Parm.PATH{2}(end),'/')==0
    Parm.PATH{2} = [Parm.PATH{2},'/'];
end

inputSize = net.trainedNet.Layers(1).InputSize(1:2);
classes = net.trainedNet.Layers(end).Classes;
layerName = activationLayerName(netName);

if model.Norm==1
    Data = load('Out1.mat');
else
    Data = load('Out2.mat');
end
% if Parm.Augment==1
%     Data.YTrain = Data.orgYTrain;
% end

Sample=1;
Dmat = 'R'; % R for Red; G for Green; B for Blue
FIG=1;
%Threshold = 0.6;

[IND,Genes, Genes_compressed] = findActivatedPoints(Data,classes,inputSize,net,netName,layerName,Dmat,Threshold,FIG,Sample);

% per class genes ###
for j=1:max(double(classes))
    G{j}=[];
    Gcomp{j}=[];
    Gind{j}=[];
end
G{Data.YTrain(Sample)} = Genes;
Gcomp{Data.YTrain(Sample)} = Genes_compressed;
Gind{Data.YTrain(Sample)} = IND;
% ###################

FIG=0;
tic
for Sample=2:size(Data.YTrain,1)
    [IND2,Genes2,Genes2_compressed] = findActivatedPoints(Data,classes,inputSize,net,netName,layerName,Dmat,Threshold,FIG,Sample);
    IND = unique([IND;IND2]);
    Genes = unique([Genes;Genes2]); % all genes including non-overlapping ones; 
                                     %e.g. if 4 genes have the same
                                     % locations then list all 4 genes
    Genes_compressed = unique([Genes_compressed;Genes2_compressed]); % compressed genes presents one gene per pixel;
                                    % e.g. if 4 genes have the same
                                    % locations then only 1 gene will be
                                    % selected
    
    % per class genes ###
    G{Data.YTrain(Sample)} = unique([G{Data.YTrain(Sample)};Genes2]);
    Gcomp{Data.YTrain(Sample)} = unique([Gcomp{Data.YTrain(Sample)};Genes2_compressed]);
    Gind{Data.YTrain(Sample)} = unique([Gind{Data.YTrain(Sample)};IND2]);
    % ###################
    
end
TIME=toc
clear Genes2 Genes2_compressed IND2

Sample=1;
Tr=Data.XTrain(:,:,1,Sample);
B=uint8(ones(size(Tr))*255);
Bpc = B; % B per class
B(IND)=Tr(IND);
figure; 
imshow(B);
title('Genes selected for all Training data')

% figure per class ###################
r = sqrt(max(double(classes)));
xr = floor(r);
xy = ceil(max(double(classes))/xr);
Bpc1 = Bpc;
figure
for k=1:max(double(classes))
    subplot(xr,xy,k);
    Bpc1(Gind{k}) = Tr(Gind{k});
    imshow(Bpc1);
    title(['Class ',num2str(k)]);
    Bpc1 = Bpc;
end

figure
for k=1:max(double(classes))
    subplot(xr,xy,k);
    Bpc1(Gind{k}) = Tr(Gind{k});
    imagesc(Bpc1); colormap pink
    title(['Class ',num2str(k)]);
    Bpc1 = Bpc;
end

% figure;
% Bpc2=Bpc;
% for k=1:max(double(classes))
%     Bpc1(Gind{k}) = Tr(Gind{k});
%     [row,col]=ind2sub(size(Bpc1),find(Bpc1<255));
%     Bpc1_ind=sub2ind(size(Bpc1),row,col);
%     Bpc1(Bpc1_ind)=uint8((k/(max(double(classes))+2))*255);
%     Bpc2(Bpc1_ind) = uint8((k/(max(double(classes))+2))*255);;
%     subplot(xr,xy,k); imshow(Bpc1);
%     Bpc1 = Bpc;
% end
% figure;imshow(Bpc2);
% ####################################

if isfield(Parm,'g')==1
if Parm.g==1
    Genes=unique([Genes;Parm.Genes]);
    Genes_compressed=unique([Genes_compressed;Parm.Genes_compressed]);
    for glen=1:length(G)
        G{glen} = unique([G{glen};Parm.G{glen}]);
    end
end
end
save('Genes.mat','Genes');
save('Genes_compressed.mat','Genes_compressed');
save('Genes_PerClass.mat','G');
save('Genes_PerClass_compressed.mat','Gcomp');


%prompt = 'Do you want to save the results? Type Y for Yes and N for No: ';
%Ask = 'y';%input(prompt,'s');

if strcmp(lower(Ask),'y')==1
    curr_dir=pwd;
    %prompt = 'What is the Run Number? Type Run1, Run2, etc.: ';
    %FileRun = input(prompt,'s');
    %prompt = 'What is the Stage number? Type 1,2, 3 etc.: ';
    %Stages = input(prompt);
    %Stages=1; % {1,2 or 3}
    %FileRun = 'Run4'; %Run1, Run2, Run3 or Run4
    %Directory = ['~/Dropbox/Public/FIGS/DeepInsight_CAM_FS/',FileRun,'/Stage',num2str(Stages),'/'];
    Directory = [Parm.PATH{1},FileRun,'/Stage',num2str(Stages),'/'];
    if isfolder(Directory(1:end-8))==0
        unix(['mkdir ',Directory(1:end-8)]);
    end
    if isfolder(Directory)==0
        unix(['mkdir ',Directory(1:end-1)]);
    end
    cd(Directory)
    saveas(1,'Sample_vs_Activation.jpg','jpg');
    saveas(2,'Sample_vs_Activation_colored.jpg','jpg');
    saveas(3,'Activation_vs_Genes.jpg','jpg');
    saveas(4,'2Dmat_Red.jpg','jpg');
    saveas(5,'Genes_AllTrainingData.jpg','jpg');
    saveas(6,'Genes_PerClass.jpg','jpg');
    saveas(7,'Genes_PerClass_colored.jpg','jpg');
    savefig(1,'Sample_vs_Activation.fig');
    savefig(2,'Sample_vs_Activation_colored.fig');
    savefig(3,'Activation_vs_Genes.fig');
    savefig(4,'2Dmat_Red.fig');
    savefig(5,'Genes_AllTrainingData.fig');
    savefig(6,'Genes_PerClass.fig');
    savefig(7,'Genes_PerClass_colored.fig');
    cd(curr_dir);
    disp('Saved...');
end

%prompt = 'Do you want to save data, model and Gene Files? Type Y for Yes and N for No: ';
%Ask = input(prompt,'s');

if strcmp(lower(Ask),'y')==1
    %prompt = 'What is the Run Number? Type Run1, Run2, etc.: ';
    %FileRun = input(prompt,'s');
    %prompt = 'What is the Stage number? Type 1,2, 3 etc.: ';
    %Stages = input(prompt);
    %Stages=1; % {1,2 or 3}
    %FileRun = 'Run4'; %Run1, Run2, Run3 or Run4
    %Directory = ['~/MatWorks/Unsup/DeepInsight_CAM_FS/Models/',FileRun,'/Stage',num2str(Stages),'/'];
    Directory = [Parm.PATH{2},FileRun,'/Stage',num2str(Stages),'/'];
    if isfolder(Directory(1:end-8))==0
        unix(['mkdir ',Directory(1:end-8)]);
    end
    if isfolder(Directory)==0
        unix(['mkdir ',Directory(1:end-1)]);
    end
    if model.Norm==1
        unix(['cp Out1.mat ',Directory]);
    else
        unix(['cp Out2.mat ',Directory]);
    end
    unix(['cp Genes.mat ',Directory]);
    unix(['cp Genes_compressed.mat ',Directory]);
    unix(['cp model.mat ',Directory]);
    unix(['cp DeepResults/',num2str(model.fileName),' ',Directory]);
    unix(['cp Genes_PerClass.mat ',Directory]);
    unix(['cp Genes_PerClass_compressed.mat ',Directory]);
    disp('Files Saved...');
end

