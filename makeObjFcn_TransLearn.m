function ObjFcn = makeObjFcn(XTrain,YTrain,XValidation,YValidation,Parm)
% the objective function is NOT based on Validation Error but on Other
% Measure (OthMes) such as sensitivity, specificty, auc etc.
%
% net: squeezenet, googlenet, efficientnetb0
%
% use previously trained nets for new datasets (transfer learning)

net = Parm.net;% coder.loadDeepLearningNetwork(Parm.net);
measure=Parm.ObjFcnMeasure;
%Augment=Parm.Augment;


ObjFcn = @valErrorFun;
    function [valError,cons,fileName] = valErrorFun(optVars)
        imageSize = [size(XTrain,1) size(XTrain,2) size(XTrain,3)];
        numClasses = numel(unique(YTrain));
        %initialNumFilters = round((max(imageSize)/2)/sqrt(optVars.NetworkDepth));
        numMaxPools=3;
        PoolSizeAvg = floor(max(imageSize)/(2^(numMaxPools)));
        %filterSize = 5;
        
        if nargin<5
        %    net = squeezenet;%googlenet;efficientnetb0
            measure='accuracy';
        end
        %net.Layers(1);
        inputSize = net.Layers(1).InputSize;

        augimdsTrain = augmentedImageDatastore(inputSize(1:2),XTrain,YTrain);
        augimdsValidation = augmentedImageDatastore(inputSize(1:2),XValidation,YValidation);
        
        miniBatchSize = Parm.miniBatchSize;
        % valFrequency = floor(numel(augimdsTrain.Files)/miniBatchSize);
        valFrequency = floor(size(XTrain,4)/miniBatchSize);
        %gpuDevice(1);
        options = trainingOptions('sgdm', ...
            'InitialLearnRate',optVars.InitialLearnRate,...
            'Momentum',optVars.Momentum,...
            'ExecutionEnvironment',Parm.ExecutionEnvironment,...
            'MiniBatchSize',miniBatchSize, ...
            'L2Regularization',optVars.L2Regularization,...
            'MaxEpochs',Parm.MaxEpochs, ...
            'Shuffle','every-epoch', ...
            'ValidationData',augimdsValidation, ...
            'ValidationFrequency',20, ...
            'Verbose',false, ...
            'Plots',Parm.trainingPlot);

	lgraph = layerGraph(Parm.DAGnet);
        trainedNet = trainNetwork(augimdsTrain,lgraph,options);
        close(findall(groot,'Tag','NNET_CNN_TRAININGPLOT_FIGURE'))
        
        [YPredicted,probs] = classify(trainedNet,augimdsValidation);
        if strcmp(measure,'accuracy')
            valError = 1 - mean(YPredicted == YValidation);
            display('accuracy');
        else
            [a,b,c,auc] = perfcurve(YValidation,probs(:,2),'2');
            valError = 1 - auc;
            display('auc based');
%         C=confusionmat(YValidation,YPredicted);
%         TP=C(1,1);
%         FN=C(1,2);
%         FP=C(2,1);
%         TN=C(2,2);
%         Sen=TP/(TP+FN);
%         Spec=TN/(TN+FP);
%         valError = 1 - Spec;
        end
        
        fileName = num2str(valError) + ".mat";
        save(fileName,'trainedNet','valError','options')
        cons = [];        
    end
end
 
