%CALCULATE STRAIN TENSOR PARAMETERS
clc
format compact
format long
clear('all');
%--------------------------------------------------------------------------
%input file format 'code,x,y,vn,ve'
inp=0;
while inp < 1 
   filename=input('Open file parameters: ', 's');
   [inp,message] = fopen(filename, 'r');
   if inp == -1
     disp(message)
   end
end
inpt=textscan(inp,'%s %f %f %f %f %*f','delimiter',',');
code=inpt{1};
x1=inpt{2};
y1=inpt{3};
vn=inpt{4};
ve=inpt{5};
m=0;k=-1;
inp=fopen(filename, 'r');
while m~=-1
    k=k+1;
    m=fgetl(inp);
end
np=k; %network points
%--------------------------------------------------------------------------
%TRANSFORMATION WITH SIX PARAMETERS
xcen=0;
ycen=0;
for i=1:k
    xcen=xcen+x1(i);
    ycen=ycen+y1(i);
end
xcen=xcen/k;
ycen=ycen/k;
x2=x1-xcen;
y2=y1-ycen;
for i=1:k
    VelneMat(i,1)=ve(i);
    VelneMat(np+i,1)=vn(i);
end
%make the observation matrix
for i=1:k
    ObsMat(1,i)=1;
    ObsMat(2,i)=0;
    ObsMat(3,i)=x2(i);
    ObsMat(4,i)=y2(i);
    ObsMat(5,i)=0;
    ObsMat(6,i)=0;
    ObsMat(1,np+i)=0;
    ObsMat(2,np+i)=1;
    ObsMat(3,np+i)=0;
    ObsMat(4,np+i)=0;
    ObsMat(5,np+i)=x2(i);
    ObsMat(6,np+i)=y2(i);
end
ObsMatTrn=ObsMat';
%E=[Ex Ey Exx Exy Eyx Eyy]
%E = inv(A'*inv(V)*A)*A'*inv(V)*B
%mse = B'*(inv(V) - inv(V)*A*inv(A'*inv(V)*A)*A'*inv(V))*B./(m-n)
%S = inv(A'*inv(V)*A)*mse
%stdE = sqrt(diag(S))
[E,stdE,mse,S] = lscov(ObsMatTrn,VelneMat);
StanDev=sqrt(mse);
Sx=E(1);
SxVar=stdE(1);
Sy=E(2);
SyVar=stdE(2);
ExxPyy=E(3)+E(6);
ExxMyy=E(3)-E(6);
ExyPyx=E(4)+E(5);
ExyMyx=E(4)-E(5);
Kx=E(3);
Ky=E(6);
KxVar=stdE(3);
KyVar=stdE(6);
Ex=-E(5);
Ey=E(4);
ExVar=stdE(5);
EyVar=stdE(4);
ETotal=ExyMyx/2;
ETotalVar=0.5 * sqrt( S(5,5) + S(4,4));
KDummy = ExxMyy^2 + ExyPyx^2;
KDummy1 = 0.5 * (ExxPyy + sqrt(KDummy));
KDummy2 = 0.5 * (ExxPyy - sqrt(KDummy));
KDumVar = ExxMyy^2 / (4 * KDummy);
KDumVar1 = 0.25 * (1 + ExxMyy / sqrt(KDummy)) ^ 2;
KDumVar2 = 0.25 * (1 - ExxMyy / sqrt(KDummy)) ^ 2;
if KDummy1 >= KDummy2
        Kmax = KDummy1;
        Kmin = KDummy2;
        KmaxVar = sqrt(KDumVar1 * KxVar ^ 2 + KDumVar2 * KyVar ^ 2 + KDumVar * (ExVar ^ 2 + EyVar ^ 2));
        KminVar = sqrt(KDumVar2 * KxVar ^ 2 + KDumVar1 * KyVar ^ 2 + KDumVar * (ExVar ^ 2 + EyVar ^ 2));
else
        Kmax = KDummy2;
        Kmin = KDummy1;
        KmaxVar = SQR(KDumVar2 * KxVar ^ 2 + KDumVar1 * KyVar ^ 2 + KDumVar * (ExVar ^ 2 + EyVar ^ 2));
        KminVar = SQR(KDumVar1 * KxVar ^ 2 + KDumVar2 * KyVar ^ 2 + KDumVar * (ExVar ^ 2 + EyVar ^ 2));
end
KMean = ExxPyy / 2;
KMeanVar = 0.5 * sqrt(S(3, 3) + S(6, 6));
Az = 0.5 * (atan(ExyPyx / -ExxMyy));
Az = Az * 180/pi;
if ExxMyy > 0 
    Az = Az + 90;
end
AzVar = 0.5 * sqrt((S(3,3)+S(6,6))*ExyPyx^2 + (S(4,4)+S(5,5)) * ExxMyy^2) / (ExyPyx^2 + ExxMyy^2);
AzVar = AzVar * 180/pi;
Gmax = sqrt(ExxMyy ^ 2 + ExyPyx ^ 2);
GmaxVar = sqrt(KmaxVar ^ 2 + KminVar ^ 2);
%--------------------------------------------------------------------------
%print output file of strain tensor parameters
parfile=fopen('str_par.txt','w');
fprintf(parfile,'NATIONAL TECHNICAL UNIVARSITY OF ATHENS\n');
fprintf(parfile,'DIONYSOS SATELLITE OBSERVATORY\n');
fprintf(parfile,'*******************************************\n');
fprintf(parfile,'NETWORK POINTS USED : %.0f\n',np);
fprintf(parfile,'BLOCK CENTER s COORDINATES :  %.3f m\n',xcen);
fprintf(parfile,'                             %.3f m\n',ycen);
fprintf(parfile,'*******************************************\n');
fprintf(parfile,'A POSTERIORI STANDARD DEVIATION : %.2f mm\n\n',StanDev*1000);
fprintf(parfile,'Deformation Parameters\n');
fprintf(parfile,'***********************\n\n');
fprintf(parfile,'Shift :     Sx= %+.2f \t+- %.2f mm\n',Sx*1000,SxVar*1000);
fprintf(parfile,'            Sy= %+.2f \t+- %.2f mm\n\n',Sy*1000,SyVar*1000);
fprintf(parfile,'Rotation :  Ex= %+.3f \t+- %.3f ppm\n',Ex*1000000,ExVar*1000000);
fprintf(parfile,'            Ey= %+.3f \t+- %.3f ppm\n\n',Ey*1000000,EyVar*1000000);
fprintf(parfile,'Total Rot:   E= %+.3f \t+- %.3f ppm\n\n',ETotal*1000000,ETotalVar*1000000);
fprintf(parfile,'Scale :     Kx= %+.3f \t+- %.3f ppm\n',Kx*1000000,KxVar*1000000);
fprintf(parfile,'            Ky= %+.3f \t+- %.3f ppm\n\n',Ky*1000000,KyVar*1000000);
fprintf(parfile,'          Kmax= %+.3f \t+- %.3f ppm\n',Kmax*1000000,KmaxVar*1000000);
fprintf(parfile,'          Kmin= %+.3f \t+- %.3f ppm\n\n\n',Kmin*1000000,KminVar*1000000);
fprintf(parfile,'Mean Scale : K= %+.3f \t+- %.3f ppm\n\n',KMean*1000000,KMeanVar*1000000);
fprintf(parfile,'Azimouth : Az= %+.3f \t+- %.3f deg\n\n',Az,AzVar);
fprintf(parfile,'Strain : ã max= %+.3f \t+- %.3f ppm\n\n',Gmax*1000000,GmaxVar*1000000);
fprintf(parfile,'*******************************************\n');
fprintf(parfile,'NETWORK POINTS USED TO CALCULATE STRAIN TENSOR\n');
for i=1:np
    fprintf(parfile,'%s\n',code{i});
end

fclose all;
%--------------------------------------------------------------------------
%print output file for gis stainn tensor
sc=input('scale factor: ');
r=1;
a=1+Kmax*1000000;
b=1+Kmin*1000000;
f=(90-Az)*pi/180;
%--------------------------------------------------------------------------
%circle
    cfile=fopen('cir.txt','w');
    fprintf(cfile,'polygon\n');
    cfile=fopen('cir.txt','a');
    fprintf(cfile,'0 0\n');
    q=0;
    for t=0.0: 0.01: 2*pi
        xcir=xcen+r*cos(t)*sc;
        ycir=ycen+r*sin(t)*sc;
        fprintf(cfile,'%.0f',q);
        fprintf(cfile,'% .3f',xcir);
        fprintf(cfile,'% .3f 1.#QNAN 1.#QNAN\n',ycir);
        q=q+1;
    end
    fprintf(cfile,'END');
%--------------------------------------------------------------------------
%ellipses
    efile=fopen('ell.txt','w');
    fprintf(efile,'polygon\n');
    efile=fopen('ell.txt','a');
    fprintf(efile,'0 0\n');
    q=0;
        for t=0.0: 0.01: 2*pi
            errx=xcen+a*cos(t)*cos(f)*sc-b*sin(t)*sin(f)*sc;
            erry=ycen+a*cos(t)*sin(f)*sc+b*sin(t)*cos(f)*sc;
            fprintf(efile,'%.0f',q);
            fprintf(efile,'% .3f',errx);
            fprintf(efile,'% .3f 1.#QNAN 1.#QNAN\n',erry);
            q=q+1;
        end    
    fprintf(efile,'END');
fclose all;
%--------------------------------------------------------------------------
%axes of ellipses
afile=fopen('axx.txt','w');
fprintf(afile,'polyline\n');
afile=fopen('axx.txt','a');
q=0;
for t=0: pi/2: 3*pi/2
    fprintf(afile,'%.0f 0\n',q);
    errx=xcen+a*cos(t)*cos(f)*sc-b*sin(t)*sin(f)*sc;
    erry=ycen+a*cos(t)*sin(f)*sc+b*sin(t)*cos(f)*sc;
    fprintf(afile,'0 %.3f',xcen);
    fprintf(afile,'% .3f 0.0 0.0\n',ycen);
    fprintf(afile,'0 %.3f',errx);
    fprintf(afile,'% .3f 0.0 0.0\n',erry);
    q=q+1;
end
fprintf(afile,'END');
fclose all;















 
    
    