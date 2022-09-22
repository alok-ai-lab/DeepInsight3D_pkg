function ObjFcn = makeObjFcn(XTrain,YTrain,XValidation,YValidation,Parm)
% the objective function is NOT based on Validation Error but on Other
% Measure (OthMes) such as sensitivity, specificty, auc etc.
%
% net: squeezenet, googlenet, efficientnetb0

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

        if isa(net,'SeriesNetwork') 
            lgraph = layerGraph(net.Layers); 
        else
            lgraph = layerGraph(net);
        end 

        [learnableLayer,classLayer] = findLayersToReplace(lgraph);

        if isa(learnableLayer,'nnet.cnn.layer.FullyConnectedLayer')
            newLearnableLayer = fullyConnectedLayer(numClasses, ...
            'Name','new_fc', ...
            'WeightLearnRateFactor',10, ...
            'BiasLearnRateFactor',10);
    
        elseif isa(learnableLayer,'nnet.cnn.layer.Convolution2DLayer')
            newLearnableLayer = convolution2dLayer(1,numClasses, ...
            'Name','new_conv', ...
            'WeightLearnRateFactor',10, ...
            'BiasLearnRateFactor',10);
        end

        lgraph = replaceLayer(lgraph,learnableLayer.Name,newLearnableLayer);

        newClassLayer = classificationLayer('Name','new_classoutput');
        lgraph = replaceLayer(lgraph,classLayer.Name,newClassLayer);

        %initialize all weights and biases (untrained net)
%         tmp_net = lgraph.saveobj;
%         for i=1:length(lgraph.Layers) 
%             if isa(lgraph.Layers(i,1),'nnet.cnn.layer.Convolution2DLayer')
%                 tmp_net.Layers(i,1).Weights=leakyHe(size(tmp_net.Layers(i,1).Weights));%randn(size(tmp_net.Layers(i,1).Weights))* 0.0001;
%                 tmp_net.Layers(i,1).Bias=leakyHe(size(tmp_net.Layers(i,1).Bias))+1;% randn(size(tmp_net.Layers(i,1).Bias))*0.00001 + 1;
%             end
%     
%         end
%         lgraph = lgraph.loadobj(tmp_net);
        %#################################################

        %figure('Units','normalized','Position',[0.3 0.3 0.4 0.4]);
        %plot(lgraph)
        %ylim([0,10])


%###### Freeze Initial Layers ########
% layers = lgraph.Layers;
% connections = lgraph.Connections;
% 
% layers(1:10) = freezeWeights(layers(1:10));
% lgraph = createLgraphUsingConnections(layers,connections);
%######################################

% if Augment==1
%     [XTrain,YTrain] = augmentDeepInsight(XTrain,YTrain);
%     [XValidation,YValidation] = augmentDeepInsight(XValidation,YValidation);
% end

% pixelRange = [-30 30];
% scaleRange = [0.9 1.1];
% imageAugmenter = imageDataAugmenter( ...
%     'RandXReflection',true, ...
%     'RandXTranslation',pixelRange, ...
%     'RandYTranslation',pixelRange, ...
%     'RandXScale',scaleRange, ...
%     'RandYScale',scaleRange);
% augimdsTrain = augmentedImageDatastore(inputSize(1:2),XValidation,YValidation, ...
%     'DataAugmentation',imageAugmenter);
        augimdsTrain = augmentedImageDatastore(inputSize(1:2),XTrain,YTrain);
        if Parm.ValidRatio>0
        augimdsValidation = augmentedImageDatastore(inputSize(1:2),XValidation,YValidation);
        end
% augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain);
%augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation);

%         miniBatchSize = 256;%128;%256;%64; %10
%         % valFrequency = floor(numel(augimdsTrain.Files)/miniBatchSize);
%         valFrequency = floor(size(XTrain,4)/miniBatchSize);
%         gpuDevice(1);
%         options = trainingOptions('sgdm', ...
%             'InitialLearnRate',optVars.InitialLearnRate,...
%             'Momentum',optVars.Momentum,...
%             'ExecutionEnvironment','gpu',...
%             'MiniBatchSize',miniBatchSize, ...
%             'L2Regularization',optVars.L2Regularization,...
%             'MaxEpochs',10, ...
%             'Shuffle','every-epoch', ...
%             'ValidationData',augimdsValidation, ...
%             'ValidationFrequency',valFrequency, ...
%             'Verbose',false, ...
%             'Plots','none');
        
          miniBatchSize = Parm.miniBatchSize;%256;%128;%256;%64;%64;%256;%64; %10
        % valFrequency = floor(numel(augimdsTrain.Files)/miniBatchSize);
        valFrequency = floor(size(XTrain,4)/miniBatchSize);
        %gpuDevice(1);
        if Parm.ValidRatio>0
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
        else
             options = trainingOptions('sgdm', ...
            'InitialLearnRate',optVars.InitialLearnRate,...
            'Momentum',optVars.Momentum,...
            'ExecutionEnvironment',Parm.ExecutionEnvironment,...
            'MiniBatchSize',miniBatchSize, ...
            'L2Regularization',optVars.L2Regularization,...
            'MaxEpochs',Parm.MaxEpochs, ...
            'Shuffle','every-epoch', ...
            'Verbose',false, ...
            'Plots',Parm.trainingPlot);
        end
%Shuffle,'every-epoch'
        
%         options = trainingOptions('rmsprop', ...
%             'InitialLearnRate',4.98661e-5,...
%             'SquaredGradientDecayFactor',0.9,...
%             'ExecutionEnvironment','gpu',...
%             'MiniBatchSize',miniBatchSize, ...
%             'L2Regularization',1.25157e-2,...
%             'MaxEpochs',20, ...
%             'Shuffle','every-epoch', ...
%             'ValidationData',augimdsValidation, ...
%             'ValidationFrequency',20, ...
%             'Verbose',false, ...
%             'Plots','training-progress');

        %  'ExecutionEnvironment','multi-gpu',...
%            'Plots','training-progress');
       %     'Plots','none');
        
        %    'Plots','training-progress');
        rng('default');
        trainedNet = trainNetwork(augimdsTrain,lgraph,options);
        close(findall(groot,'Tag','NNET_CNN_TRAININGPLOT_FIGURE'))
        
        if Parm.ValidRatio>0
            [YPredicted,probs] = classify(trainedNet,augimdsValidation);
        
            if strcmp(measure,'accuracy')
                valError = 1 - mean(YPredicted == YValidation);
                disp('accuracy');
            else
                [a,b,c,auc] = perfcurve(YValidation,probs(:,2),'2');
                valError = 1 - auc;
                disp('auc based');
%         C=confusionmat(YValidation,YPredicted);
%         TP=C(1,1);
%         FN=C(1,2);
%         FP=C(2,1);
%         TN=C(2,2);
%         Sen=TP/(TP+FN);
%         Spec=TN/(TN+FP);
%         valError = 1 - Spec;
            end
        else
            valError = 100;
            disp('Validation data not used!')
        end
        fileName = num2str(valError) + ".mat";
        save(fileName,'trainedNet','valError','options','-v7.3')
        cons = [];
    end
end
 
