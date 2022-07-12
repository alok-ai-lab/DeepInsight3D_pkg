function [Genes,Genes_compressed,G]= func_FS_class_basedCAM(Parm)
%[Genes,Genes_compressed,G]= func_FS_class_basedCAM(Parm)
%
% Parm is from Parameters.m file; execute Parm = Parameters(DSETnum);
%   where DSETnum is the number of dataset. For example DSETnum=1 for
%   dataset1.mat. Therefore, name of dataset file is <dataset"DSETnum".mat>
%
% Feature selection using class-based CAM
%
% Genes: selected genes
% G: genes per class or categories
% Genes_compressed: only 1 gene is used if more than one genes are present
%      in a given pixel location. That is if overlapping genes are present
%      then only 1 gene is obtained and others are discarded.
display('Feature selection begins');

% open file DeepInsight3D_Results.txt for saving the outputs
fid2 = fopen('DeepInsight3D_Results.txt','a+');

close all hidden; 
model = load('model.mat')
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

nclass = max(double(classes));
Rclass=zeros(inputSize(1),inputSize(2),1,nclass);
for cls=1:nclass
    R=zeros(inputSize(1),inputSize(2));
    SMPLE = (double(Data.YTrain)==cls);
    Range=1:length(SMPLE);
    Range=Range(SMPLE);
    for Sample=Range
        Rsample = CAMcompute(Data,inputSize,net,netName,layerName,Dmat,Sample);
        R=R+Rsample;
    end
    Rclass(:,:,1,cls)=R/length(Range);
end

if FIG==1
figure
   r = sqrt(max(double(classes)));
   xr = floor(r);
   xy = ceil(max(double(classes))/xr);
   Range=1:length(Data.YTrain);
   for k=1:nclass
      Sample_cls = Range(double(Data.YTrain)==k);
      Sample_cls = Sample_cls(1);
      subplot(xr,xy,k);
      CAMshow(Data.XTrain(:,:,:,Sample_cls),Rclass(:,:,1,k));
      title(['Activation area: Class ',num2str(k)]);
   end
pause(1);

% figure
% subplot(1,2,1)
% imagesc(Data.XTrain(:,:,1,Sample))
% colormap hot
% colorbar
% %imshow(im)
% title(['Sample ',num2str(Sample),' in color']);

%subplot(1,2,2)
%CAMshow(Data.XTrain(:,:,:,Sample),Rclass(:,:,1,double(Data.YTrain(Sample))));
%title('Activation area');

end

for cls=1:nclass
    [row,col]=ind2sub(size(Rclass(:,:,1,cls)),find(Rclass(:,:,1,cls)>Threshold));
    inputSize = size(Data.XTrain,1:2);
    IND{cls}=sub2ind(size(Rclass(:,:,1,cls)),row,col);
    [Genes{cls},Genes_compressed{cls}] = findGenes(IND{cls},Data.xp,Data.yp,inputSize);
end

if FIG==1
   % cls=1;
   %figure; imshow(Rclass(:,:,1,cls));
   %title(['2D matrix used is ',Dmat,'; Class ',num2str(cls)]);

   r = sqrt(max(double(classes)));
   xr = floor(r);
   xy = ceil(max(double(classes))/xr);
   
%    figure
%    Range=1:length(Data.YTrain);
%    for k=1:nclass
%        subplot(xr,xy,k);
%    B=ones(inputSize);
%    B(IND{k})=Rclass(IND{k});
%    imagesc(B); colormap hot;
%    title(['Area by activation: Class ',num2str(k)])
%    end
   
   figure
   for k=1:nclass
       subplot(xr,xy,k);
   Sample_cls = Range(double(Data.YTrain)==k);
   Sample_cls = Sample_cls(1);
   C=uint8(ones(inputSize)*255);
   im2=Data.XTrain(:,:,1,Sample_cls);
   C(IND{k})=im2(IND{k});
   imagesc(C); colormap hot;
   title(['Genes selected, Class ',num2str(k)]);
   end
end

Unique_G=[];
Unique_Gcmp=[];
for j=1:nclass
    Unique_G=unique([Unique_G;Genes{j}]);
    Unique_Gcmp=unique([Unique_Gcmp;Genes_compressed{j}]);
end
G=Genes;
Gcomp=Genes_compressed;
Genes=Unique_G;
Genes_compressed=Unique_Gcmp;
clear Unique_G Unique_Gcmp

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

    saveas(1,'Class_Activation.jpg','jpg');
    saveas(2,'Genes_PerClass.jpg','jpg');

    savefig(1,'Class_Activation.fig');
    savefig(2,'Genes_PerClass.fig');

    cd(curr_dir);
    display('Files saved in the FIGS folder');
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
    display('Files saved in the Models folder');
end

% store results in *_Results.txt file
Glen=length(Genes);
Glen_comp = length(Genes_compressed);
fprintf(fid2,'Threshold: %6.2f\n',Parm.Threshold);
fprintf('#Genes = %d; #Genes_compressed = %d\n',Glen,Glen_comp);
fprintf(fid2,'#Genes = %d; #Genes_compressed = %d\n',Glen,Glen_comp);
fprintf('Stage %d Ends\n',Parm.Stage);
fprintf(fid2,'Stage %d Ends\n\n',Parm.Stage);
fclose(fid2);

display('Feature selection ends');
