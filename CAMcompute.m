function R = CAMcompute(Data,inputSize,net,netName,layerName,Dmat,Sample);
% R = CAMcomputeR(classActivationMap);

im = Data.XTrain(:,:,:,Sample); %cat(3,Data.XTrain(:,:,:,Sample),Data.XTrain(:,:,:,Sample),Data.XTrain(:,:,:,Sample));%imread('ngc6543a.jpg');
imResized = imresize(im,[inputSize(1),inputSize(2)]);
%gpuDevice(1);
%options=trainingOptions('sgdm','ExecutionEnvironment','gpu');
imageActivations = activations(net.trainedNet,imResized,layerName);

scores = squeeze(mean(imageActivations,[1,2]));
    
if netName ~= "squeezenet"
        fcWeights = net.trainedNet.Layers(end-2).Weights;
        fcBias = net.trainedNet.Layers(end-2).Bias;
        scores =  fcWeights*scores + fcBias;
        
        [~,classIds] = maxk(scores,3);
        
        weightVector = shiftdim(fcWeights(classIds(1),:),-1);
        CAM = sum(imageActivations.*weightVector,3);
else    
        [~,classIds] = maxk(scores,3);
        CAM = imageActivations(:,:,classIds(1));
end


CAM = imresize(CAM,inputSize(1:2));
CAM = normalizeImage(CAM);
CAM(CAM<0.2) = 0;
cmap = jet(255).*linspace(0,1,255)';
CAM = ind2rgb(uint8(CAM*255),cmap)*255;

combinedImage = double(rgb2gray(im))/2 + CAM;
combinedImage = normalizeImage(combinedImage)*255;


if strcmp('r',lower(Dmat))==1
    H=combinedImage(:,:,1); %let it do for 'R' or Red
    DmatStr='Red';
elseif strcmp('g',lower(Dmat))==1
    H=combinedImage(:,:,2); %let it do for 'G' or Green
    DmatStr='Green';
elseif strcmp('b',lower(Dmat))==1
    H=combinedImage(:,:,3); %let it do for 'B' or Blue
    DmatStr='Blue';
else
    disp('Error: 2Dmat not defined, use string R, G or B');
end
%## Find which pixels are expressed #### (by Alok)
% H=combinedImage(:,:,1); %let it do for 'R' only
R=H/255;

%##################################################
end

