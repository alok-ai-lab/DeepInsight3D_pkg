function [zp,Overlap] =assignment(z,type,Size)
% [zp,Overlap] = assignment(z,type,Size);
% 
% Input
% z: nx2 or 2xn coordinates
% type: if z is raw data or representing in Cartesian coordinates then
%        type = 'raw'
% type: if z is representing Pixel Coordinates then
%        type = 'pixel'
%
% Size: is the frame size of Pixel Coordinates such as:
%     Size = 224 for Input Size of 224 x 224 Pixel Coordinates
%
% Output
%  zp: n x 2 flattened Pixel Coordinates
%  if Overlap is called then it will show overlap percentage of elements over pixels
% 


if nargin<2
	type='raw';
	Size=16;
elseif nargin<3
	type='raw';
end

[r1,r2]=size(z);
if r1>= r2
	x1=z(:,1)';
	y1=z(:,2)';
else
	x1=z(1,:);
	y1=z(2,:);
	r1=r2;
end
if strcmp(lower(type),'raw')==1
	A=Size-1;
	x1 = (1+(A*(x1-min(x1))/(max(x1)-min(x1))));
	y1 = (1+(-A)*(y1-max(y1))/(max(y1)-min(y1)));
	%figure;plot(x1,y1,'ob');
	%hold on
	%plot(x1(1),y1(1),'*r');
end

fprintf('\nGrid size is %d x %d\n',Size,Size);

[x0,y0]=meshgrid(1:Size);
x0=x0(:)';
y0=y0(:)';

D = zeros(r1,Size^2);

for j=1:r1
	D(j,:)=vecnorm([x1(j)-x0;y1(j)-y0],2,1)';
end
M=matchpairs(D,r1+1);
%figure
figure
if Size<17
plot(x0,y0,'g*');
end
hold on;
plot(x1,y1,'r*');
xc = [x0(M(:,2)); x1(M(:,1))];
yc = [y0(M(:,2)); y1(M(:,1))];
plot(xc,yc,'-o');
% ######

[rw,col]=sort(M(:,1));
M=M(col,:);
xp=x0(M(:,2));
yp=y0(M(:,2));
zp=[xp',yp'];

if nargout==2
	[c,ia,ic]=unique(zp,'rows');
	%figure; histogram(categorical(ic));
	Overlap = 100*(r1-length(ia))/r1;
end
