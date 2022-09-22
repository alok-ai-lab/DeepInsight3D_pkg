function [Out,Norm]  = DeepInsight_train_CAM(Parm,Norm)
% [Out,Norm] = DeepInsight_train_CAM(Parm);
%
% dset is a data struct (dset.Xtrain, dset.XValidation,...)
%
% Out is the output in struct format

%fprintf(Parm.fid,'\nDataset: %s\n',dset.Set);
%fprintf('\nDataset: %s\n',dset.Set);

if nargin<2

dset = load('Out1.mat');
if Parm.ValidRatio==0
    dset.XValidation=[];
end
if size(dset.XTrain,3)==1
    dset.XTrain = cat(3,dset.XTrain,dset.XTrain,dset.XTrain);
    dset.XValidation = cat(3,dset.XValidation,dset.XValidation,dset.XValidation);
elseif size(dset.XTrain,3)==2
    dset.XTrain = cat(3,dset.XTrain(:,:,1,:),dset.XTrain(:,:,2,:),dset.XTrain(:,:,1,:));
    dset.XValidation = cat(3,dset.XValidation(:,:,1,:),dset.XValidation(:,:,2,:),dset.XValidation(:,:,1,:));
end

Out1 = DeepInsight_train_norm_CAM(dset.XTrain,dset.YTrain,dset.XValidation,dset.YValidation,Parm);
if Parm.ValidRatio>0
    fprintf('\nNorm-1 valError %2.4f\n',Out1.valError);
    fprintf(Parm.fid,'\nNorm-1 valError %2.4f\n',Out1.valError);
else
    fprintf('\nNo validation is used\n');
    fprintf(Parm.fid,'\nNo validation is used\n');
end

dset = load('Out2.mat');
if Parm.ValidRatio==0
    dset.XValidation=[];
end
if size(dset.XTrain,3)==1
    dset.XTrain = cat(3,dset.XTrain,dset.XTrain,dset.XTrain);
    dset.XValidation = cat(3,dset.XValidation,dset.XValidation,dset.XValidation);
elseif size(dset.XTrain,3)==2
    dset.XTrain = cat(3,dset.XTrain(:,:,1,:),dset.XTrain(:,:,2,:),dset.XTrain(:,:,1,:));
    dset.XValidation = cat(3,dset.XValidation(:,:,1,:),dset.XValidation(:,:,2,:),dset.XValidation(:,:,1,:));
end

Out2 = DeepInsight_train_norm_CAM(dset.XTrain,dset.YTrain,dset.XValidation,dset.YValidation,Parm);

clear dset
if Parm.ValidRatio>0
    fprintf('\nNorm-2 valError %2.4f\n',Out2.valError);
    fprintf(Parm.fid,'\nNorm-2 valError %2.4f\n',Out2.valError);
else
    fprintf('\nNo validation is used\n');
    fprintf(Parm.fid,'\nNo validation is used\n');
end
% select best one from Out1 and Out2
if Out1.valError < Out2.valError
    Out = Out1;
    Norm = 1;
else
    Out = Out2;
    Norm = 2;
end

fprintf(Parm.fid,'\nDeepInsight valErr: %6.4f\n',Out.valError);

else
    if Norm==1
        dset = load('Out1.mat');
        if Parm.ValidRatio==0
            dset.XValidation=[];
        end
        if size(dset.XTrain,3)==1
            dset.XTrain = cat(3,dset.XTrain,dset.XTrain,dset.XTrain);
            dset.XValidation = cat(3,dset.XValidation,dset.XValidation,dset.XValidation);
        elseif size(dset.XTrain,3)==2
            dset.XTrain = cat(3,dset.XTrain(:,:,1,:),dset.XTrain(:,:,2,:),dset.XTrain(:,:,1,:));
            dset.XValidation = cat(3,dset.XValidation(:,:,1,:),dset.XValidation(:,:,2,:),dset.XValidation(:,:,1,:));
        end

        Out1 = DeepInsight_train_norm_CAM(dset.XTrain,dset.YTrain,dset.XValidation,dset.YValidation,Parm);
        if Parm.ValidRatio>0
            fprintf('\nNorm-1 valError %2.4f\n',Out1.valError);
            fprintf(Parm.fid,'\nNorm-1 valError %2.4f\n',Out1.valError);
        else
            fprintf('\nNo validation is used\n');
            fprintf(Parm.fid,'\nNo validation is used\n');
        end
        Out = Out1;
        Norm = 1;
    elseif Norm==2
        dset = load('Out2.mat');
        if Parm.ValidRatio==0
            dset.XValidation=[];
        end
        if size(dset.XTrain,3)==1
            dset.XTrain = cat(3,dset.XTrain,dset.XTrain,dset.XTrain);
            dset.XValidation = cat(3,dset.XValidation,dset.XValidation,dset.XValidation);
        elseif size(dset.XTrain,3)==2
            dset.XTrain = cat(3,dset.XTrain(:,:,1,:),dset.XTrain(:,:,2,:),dset.XTrain(:,:,1,:));
            dset.XValidation = cat(3,dset.XValidation(:,:,1,:),dset.XValidation(:,:,2,:),dset.XValidation(:,:,1,:));
        end

        Out2 = DeepInsight_train_norm_CAM(dset.XTrain,dset.YTrain,dset.XValidation,dset.YValidation,Parm);

        clear dset
        if Parm.ValidRatio>0
            fprintf('\nNorm-2 valError %2.4f\n',Out2.valError);
            fprintf(Parm.fid,'\nNorm-2 valError %2.4f\n',Out2.valError);
        else
            fprintf('\nNo validation is used\n');
            fprintf(Parm.fid,'\nNo validation is used\n');
        end
        Out = Out2;
        Norm = 2;
    end

fprintf(Parm.fid,'\nDeepInsight valErr: %6.4f\n',Out.valError);
end

end
