function func_SaveFigs(Parm)

% Save all open figures

FileRun = Parm.FileRun;
Stages = Parm.Stage;
Ask = Parm.SaveModels;

if strcmp(Parm.PATH{1}(end),'/')==0
    Parm.PATH{1} = [Parm.PATH{1},'/'];
end
if strcmp(Parm.PATH{2}(end),'/')==0
    Parm.PATH{2} = [Parm.PATH{2},'/'];
end

FigList = findobj(allchild(0),'flat','Type','figure');
if length(FigList) ==0
    disp('No active figures');
    disp('Nothing to be saved!!!');
else

if strcmp(lower(Ask),'y')==1
    Directory = [Parm.PATH{1},FileRun,'/Stage',num2str(Stages),'/'];
    if isfolder(Directory(1:end-8))==0
        unix(['mkdir ',Directory(1:end-8)]);
    end
    if isfolder(Directory)==0
        unix(['mkdir ',Directory(1:end-1)]);
    end
    
    for j=1:length(FigList)
        FigName = get(FigList(j),'Name');
        if isempty(FigName)==1;
            FigName = ['Figure',num2str(j)];
        end
        savefig(FigList(j), fullfile(Directory,[FigName '.fig']));
    end
    disp('Figures Saved in the FIGS folder...');
end
end