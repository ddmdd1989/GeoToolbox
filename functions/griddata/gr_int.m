%--------------------------------------------------------------------------
%griddata:: make grid from data
%--------------------------------------------------------------------------
clc
format compact
format long
clear('all');
% %--------------------------------------------------------------------------
% %arxeio coord format 'name,x,y'
% crd=0;
% while crd < 1 
%    filename=input('Open file coords: ', 's');
%    [crd,message] = fopen(filename, 'r');
%    if crd == -1
%      disp(message)
%    end
% end
% 
% cor=textscan(crd,'%*s %f %f ','delimiter',',');
% x=cor{1};
% y=cor{2};
% m=0;k=-1;
% crd=fopen(filename, 'r');
% while m~=-1
%     k=k+1;
%     m=fgetl(crd);
%     %m=feof(crd);
% end

%--------------------------------------------------------------------------
%Input File format 'name,x,y,Vn,Ve,Vu'
%--------------------------------------------------------------------------
disp('Compute Grid from data interpolation');
inp=0;
while inp < 1 
   filename=input('Open Input file: ', 's');
   [inp,message] = fopen(filename, 'r');
   if inp == -1
     disp(message)
   end
end
inp=textscan(inp,'%*s %f %f %f %f %f','delimiter',',');
x=inp{1};
y=inp{2};
n=inp{3};
e=inp{4};
u=inp{5};
m=0;k=-1;
inp=fopen(filename, 'r');
while m~=-1
    k=k+1;
    m=fgetl(inp);
    %m=feof(crd);
end
%--------------------------------------------------------------------------
%make the grid for the data
% xmin=input('input xmin for the grid: ');
% xmax=input('input xmax for the grid: ');    
% xstep=input('input the step of the grid for x: ');
% ymin=input('input ymin for the grid: ');
% ymax=input('input ymax for the grid: ');
% ystep=input('input the step of the grid for y: ');
% xi=xmin:xstep:xmax;
% yi=ymin:ystep:ymax;
% yi=yi';
%--------------------------------------------------------------------------
%find the grid
xmin=1000000;
xmax=0;
ymin=10000000;
ymax=0;
for i=1:k
    if x(i)<xmin
        xmin=x(i);
    end
    if x(i)>xmax
        xmax=x(i);
    end
    if y(i)<ymin
        ymin=y(i);
    end
    if y(i)>ymax
        ymax=y(i);
    end
end
xstep=input('input the step of the grid for x: ');
ystep=input('input the step of the grid for y: ');
xi=xmin:xstep:xmax;
yi=ymin:ystep:ymax;
yi=yi';
%--------------------------------------------------------------------------
%grid the data
%velocities in NS
zn=griddata(x,y,n,xi,yi,'cubic');
%velocities in EW
ze=griddata(x,y,e,xi,yi,'cubic');
%velocities in up
zu=griddata(x,y,u,xi,yi,'cubic');
%plot the valuew of the points
subplot(2,2,1);
plot3(x,y,n,'o'),hold on;
surfc(xi,yi,zn,'FaceColor','interp',...
	'EdgeColor','none',...
	'FaceLighting','phong');
axis on; grid on; title('Vnorth'); colorbar;view(2);
subplot(2,2,2);
plot3(x,y,e,'o'),hold on;
surfc(xi,yi,ze,'FaceColor','interp',...
	'EdgeColor','none',...
	'FaceLighting','phong');
axis on; grid on; title('Veast'); colorbar;view(2);
subplot(2,2,3);
plot3(x,y,u,'o'),hold on;
surfc(xi,yi,zu,'FaceColor','interp',...
	'EdgeColor','none',...
	'FaceLighting','phong');
axis on; grid on; title('Vup'); colorbar;view(2);
%--------------------------------------------------------------------------
%calculate and write velocitiews for plotting
%scale factor
sc=input('scale factor: ');
output=input('dwse to onoma tou output arxeiou for horizontal velocities: ', 's');
hfile=fopen(output,'w');
cfile=fopen('inp_dat.txt','w');
fprintf(hfile,'polyline\n');
hfile=fopen(output,'a');

jfin=fix((xmax-xmin)/xstep);
ifin=fix((ymax-ymin)/ystep);
q=0;
for i=1:(ifin+1)
    for j=1:(jfin+1) 
        sz(i,j)=ze(i,j);
        if ze(i,j)<=0
        q=q+1;
        x2=xi(j)+ze(i,j)*sc;
        y2=yi(i)+zn(i,j)*sc;
        s=sqrt(ze(i,j)^2+zn(i,j)^2);
        if s<0.01
            sq=1;
        elseif s>=0.01 && s<0.02
            sq=2;
        elseif s>=0.02 && s<3
            sq=3;
        elseif s>=3
            sq=4;
        end
        fprintf(hfile,'%1.0f 0\n',sq);
        fprintf(hfile,'0 %.3f',xi(j));
        fprintf(hfile,'% .3f 0.0 0.0\n',yi(i));
        fprintf(hfile,'1 %.3f',x2);
        fprintf(hfile,'% .3f 0.0 0.0\n',y2);
        sz(i,j)=sqrt(ze(i,j)^2+zn(i,j)^2);
            %output file for grid coords format 'code,x,y,vn,ve'
            fprintf(cfile,'%.0f,',q);
            fprintf(cfile,'%.3f,',xi(j));
            fprintf(cfile,'%.3f,',yi(i));
            fprintf(cfile,'%.4f,',zn(i,j));
            fprintf(cfile,'%.4f\n',ze(i,j));
        elseif ze(i,j)>0
            q=q+1;
        x2=xi(j)+ze(i,j)*sc;
        y2=yi(i)+zn(i,j)*sc;
        s=sqrt(ze(i,j)^2+zn(i,j)^2);
        if s<0.01
            sq=1;
        elseif s>=0.01 && s<0.02
            sq=2;
        elseif s>=0.02 && s<3
            sq=3;
        elseif s>=3
            sq=4;
        end
        fprintf(hfile,'%1.0f 0\n',sq);
        fprintf(hfile,'0 %.3f',xi(j));
        fprintf(hfile,'% .3f 0.0 0.0\n',yi(i));
        fprintf(hfile,'1 %.3f',x2);
        fprintf(hfile,'% .3f 0.0 0.0\n',y2);
        sz(i,j)=sqrt(ze(i,j)^2+zn(i,j)^2);
            %output file for grid coords format 'code,x,y'
            fprintf(cfile,'%.0f,',q);
            fprintf(cfile,'%.3f,',xi(j));
            fprintf(cfile,'%.3f,',yi(i));
            fprintf(cfile,'%.4f,',zn(i,j));
            fprintf(cfile,'%.4f\n',ze(i,j));
        end
        
    end
end
subplot(2,2,4);
surfc(xi,yi,sz,'FaceColor','interp',...
	'EdgeColor','none',...
	'FaceLighting','phong');
axis on; grid on; title('SV in horizontal comp'); colorbar;view(2);
fprintf(hfile,'END');
fclose all;






















