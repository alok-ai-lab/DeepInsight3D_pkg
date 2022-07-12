# DeepInsight3D
DeepInsight3D package to deal with multi-omics or multi-layered data

DeepInsight3D has 3 main components. 1) it converts multi-layered non-image samples (such as multi-omics) into colored image-forms (i.e. 3D image samples). 2) The images are applied to convolutional neural network (CNN). 3) It can also perform element selection via CNN, such as using class-activation maps (CAMs). 

This approach builds a 3D-image by arranging similar elements (or genes) together and dissimilar apart, and then by mapping the multi-layered non-image values on to these aligned pixel locations. This approach employs CNN for element or gene selection on non-image data. 

# Reference 
Sharma A, et al. ...  TBA

## Download and Install

1. Download Matlab package DeepInsight3D_pkg.tar.gz from the link above. Store it in your working directory. Gunzip and untar as follows:

    ```Matlab
    >> gunzip DeepInsight3D_pkg.tar.gz
    >> tar -xvf DeepInsight3D_pkg.tar
    ```

2. Follow the link: (http:/... TBA ... /dataset1.mat) to download PDX_Paclitaxel multi-omics data the RNA-seq data (caution: data size is 88MB). The dataset is given in .mat file format of Matlab. Place the data file ‘dataset1.mat’ in the folder, `~/DeepInsight3D_pkg/Data/`

3. Download and Install example CNN net such as ResNet-50 in Matlab, see details about ResNet-50 from MathWorks [link](https://www.mathworks.com/help/deeplearning/ref/resnet50.html).

4. Executing the DeepInsight3D_pkg: all code should run in the folder ../DeepInsight3D_pkg/, if you want to run in a different folder then addpath in Matlab

### Example 1: classification of multi-omics or multi-layered data using DeepInsight3D model
In this example, multi-omics example data (PDX_Paclitaxel) which is saved in DeepInsight3D_pkg/Data folder as 'dataset1.mat', is first converted to images using DeepInsight3D converter. Then CNN net (resnet50) is applied for training the model. The performance evaluation, in terms of accuracy and AUC, are done on the test set of the data.

1. File: open Example1.m file in the Matlab Editor.

2. Set up parameters by changing `Parameter.m` file. Based on your hardware, change `Parm.miniBatchSize` (default 512) and `Parm.ExecutionEnvironment` (default multi-gpu. If you don't want to see the training progress plot by CNN then set `Parm.trainingPlot=none`. Alternatively, leave all parameters  at their default values.

3. Dataset calling: since the dataset name is `dataset1.mat`, the variable `DSETnum=1` (at Line 17 of Example1.m) has been used. If the name of the dataset is `datasetX.m` then variable `DSETnum` should be `X`.

4. Example1.m file uses function DeepInsight3D.m. This function has two parts: 1) tabular data to image convertion using `func_Prepare_Data.m`, and 2) CNN training using resent50 (default or change as required) using `func_TrainModel.m`.
5. The output is AUC (for 2-class problem only), C (confusion matrx) and Accuracy of the test set (at Line 28). It also gives ValErr which is the validation error.
6. By default, trained CNN models (such as model.mat, 0*.mat) and converted data (either Out1.mat or Out2.mat) will be saved in folder /Models/Run1/ and figures will be stored in folder /FIGS/Run1/. The saving of files are done by calling `func_SaveModels.m` and `func_SaveFigs.m`
7. The execution results are stored in `DeepInsight3D_Results.txt` file in /DeepInsight3D_pkg/ folder.
8. A few messages will be displayed by running Example1.m on the Command Window of Matlab, such as

    ```
    Dataset: PDX_Paclitaxel
    
    NORM-2
    tSNE with burneshut algorithm has been used
    Distance: euclidean

    Pixels: 227 x 227
    Training model begins: Net1
    ...
    Out =
      struct with fields:
      bestIdx: 1
      fileName: "0.32624.mat"
      valError: 0.3262
      
    Stage: 1; Test Accuracy: 0.6744; ValErr: 0.3262;
    Momentum: 0.801033; L2Regularization: 0.0125157; InitLearnRate: 4.9866e-05
    
    Training model ends
    ```

    *Note that the above values might differ.*

    Objective function image will be shown for the Bayesian Optimization Technique (BOT). By default 'no BOT' will be applied; i.e. `Parm.MaxObj=1`. However, if BOT is required then change parameter `Parm.MaxObj' value higher than 1. If it is set as '20' then 20 objective functions will be searched for hyperparameters tuning and the best one (with the minimum validation error) will be selected.
    
    Results file: check `DeepInsight3D_Results.txt` for more information, such as
    ```
    AUC: 0.7789
    ConfusionMatrix
    25  13
    1   4
    ```
### Example 2: Feature selection of saved model
In this example, feature selection using class-activation maps (CAMs) is executed. It is assumed that Example 1 has been run before running this example. Running Example 1 will save model files in Models/Run.. folder, and also the data file Out1.mat (if norm1 is used) or Out2.mat (if norm2 is used).

Running Example2.m will perform feature selection. However, steps are described here under.

1.  copy saved model files in the correct folders
    ```
    unix(['cp Models/Run1/stage1/model.mat .']);
    unix(['cp Models/Run1/stage1/0.*.mat DeepResults']);
    ```
2.  Dataset is still the same therefore parameter `DSETnum=1`. Call parameters using `Parm = Parameters(DSETnum);`
3.  Set CAM threshold e.g. `Parm.Threshold = 0.35;`
4.  Execute classed-based CAm using `func_FS_class_basedCAM(Parm);` as shown in Example2.m (Line 29). The following information will be displayed on the screen.

    ```
    Feature selection begins
    model = 
       struct with fields
       Norm: 2
       bestIdx: 1
       fileName: '0.32624.mat'
    
    Files saved in the FIGS folder
    Files saved in the Models folder
    #Genes = 5205; #Genes_compressed = 3331
    Stage 1 Ends
    ```
Images will be stored in FIGS folder. The following command can be used to open images in the unix console/terminal:

    
    eog ~/DeepInsight3D_pkg/FIGS/Run1/Stage1/Class_Activation.jpg
    
Class activation image is given below. Since only two classes exist, the figure shows 'class1' and 'class2' activations.    
    ![alt text](https://github.com/alok-ai-lab/DeepInsight3D/blob/main/Class_Activation.jpg?raw=true)
    
Vary the threshold `Parm.Threshold` between 0 and 1 to vary the number of selected features/genes.

Features selected per class can also be viewed from FIGS/Run1/ folder.
    ![alt text](https://github.com/alok-ai-lab/DeepInsight3D/blob/main/Genes_PerClass.jpg?raw=true)

### Example 3: Feature selection using iterative procedure
In this example, feature selection using CAMs is performed in an iterative manner. There are 3 steps in this iterative procedure:
1)  conversion of multi-layered tabular data to 3D image.
2)  estimation of CNN net using the training set and validation using the validation set.
3)  feature selection using CAMs
4)  repeating the above 3 steps until a desired number of features or maximum of 6 stages is reached. At this point, iterative procedure will be terminated.

*Caution: this procedure could take a very long processing time (depending upon hardware specs)*

Running Example3.m will execute iterative procedure. However, steps are described hereunder.

Steps:
1)  Set up parameters by changing Parameters.m file, otherwise leave it with default values.
2)  Provide the path od dataset in Parameter.m file by changing "Data_path" variable. In this example, it is set as /DeepInsight3D_pkg/Data/
3)  Define the stored dataset using 
        `DSETnum=1;`
5)  Call parameters using 
        `Parm = Parameters(DSETnum);`
7)  For testing code, reduce the MaxEpochs e.g. 
        `Parm.MaxEpochs = 5;`
    for better training it would be good to have higher value of MaxEpochs.
    
9)  Set the CAM Threshold 
        `Parm.Threshold = 0.3;`
11)  Suppress training plot (otherwise several plots will be invoked for every Stage)
        `Parm.trainingPlot = 'none';`
13)  Define the folder where models to be stored
        `Parm.FileRun = 'Run2';`
15)  The following code will perform iterative procedure:

        ```
        Glen = inf;
        while (Glen > Parm.DesiredGenes) & (Parm.Stage < 7)
            [AUC,C,Accuracy,ValErr] = DeepInsight3D(DSETnum,Parm);
            [Genes,Genes_compressed,G] = func_FS_class_basedCAM(Parm);
            Glen = length(Genes);
            Parm.Stage = Parm.Stage + 1;
        end
        ```

 
### Note:

* All the results will be stored in current stage folder
 `~/DeepInsight3D_pkg/Models/Run2/StageX`  where X is the current stage;

* Similarly, all the figures will be stored in a folder
`~/DeepInsight3D_pkg/FIGS/Run1/StageX` where X is the current stage.

* If the loop continues then the value of X will increment to 2, 3, 4, …; i.e., repeating DeepInsight3D model to find a smaller subset of features/genes.

## Description of files and folders

1. `DeepInsight3D_pkg` has 4 folders: Data, DeepResults, FIGS and Models. It has several .m files. However, the main files are 1) `Deepinsight3D.m` to peform image conversion and CNN modeling, and 2) `func_FS_classbasedCAM.m` to perform feature selection. All the parameter settings can be done in `Parameters.m` file.

2. DeepInsight3D.m has 2 main functions:

    * `func_Prepare_Data`: This function loads the data, splits the training data into the Train and Validation sets, normalizes all the 3 sets (including Test set), and converts multi-layered non-image samples to 3D image form using the Training set. The Test and Validation sets are not used to find pixel locations. Once the pixel locations are obtained, all the non-image samples are converted to 3D image samples. The image datasets are stored as Out1.mat or Out2.mat depending on whether norm1 or norm2 was executed.

    * `func_TrainModel`: This function executes the convolution neural network (CNN) using many pretrained and custom nets. The user may change the net as required. The default values of hyperparameters for CNN are used. However, if `Parm.MaxObj` is greater than 1 then it optimizes hyper-parameters using the Bayesian Optimization Technique. It uses Training set and Validation set to tune and evaluate the model hyper-parameters.

        Note: To tune hyperparameters of CNN automatically, use a higher value of `Parm.MaxObj`.

        The best evaluation is stored in DeepResults folder as .mat files, where the file name depicts the best validation error achieved. For example, file 0.32624.mat in DeepResults folder tells the hyper-parameters at validation error 0.32624. Also, the model file `model.mat` detailing the nets will be stored.

3. Feature selection functions
    * `func_FeatureSelection`: This will find activation maps at the ReLu layer, perform Region Accumulation (RA) step and Element Decoder step to find gene subset. The input is model.mat (from `func_TrainModel`) and related .mat file from the folder DeepResults. This function finds CAM for each sample and provide the union of all maps.
    * `func_FS_class_basedCAM`: This function performs class-based CAM, i.e., each class will have a distinct CAM.
    * `func_FeatureSelection_avgCAM`: This function finds the common CAM across all the samples.

4. Non-image to image conversion: two core sub-functions of `func_Prepare_Data` are used to convert samples from non-image to image. These are described below.

    * `Cart2Pixel`: The input to this function is the entire Training set. The output is the feature or gene locations Z in the pixel frame. The size of the pixel frame is pre-defined by the user.

    * `ConvPixel`: The input is a non-image sample or feature vector and Z (from above). The output is an image sample corresponding to the input sample.

4. Compression Snow-fall algorithm (SnowFall.m): Not used in this package. However, this compression algorithm is used to provide more space for features in the given pixel frame. Since the conversion from Cartesian coordinates system to the pixel frame depends on the pixel resolution, it becomes difficult to fit all the features without overlapping each other. This algorithm tries to create more space such that the overlapping of feature or gene location can be minimized. The input is the locations of genes or features with the pixel size information. The output is the readjusted image. It is up to the user to use Snow-fall compression or not by setting `Parm.SnowFall` to either `0` (not use) or `1` (use).

5. Extraction of Gene Names (optional): This option is useful for enrichment analysis. Two files for extraction of genes are GeneNames_Extract.m and GeneNames.m. The list of names of genes is stored in `~/DeepInsight3D_pkg/Models/RunY/StageX/` folder.

    After running feature selection function, the results will be stored in the corresponding RunY and StageX folders (where X and Y are integers 1,2,3…). If it is required to find the gene IDs/names of the obtained subset for each cancer type, then execute `GeneNames_Extract` function. Go to Line 4, and set the `Out_Stages` variable. For e.g. if Stage 2 has been saved inside Run1 after executing `func_FS_class_basedCAM`, use `Out_Stages = 2`. Then go to Line 6 and define `FileRun`. For example, it is set as `FileRun = ‘Run1’`.

    The gene list per class will be generated. If there are 10 cancer-types, then 10 files will be generated. In addition, one file with all genes listed will be generated (e.g. GeneList_UnCmprss.txt). The results will be stored in `~/Models/RunY/StageX` as RunYStageX.tar.gz and a folder with the same results will also be created as RunYStageX. In this example, it will be stored in the folder `Run1Stage2` and Run1Stage2.tar.gz.


## Parameter settings to run the package

A number of parameters/variables are used to control the DeepFeature_pkg. The details are given hereunder

1. `Parm.Method` (selection dimensionality reduction technique)

    Dimensionality reduction technique can be considered as one of the following methods; 1) tSNE 2) Principal component analysis (PCA) 3) kernel PCA, 4) uniform manifold approximation and projection (umap). For umap you can use python or R scripts (please see umapa_Rmatlab.m).

    Select this variable in Parameter.m file or after calling `Parm = Parameter(DSETnum)` change

    Parm.Method = ‘tSNE’, ‘kpca’, ‘pca’ or ‘umap’

    Default is tSNE.

2. `Parm.Dist` (Distance selection only for tSNE)

    If tSNE is used, then one of the following distances can be used. The default distance is ‘euclidean’.

    Parm.Dist = ‘cosine’, ‘hamming’, ‘mahalanobis’, ‘educidean’, ‘chebychev’, ‘correlation’, ‘minkowski’, ‘jaccard’, or ‘seuclidean’ (standardized Eucliden distance).

3. `Parm.Max_Px_Size` (maximum pixel frame either row or column)

    The default value is 224 as required by ResNet-50 architecture.

4. `Parm.ValidRatio` (ratio of validation data and training data)

    The amount of training data required to be used as a validation set. Default is 0.1; i.e., 10% of training data is kept aside as a validation set. The new training set will be 90% of the original size.

5. `Parm.Seed`

    Random parameter seed to split the data.

6.  `Parm.NetName`: use pre-trained nets such as `resnet50`, `inceptionresnetv2`, `nasnetlarge`, `efficientnetb0`, `googlenet` and so on.

7.  `Parm.ExecutionEnvironment`: execution environment based on your hardware. Options are `cpu`, `gpu`, `multi-gpu`, `parallel`, and `auto`. Please check trainingOptions (Matlab) for further details.

8.  `Parm.ParallelNet`: if '1' then this option overrides `Parm.NetName`. The custom made net from `makeObjFcn2.m` will be used.

9.  `Parm.miniBatchSize`: define miniBatchSize, default is 512.

10.  `Parm.Augment`: augment samples during training progress, select '1' for yes and '0' for no.

11.  `Parm.AugMeth`: select method '1' or '2'. Method 1 automatically augments samples whereas Method 2 is done by the user

12.  `Parm.aug_tr`: if `Parm.AugMeth=2` then `Parm.aug_tr=500` will augment 500 samples of training set if the number of samples in a class is less than 500.

13.  `Parm.aug_val`: if `Parm.Aug=2` then `Parm.aug_val=50` will augment 50 samples of validation set if the number of samples in a class is less than 50.

14.  `Parm.ApplyFS`: if '1' it applies a feature selection process using Logistic Regression before applying DeepInsight transformation.

15.  `Parm.FeatureMap`: has following options. `0` means use 'all' omics or multi-layered data for conversion.
                            '1' means use the 1st layer for conversion (e.g. expression)
                            '2' means use the 2nd layer for conversion (e.g. methylation)
                            '3' means use the 3rd layer for conversion (e.g. mutation)
                            
16.  `Parm.TransLearn`: if '1' then learn CNN from previously trained nets on your different datasets.

17. `Parm.FileRun`

    Change the name as RunX, where X is an integer defining the run of DeepFeature on your data.

    Change the value X for new runs.

18. `Parm.SnowFall` (compression algorithm)

    Suppose SnowFall compression algorithm is used then set the value as 1, otherwise 0. Default is set as 1.

19. `Parm.Threshold` (for Class Activation Maps)

    Set the threshold of class activation maps (CAMs) by changing the value between 0 and 1. If the value is high (towards 1), then the region of activation maps will be very fine. On the other hand, the region will be broader towards value 0. Default is 0.3. 

20. `Parm.DesiredGenes`

    Expected number of genes to be selected. Default is set as 1200. However, change as required.

21. `Parm.UsePrevModel`

    The iterative way runs in multiple stages. If you want to avoid running CNN multiple times then set these values as ‘y’ (yes); i.e., the previous weights of CNN will be used for the current model. This way, the processing time is shorter, however, performance (in terms of selection and accuracy) would be lower. The default setting is ‘n’ (no).

22. `Parm.SaveModels`

    For saving models type ‘y’, otherwise ‘n’. Default is set as yes ‘y’.

23. `Parm.Stage`

    Define the stage of execution. The default value is set as `Parm.Stage=1`. All the results will be saved in RunXStage1. If iterative process is executed then results will be stored in Stage2, Stage3… and so on.


24. `Parm.PATH`

    Default paths for FIGS, Models and Data are `~/DeepInsight3D_pkg/FIGS/`, `~/DeepInsight3D_pkg/Models/` and `~/DeepInsight3D/Data/`, respectively. Runtime parameters will be stored in `~/DeepInsight3D_pkg/` folder (such as model.mat, Out1.mat or Out2.mat).

25. Log and performance file (including an overview of parameter information)

    The runtime results will be stored in `~/DeepFeature/DeepInsight3D_Results.txt` with complete information about the run.

## Related materials

### DeepInsight YouTube

A YouTube video about the original DeepInsight method is available [here](https://www.youtube.com/watch?v=411iwaptk24&feature=youtu.be).
A Matlab page on DeepInsight can be viewed from [here](https://www.mathworks.com/company/user_stories/case-studies/riken-develops-a-method-to-apply-cnn-to-non-image-data.html).

### DeepInsight Paper
Sharma et al., DeepInsight: A methodology to transform a non-image data to an image for convolution neural network architecture, Scientifi Reports, 9(1), 1-7, 2019.

### GitHub weblink of DeepInsight (Python and Matlab)
Overall weblink [here](https://alok-ai-lab.github.io/DeepInsight/)

### DeepFeature Paper
Sharma et al., DeepFeature: feature selection in nonimage data using convolutional neural network, Briefings in Bioinformatics, 22(6), 2021.

### Winning Kaggle competition by Mark Peng
Competition details: Mechanisms of Actions (MoA) Predictions https://www.kaggle.com/competitions/lish-moa

Organizers: MIT and Harvard University (Connectivity Map [here](https://clue.io/))

DeepInsight EfficientNet-B3 Noisy Student [here](https://www.kaggle.com/code/markpeng/deepinsight-efficientnet-b3-noisystudent/notebook)

### Usage of DeepInsight by Subject Area
![alt text](https://github.com/alok-ai-lab/DeepInsight3D/blob/main/Docs_by_Subject.png?raw=true)
#### source: Scopus
