function Parm = Parameters(DSETnum)
% Paramaters for the DeepInsight-3D model

Parm.Method = ['tsne']; % 1) tSNE 2) kpca or 3) pca 4) umap
Parm.Dist = 'euclidean';% For tSNE only 1) mahalanobis 2) cosine 3) euclidean 4) chebychev 5) correlation 6) hamming (default: cosine)

Parm.Max_Px_Size = 224; %227 for SqueezeNet, 224 EfficientNetB0 (however, not necessary to change)
Parm.MPS_Fix=1;
%Parm.MPS_Fix = 1; % if this val is 1 then screen will be 
                  % Max_Px_Size x Max_Px_Size (e.g. 227x227), otherwise 
                  % automatically decided by the distribution of the input data.
                  
Parm.ValidRatio = 0.1; % ratio of validation data/Training data
Parm.Seed = 108; % random seed to distribute training and validation sets
Parm.Norm = 2; % Select '1' for Norm-1, '2' for Norm-2 and '0' for automatically select the best Norm (either 1 or 2).
Parm.FileRun = ['Run',num2str(DSETnum)];%
Parm.SnowFall = 0;%1; % Put 1 if you want to use SnowFall compression algorithm
Parm.Threshold = 0.3; %CAM threshold [0,1]

Parm.DesiredGenes = 1200;% number of expected features to be selected
Parm.UsePrevModel = 'n'; % 'y' for yes and 'n' for no (for CNN). For 'y' the hyperparameter of previous stages will be used.
Parm.SaveModels = 'y'; % 'y' for saving models or 'n' for not saving
Parm.Stage=1; % '1', '2', '3', '4', '5' depending upon which stage of DeepInsight-FS to run.
Parm.ObjFcnMeasure = 'accuracy';%'accuracy' or 'other' % select objective function valError (accuracy or other (for other measures eg sensitiity, specificity, auc etc)
Parm.MaxObj = 1; % maximum objective functions for Bayesian Optimization Technique
Parm.ParallelNet = 0; % if '1' then parallel net (from DeepInsight project) will be used using makeObjFcn2.m
if Parm.MaxObj==1
    Parm.InitialLearnRate=4.98661e-5;
    Parm.Momentum=0.801033;
    Parm.L2Regularization=1.25157e-2;
    % if net is parallel (custom made)
    if Parm.ParallelNet==1
    Parm.initialNumFilters = 4;
    Parm.filterSize = 12;
    Parm.filterSize2 = 2;
    end
end
Parm.MaxEpochs = 400;
Parm.MaxTime = 50; % (in hours) Max. training time in hours to run a model.  
Parm.trainingPlot = 'training-progress'; % 'training-progress' to view training plot otherwise 'none'

% ExecutionEnvironment — Hardware resource for training network
%'auto' | 'cpu' | 'gpu' | 'multi-gpu' | 'parallel'
Parm.ExecutionEnvironment = 'multi-gpu';

% CNN net
Parm.NetName = 'resnet50';%'resnet50';%'inceptionresnetv2';%'nasnetlarge';%alexnet;%squeezenet;%'efficientnetb0'; 'googlenet';
Parm.net = eval(Parm.NetName);

if Parm.ParallelNet==1
    Parm.NetName = 'ParallelNet';
    Parm = rmfield(Parm,'net');
end

% Minimum Batch size
Parm.miniBatchSize = 512;%256;

% augment training set during CNN model estimation
Parm.Augment = 1;%1; % '1' to augment training data, otherwise set it '0'
Parm.AugMeth = 2; % Type '1' or original method and '2' for DeepInsight_Ver2 method
Parm.aug_tr = 500; % augment 500 samples per class in the training set if num of samples is less than 500
Parm.aug_val = 50; % augment 50 samples per class in the validation set if num of samples < 50
Parm.ApplyFS = 0; %if '1' then apply Feature Selection using logreg otherwise '0'
Parm.FeatureMap = 1; % if '0' means use 'All' omics data for Cart2Pixel;
                     % if '1' means use Layer 1 (eg 'EXP' omics) data only
                     % if '2' means use Layer 2 (eg 'MET' omics) data only
                     % if '3' means use Layer 3 (eg 'MUT' omics) data only
Parm.TransLearn = 0; % learn from previous datasets '1' for yes

% Define Model PATH
% Set where you want to store the model and FIGS, and path of Data
%(default settings are given here)
curr_dir=pwd;
FIGS_path = [curr_dir,'/FIGS/'];
Models_path = [curr_dir,'/Models/'];
Data_path = [curr_dir,'/Data/'];
Parm.PATH{1} =  FIGS_path; %'~/DeepInsight3D/FIGS/'; %Store figures in this folder
Parm.PATH{2} = Models_path; %'~/DeepInsight3D_pkg/Models/'; % Store model in this folder
Parm.PATH{3} = Data_path; % store your data here

if Parm.TransLearn==1
    Parm.TLdir = 'Run32'; % Define as per the path of your stored model.
    Parm.TLfile = [Models_path,Parm.TLdir,'/Stage1/model.mat'];
    cd(Parm.TLfile(1:end-9)); 
    Mod = load(Parm.TLfile);
    ModF = load(Mod.fileName);
    cd(curr_dir);
    Parm.DAGnet = ModF.trainedNet;
end

% Dataset name
Parm.Dataname = ['dataset',num2str(DSETnum),'.mat'];% change as required
end
