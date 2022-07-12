function [Genes,Genes_compressed,G]= func_FeatureSelection_avgCAM(Parm)

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

R=zeros(inputSize(1),inputSize(2));
for Sample=1:size(Data.XTrain,4)
    Rsample = CAMcompute(Data,inputSize,net,netName,layerName,Dmat,Sample);
    R=R+Rsample;
end
R=R/size(Data.XTrain,4);

if FIG==1
figure
subplot(1,2,1)
imshow(Data.XTrain(:,:,:,Sample));
title(['Sample ',num2str(Sample)]);

subplot(1,2,2)
CAMshow(Data.XTrain(:,:,:,Sample),R);
title('Activation area');

pause(1);

figure
subplot(1,2,1)
imagesc(Data.XTrain(:,:,1,Sample))
colormap hot
colorbar
%imshow(im)
title(['Sample ',num2str(Sample),' in color']);

subplot(1,2,2)
CAMshow(Data.XTrain(:,:,:,Sample),R);
title('Activation area');

pause(1);
end


[row,col]=ind2sub(size(R),find(R>Threshold));
%end

if FIG==1
   figure; imshow(R);
   title(['2D matrix used is ',Dmat]);
end

IND=sub2ind(size(R),row,col);
if FIG==1
   B=ones(size(R));
   B(IND)=R(IND);
   figure; 
   subplot(1,2,1); imshow(B);
   title('Area by activation')
   
   C=uint8(ones(size(R))*255);
   im2=Data.XTrain(:,:,1,1);
   C(IND)=im2(IND);
   subplot(1,2,2); imshow(C)
   title('Genes selected')
end

inputSize = size(Data.XTrain,1:2);
[Genes,Genes_compressed] = findGenes(IND,Data.xp,Data.yp,inputSize);
   
for j=1:max(double(classes))
    G{j}=Genes;
    Gcomp{j}=Genes_compressed;
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
    %saveas(5,'Genes_AllTrainingData.jpg','jpg');
    %saveas(6,'Genes_PerClass.jpg','jpg');
    %saveas(7,'Genes_PerClass_colored.jpg','jpg');
    savefig(1,'Sample_vs_Activation.fig');
    savefig(2,'Sample_vs_Activation_colored.fig');
    savefig(3,'Activation_vs_Genes.fig');
    savefig(4,'2Dmat_Red.fig');
    %savefig(5,'Genes_AllTrainingData.fig');
    %savefig(6,'Genes_PerClass.fig');
    %savefig(7,'Genes_PerClass_colored.fig');
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
