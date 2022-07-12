% Example 3: Feature selection using iterative procedure
%
% In this Example, feature selection using CAMs is performed in an iterative
% manner. There are 3 steps in the iterative procedure:
%           1) conversion of tabular data to image
%           2) estimating/validating CNN net using training and validations
%           sets.
%           3) feature selection using CAMs
%           4) repeating the above 3 steps until a desired number of
%           features or max. of 6 stages is reached. At this point,
%           terminate the iterative procedure.
%
%  Caution: This procedure could take a very long time (depending upon 
%  your hardware)
%
% Example data: dataset1.mat

clear all;
close all hidden;

% call parameters
% 1. Set up parameters by changing Parameter.m file, otherwise leave it with default values.
% 2. Provide the path of dataset in Parameter.m file by changing the "Data_path" variable.

DSETnum = 1; %This means the stored data in your defined path is dataset1.mat
	     
Parm = Parameters(DSETnum); % Define parameters for DeepInsight3D and CNN

% NOTE: 1) Set "Parm.miniBatchSize" based on your GPU requirements. 
%       by default Parm.miniBatchSize = 512.
%   
%       2) Set execution environment (for trainingOptions). By default it
%       is set to 'multi-gpu'.

Parm.MaxEpochs = 5; % for a quick check  use a lower value for MaxEpochs

% Set CAM Threshold
Parm.Threshold=0.3; % varying threshold will change the number of features selected 

Parm.trainingPlot = 'none'; % no training plot
Parm.FileRun = 'Run2'; % save models in Run2 folder

Glen=inf; 
% iterate until desired number of features is obtained
% or Stage 6 has reached.
while (Glen > Parm.DesiredGenes) & (Parm.Stage < 7)

    % conversion to image and CNN model estimation
    [AUC,C,Accuracy,ValErr] = DeepInsight3D(DSETnum,Parm);

    % Feature selection
    [Genes,Genes_compressed,G]= func_FS_class_basedCAM(Parm); 
    % class-based CAM values (used in this paper)
    % NOTE: func_FS_class_basedCAM saves Models so no need to run
    % func_SaveModels and func_SaveFigs functions!

    Glen=length(Genes);
    Parm.Stage=Parm.Stage+1;
end
 