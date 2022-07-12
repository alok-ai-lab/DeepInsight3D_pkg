% Example 2: Feature selection of saved model
%
% In this Example, feature selection using class-activation maps (CAMs) is executed. 
% It is assumed that Example 1 has been run before running this Example.
% Running Example 1 will save model files in Models/Run.. folder and also the 
% data file either Out1.mat (if norm1 is used) or Out2.mat (if norm2 is used).

clear all;
close all hidden;

% NOTE: folders/filename/stages are defined as per Example 1

% Step 1: copy model files in the correct folders
% current directory is DeepInsight3D_pkg
unix(['cp Models/Run1/Stage1/model.mat .']);
unix(['cp Models/Run1/Stage1/0.*.mat DeepResults']);

%Step 2: call parameters
% 1. Set up parameters by changing Parameter.m file, otherwise leave it with default values.
% 2. Provide the path of dataset in Parameter.m file by chaning the "Data_path" variable.

DSETnum = 1; %This means the stored data in your defined path is dataset1.mat
	     % dataset(DSETnum) (as per Example 1)
Parm = Parameters(DSETnum); % Define parameters for DeepInsight3D and CNN

% Set CAM Threshold
Parm.Threshold=0.35; % varying threshold will change the number of features selected 

[Genes,Genes_compressed,G]= func_FS_class_basedCAM(Parm); % class-based CAM values (used in this paper)
%[Genes,Genes_compressed,G]= func_FeatureSelection_CAM(Parm); % sample based CAM (same as DeepFeature paper)
%[Genes,Genes_compressed,G]= func_FeatureSelection_avgCAM(Parm);% using average CAM values across all the training samples
 
