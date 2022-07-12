function [AUC,C,Accuracy,ValErr] = DeepInsight3D(DSETnum,Parm)
%[AUC,C,Accuracy,ValErr] = DeepInsight3D(DSETnum)
% DeepInsight3D function
% DSETnum is the number of dataset; e.g. dataset1.mat. dataset2.mat,...
%
% AUC (for 2-class problem) otherwise returns an empty matrix
% C is the confusion matrix of the test set
% Accuracy is the test accuracy
% ValErr is the validation error of the validation set
%
% contact: alok.fj@gmail.com

close all;

fid2 = fopen('DeepInsight3D_Results.txt','a+');
fprintf(fid2,'\n');
fprintf(fid2,'%s',Parm.FileRun);
fprintf(fid2,'\n');
fprintf(fid2,'SnowFall: %d\n',Parm.SnowFall);
fprintf(fid2,'Method: %s\n',Parm.Method);
if any(strcmp('Dist',fieldnames(Parm)))==1
    fprintf(fid2,'Distance: %s\n',Parm.Dist);
else
    fprintf(fid2,'Distance is not applicable or Deafult\n');
end
fprintf(fid2,'Use Previous Model: %s\n',Parm.UsePrevModel);

% Convert tabular data to image
display('Conversion of tabular data to images is starting ...');
[InputSz1,InputSz2,InputSz3,Init_dim,SET] = func_Prepare_Data(Parm);
display('Conversion finished and saved as Out1.mat or Out2.mat!');

% Run CNN net
display('Training model begins: Net1');
[Accuracy,ValErr,Momentum,L2Reg,...
    InitLR,AUC,C,prob] = func_TrainModel(Parm);

fprintf(fid2,'Stage %d\n',Parm.Stage);
fprintf(fid2,'Net: %s\n',Parm.NetName);
fprintf(fid2,'ObjFcnMeasure: %s\n',Parm.ObjFcnMeasure);
fprintf('Test Accuracy: %6.4f; ValErr: %4.4f; \n',Accuracy,ValErr);
fprintf('Momentum: %g; L2Regularization: %g; InitLearnRate: %g\n',Momentum,L2Reg,InitLR);
fprintf(fid2,'Stage: %d; Test Accuracy: %6.4f; ValErr: %4.4f; \n',Parm.Stage,Accuracy,ValErr);
fprintf(fid2,'Momentum: %g; L2Regularization: %g; InitLearnRate: %g\n',Momentum,L2Reg,InitLR);

if size(C,1)==2
    fprintf(fid2,'AUC: %6.4f; \n',AUC);
end

fprintf(fid2,'ConfusionMatrix:\n');
for nC=1:size(C,2)
    fprintf(fid2,'%d\t',C(nC,:));
    fprintf(fid2,'\n');
end
display('Training model ends');
fprintf('\n');

fclose(fid2);
end

