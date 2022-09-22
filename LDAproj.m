function Y = LDAproj(data,Labels)
% function Y = LDAproj(data,Labels)

J = func_LDA(data,Labels,'element');
t=size(J,1);
%J=kmeans(data,3);
%T = 20; %clusters
N=300;
if t<N
    N=t;
end

range=1:3:N;
L=1:length(range);
clust=zeros(size(J,1),length(range));
for j=L
    clust(:,j)=kmeans(J,range(j),'MaxIter',1000);
end
eva=evalclusters(J,clust,'CalinskiHarabasz');

%eva = evalclusters(J,'kmeans','CalinskiHarabasz','KList',1:3:N);
T = eva.OptimalK;
if t>T
    fprintf('\nt cluster for LDA %d\n',T)
    J = kmeans(data,T);
else
    fprintf('\nt cluster for LDA %d\n',t);
    J = kmeans(data,t);
end
% J=pdist(J);
% J=linkage(J);
% J=cluster(J,'maxclust',3);
Y=func_LDA(data',J,'vector');
Y=Y';

