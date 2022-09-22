function J = func_LDA(data,Labels,method)
% J = func_LDA(data,Labels,method)
% method = 'element' will perform element wise LDA; i.e. 1-dimensional lda
%        = 'vector' will perform the usual LDA; i.e. using a vector
%        (d-dimensional lda)

typ=isa(Labels,'categorical');
if typ==1
    Labels=double(Labels);
end
[n_genes,no_samples] = size(data); 
class = numel(unique(Labels));
mu = mean(data')';
m = zeros(n_genes,class);
for j=1:class
   m(:,j)=mean(data(:,find(Labels==j))')';	
end

if strcmp(lower(method),'element')==1
    sb=zeros(n_genes,1);
    for j=1:class
        sb=sb+numel(find(Labels==j))*((mu-m(:,j)).^2);	
    end
    sw=zeros(n_genes,1);
    for j=1:class
        sw=sw+sum(((data(:,find(Labels==j))-m(:,j))').^2)';	
    end
    J = sb./sw;
elseif strcmp(lower(method),'vector')==1
    d=n_genes;
    n=no_samples;
    if d>n-1
        Hb=[]; Hw=[];
        for j=1:class
            Hb=[Hb,sqrt(numel(find(Labels==j)))*(mu-m(:,j))];
            Hw=[Hw,data(:,find(Labels==j))-m(:,j)];
        end
        [Uw,Dw]=svd(Hw,0);
        [Ub,Db]=svd(Hb,0);
        rw=rank(Dw);
        Dw=Dw(1:rw,1:rw);
        Uw=Uw(:,1:rw);
        rb=rank(Db);
        Ub=Ub(:,1:rb);
        Db=Db(1:rb,1:rb);
        [F,Sig]=svd(inv(Dw)*Uw'*Hb,0);
        %rsig=rank(Sig);
        Sig=Sig(1:2,1:2);
        F=F(:,1:2);
        W=Uw*inv(Dw)*F*inv(Sig);
        J = W'*data;
    else
        Sb=zeros(d,d);
        Sw=zeros(d,d);
        for j=1:class
            Sb=Sb+numel(find(Labels==j))*(mu-m(:,j))*(mu-m(:,j))';
            Sw=Sw+(data(:,find(Labels==j))-m(:,j))*(data(:,find(Labels==j))-m(:,j))';
        end
        if rank(Sw)<size(Sw,1)
            [W,D]=svd(pinv(Sw)*Sb,0);
        else
            [W,D]=svd(inv(Sw)*Sb,0);
        end
        W=W(:,1:2);
        J=W'*data;
    end

end