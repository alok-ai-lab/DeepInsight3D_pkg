function [IND,Genes,Genes_compressed] = findActivatedPoints_gradCAM(Data,inputSize,net,Dmat,Threshold,FIG,Sample)

im = cat(3,Data.XTrain(:,:,:,Sample),Data.XTrain(:,:,:,Sample),Data.XTrain(:,:,:,Sample));%imread('ngc6543a.jpg');
imResized = imresize(im,[inputSize(1),inputSize(2)]);
scoreMap = gradCAM(net.trainedNet,imResized,double(Data.YTrain(Sample)));
%gpuDevice(1);
%options=trainingOptions('sgdm','ExecutionEnvironment','gpu');

if FIG==1
figure
subplot(1,2,1)
imshow(imResized);
title(['Sample ',num2str(Sample)]);

subplot(1,2,2)
imshow(imResized); hold on;
imagesc(scoreMap,'AlphaData',0.5);
colormap jet
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
imshow(im); hold on;
imagesc(scoreMap,'AlphaData',0.5);
colormap jet
title('Activation area');

pause(1);
end



%Threshold = 0.5;
%Dmat = 'R'; % R for Red; G for Green; B for Blue
IND = CAMind(imResized,scoreMap,Threshold,Dmat,FIG);

inputSize = size(Data.XTrain,1:2);
[Genes,Genes_compressed] = findGenes(IND,Data.xp,Data.yp,inputSize);

end
