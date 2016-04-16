%-------------------------------------------------------------------------
%estimation of euler pole 
%-------------------------------------------------------------------------
%GRS80 a=6378137m b=6356752 f=1/298.257222101   e^2=0.006694380023
clc
format compact
format long
re=6378137; 
a=6378137; b=6356752;
file=fopen('outne_w.txt','w');
fprintf(file,'Dionysos Satellite Observatory               %s\n',date);
fprintf(file,'Higher Geodesy Laboratory\n');
fprintf(file,'--------------------------------------------------------\n');
fprintf(file,'Estimation of euler pole and angular velocity\n');
file=fopen('outne_w.txt','a');
%arxeio coord format 'name,f,l'
crd=0;
while crd < 1 
   filename=input('Open file coords in f,l: ', 's');
   [crd,message] = fopen(filename, 'r');
   if crd == -1
      disp(message)
   end
end
cor=textscan(crd,'%s %f %f ','delimiter',',');
code=cor{1};
fe=cor{2}*pi/180;
%ellipsoid to sphere
fs=atan(((b/a)^2)*tan(fe));
l=cor{3}*pi/180;
m=0;k=-1;
crd=fopen(filename, 'r');
while m~=-1
    k=k+1;
    m=fgetl(crd);
    %m=feof(crd);
end
%arxeio velocities format 'name,Vn,Ve,Vu'
vel=0;
while vel < 1 
   filename=input('Open file velocities: ', 's');
   [vel,message] = fopen(filename, 'r');
   if vel == -1
     disp(message)
   end
end
vel=textscan(vel,'%*s %f %f %f','delimiter',',');
veln=vel{1};
vele=vel{2};
fprintf(file,'Number of station velcities introduced: %.0f\n',k);

%matrix v=[vni;vei]
v=[veln(1);vele(1)];
for q=2:k
   v=[v;veln(q);vele(q)];
end
%matrix A
A=re*[sin(l(1)) -cos(l(1)) 0;-sin(fs(1))*cos(l(1)) -sin(fs(1))*sin(l(1)) cos(fs(1))];
for q=2:k
    A1=re*[sin(l(q)) -cos(l(q)) 0;-sin(fs(q))*cos(l(q)) -sin(fs(q))*sin(l(q)) cos(fs(q))];
    A=[A;A1];
end
[w,se_w,mse,S]=lscov(A,v);
%w1=linsolve(A,v)
wr=sqrt((w(1)^2)+(w(2)^2)+(w(3)^2));
sw=sqrt((abs(w(1))*se_w(1)^2+abs(w(2))*se_w(2)^2+abs(w(3))*se_w(3)^2)/wr);
swd=sw*180000000/pi;
wd=wr*180/pi;
wm=wd*1000000;
lr=atan(abs(w(2))/abs(w(1)));
t1=-((se_w(2))^2)/(abs(w(1))*(cos(w(2)/w(1))^2)*(tan(w(2)/w(1))^2));
t2=((se_w(1))^2)*abs(w(2))/((w(1)^2)*(cos(w(2)/w(1))^2)*(tan(w(2)/w(1))^2));
sl=sqrt(t1+t2);
sld=sl*180/pi;
lp=lr*180/pi;
fr=atan(abs(w(3))/sqrt(w(1)^2+w(2)^2));
h1=w(3)/sqrt(w(1)^2+w(2)^2);
h2=(cos(h1))^2*(tan(h1)^2);
w1=h1*w(1)/h2;
w2=h1*w(2)/h2;
w3=-(h1/w(3))/h2;
sf=sqrt(abs(w1*se_w(1)^2+w2*se_w(2)^2+w3*se_w(3)^2));
sfd=sf*180/pi;
%sphere to ellipsoid
fre=atan(tan(fr)/((b/a)^2));
fp=fre*180/pi;



fprintf(file,'\nEstimation of Euler pole \n');
fprintf(file,'\t latitude:  %.3f \t',fp);
fprintf(file,'+-%.3f deg\n',sfd);
fprintf(file,'\t longitude: %.3f \t',lp);
fprintf(file,'+-%.3f deg\n',sld);
fprintf(file,'\nparameter\t\tvalue\tst_er \t\t\tvalue\tst_er\n');
fprintf(file,'\t\t\t\t(deg/My)\t\t\t\t (rad/y)\n');
fprintf(file,'--------------------------------------------------------\n');
fprintf(file,'ang vel w\t\t%.3f',wm);
fprintf(file,'\t %.3f',swd);
fprintf(file,'\t\t%.3e',wr);
fprintf(file,'\t%.3e\n',sw);
fprintf(file,'vel comp wx\t\t%.3f',w(1)*180*1000000/pi);
fprintf(file,'\t%.3f',se_w(1)*180000000/pi);
fprintf(file,'\t\t%.3e',w(1));
fprintf(file,'\t%.3e\n',se_w(1));
fprintf(file,'vel comp wy\t\t%.3f',w(2)*180*1000000/pi);
fprintf(file,'\t%.3f',se_w(2)*180000000/pi);
fprintf(file,'\t\t%.3e',w(2));
fprintf(file,'\t%.3e\n',se_w(2));
fprintf(file,'vel comp wz\t\t%.3f',w(3)*180*1000000/pi);
fprintf(file,'\t%.3f',se_w(3)*180000000/pi);
fprintf(file,'\t\t%.3e',w(3));
fprintf(file,'\t%.3e\n\n',se_w(3));
fprintf(file,'mean sigma: %.3f deg/My',sqrt(mse*180000000/pi));
fprintf(file,'\t%.3e rad/y\n',sqrt(mse));
fprintf(file,'Estimated covariance matrix of w: (rad/y)^2\n');
for q=1:3
    fprintf(file,'%.3e\t %.3e\t %.3e\n',S(1,q),S(2,q),S(3,q));
end


%-------------------------------------------------------------------------
%calculate for the points linear velocities and differences
R=6371000000;

%eisagwgh twn dedomenwn tou polou
fep=atan(((b/a)^2)*tan(fre));
lep=lr;
direction=input('give direction of angular velocity 1:clockwise 2:counderclockwise : ');
if (direction==1)
    wrad=-(wm*pi/180)/1000000;
elseif (direction==2)
    wrad=(wm*pi/180)/1000000;
end
fprintf(file,'\n\t(mm/yr)\t\tinput\t\t\toutput\t\tdifferences\n');
fprintf(file,'   code \t Vn\t\tVe\t\t Vn\t\tVe\t\tdVn\t\tdVe\n');
fprintf(file,'--------------------------------------------------------\n');
resn=0;
rese=0;
for q=1:k

if lep>0
    A=2*pi-lep+l(q);

else
    A=l(q)-lep;
end
fsq=fs(q);

Vn=R*wrad*(sin(A)*cos(fep));
Ve=R*wrad*cos(fsq)*(sin(fep)-tan(fsq)*cos(fep)*cos(A));

%V=sqrt(Vn^2+Ve^2);
%azrad=(pi/2)-atan(Vn/Ve);
%az=azrad*180/pi;

    fprintf(file,'%.0f. ',q);
    fprintf(file,'%s \t',code{q});
    fprintf(file,'% +.1f  \t',veln(q)*1000);
    fprintf(file,'% +.1f\t',vele(q)*1000);
    fprintf(file,'% +.1f\t',Vn);
    fprintf(file,'% +.1f\t',Ve);
    dvn=veln(q)*1000-Vn;
    fprintf(file,'% +.1f\t',dvn);
    dve=vele(q)*1000-Ve;
    fprintf(file,'% +.1f\n',dve);
    
    resn=resn+(Vn-(veln(q)*1000))^2;
    rese=rese+(Ve-(vele(q)*1000))^2;
    
end
s_vn=sqrt(resn/k);
s_ve=sqrt(rese/k);
fprintf(file,'s_vn= %.1f mm/y \n',s_vn);
fprintf(file,'s_ve= %.1f mm/y ',s_ve);
fclose all;




