function [corx1,cory1]=wgs2ggrs(lat,long)
%==========================================================================
%  
%   |===========================================|
%   |**     DIONYSOS SATELLITE OBSERVATORY    **|
%   |**        HIGHER GEODESY LABORATORY      **|
%   |** National Tecnical University of Athens**|
%   |===========================================|
%  
%   filename              : wgs2ggrs.m
%                             NAME=wgs2ggrs
%   version               : v-1.0
%                             VERSION=v-1.0
%                             RELEASE=beta
%   created               : DEC-2014
%   usage                 :
%   exit code(s)          : 0 -> success
%                         : 1 -> error
%   discription           : 
%   uses                  : 
%   notes                 :
%   TODO                  :
%   detailed update list  : LAST_UPDATE=JAN-2016
%   contact               : Demitris Anastasiou (danast@mail.ntua.gr)
%                           Xanthos Papanikolaou (xanthos@mail.ntua.gr)
%==========================================================================% Trasformation from Geodetic to projection Coordinates
% elliposid Bessel: a=6377397.155 e1=0.006674372 e2=0.006719219 -for Old datum (GR DATUM)
% elliposid Hayford: a=6377388.000 e1=0.0066722670 e2=0.006768170- for ED50
% elliposid GRS80: a=6378137.000 e1=0.006694380 e2=0.006739497- for EGSA87
% ellipsoid WGS84: a=6378137.000 e1=0.00669437999 e2=0.006739497
%*******************************************************************************************
% global input_dir
% global output_dir
clc
%clear all
    a = 6378137.000;
    b = 6356752.314245;
    e2=((((a^2)-(b^2))^0.5)/b)^2;
    e1=0.006694380;
    %e2=0.006739497;

% %Put the geodetic coordinates of the point: latitude,longitude
% crd=0;
% while crd < 1 
%    dir(input_dir)
%    filename=input('Open file coords in WGS84 (P,LAT,LONG): ', 's');
%    [crd,message] = fopen(fullfile(input_dir,filename), 'r');
%    if crd == -1
%      disp(message)
%    end
% end
% cor=textscan(crd,'%s %f %f','delimiter',',');
LLA=[lat long];
LLA(:,3)=0;
XYZ=lla2ecef(LLA);
XYZ=[XYZ(:,1)+199.87 XYZ(:,2)-74.79 XYZ(:,3)-246.62];
D=ecef2lla(XYZ);
%D=[lat long];
pp=size(D);
n=pp(1);


for i=1:n
Rad_f(i)=D(i,1)*pi/180;
Rad_lon(i)=D(i,2)*pi/180;
end
Rad_f=Rad_f';
Rad_lon=Rad_lon';
for i=1:n
    W(i)=1/(sqrt(1-e1*(sin(Rad_f(i))^2)));
end
W=W';
for i=1:n
    N(i)=a*W(i);
end
N=N';
%finding projection coordinates in TM %
    m0=0.9996;
    l0=24*pi/180;

    % finding Sf %
Sf=zeros(n,1);
    m0=0.9996;
   for i=1:n
       Sf(i)=6367408.748*(1.000006345*Rad_f(i)-(0.0025188441)*sin(2*Rad_f(i))+((0.0000052871167)/2)*sin(4*Rad_f(i))-((0.000000010357890)/3)*sin(6*Rad_f(i)));
   end

for i=1:n
    t(i)=tan(Rad_f(i));
    h2(i)=e2*((cos(Rad_f(i)))^2);
    dl(i)=Rad_lon(i)-l0;
end

t=t';
h2=h2';
dl=dl';

% approximate projection's coordinates %
Northing=ones(n,1);

for i=1:n
    Northing(i)=m0*Sf(i)+m0*N(i)*(((dl(i)^2)/2)*sin(Rad_f(i))*cos(Rad_f(i))+(((dl(i)^4)/24)*sin(Rad_f(i))*((cos(Rad_f(i)))^3))*(5-(t(i)^2)+9*h2(i)+4*(h2(i)^2)))+((dl(i)^6)/720)*sin(Rad_f(i))*((cos(Rad_f(i))^5))*(61-58*(t(i)^2)+(t(i)^4)+270*h2(i)-(330*(t(i)^2)*h2(i))+(445*(h2(i)^2))+(324*(h2(i)^3))-(680*(t(i)^2)*(h2(i)^2))+(88*(h2(i)^4))-(600*(t(i)^2)*(h2(i)^3))-(192*(t(i)^2)*(h2(i)^4)))+(((dl(i)^8)/40320)*sin(Rad_f(i))*((cos(Rad_f(i))^7))*(1385-(3111*(t(i))^2)+(543*(t(i)^4))-(t(i)^6)));
end

for i=1:n
    Easting(i)=m0*N(i)*(dl(i)*cos(Rad_f(i))+(((dl(i)^3)*(cos(Rad_f(i))^3))/6)*(1-(t(i)^2)+h2(i))+(((dl(i)^5)*(cos(Rad_f(i))^5))/120)*(5-18*(t(i)^2)+(t(i)^4)+14*h2(i)-58*(t(i)^2)*h2(i)+(13*h2(i)^2)+4*(h2(i)^3)-64*((t(i)*h2(i))^2)-24*(t(i)^2)*(h2(i)^3))+(((dl(i)^7)*(cos(Rad_f(i))^7))/5040)*(61-479*(t(i)^2)+179*(t(i)^4)-(t(i)^6)));
end

Easting=Easting'+500000;
cory1=Northing;
corx1=Easting;

% %final coordinates%
% %TM=[Easting Northing]
% fprintf(out,'CODE \t\t X(m) \t\t Y(m)\n');
% fprintf(out,'---------------------------------------------\n');
% %dlmwrite('outCOORD.txt',TM,'precision','%.4f','delimiter','\t');
% for i=1:n
%     fprintf(out,'%s\t %.4f\t %.4f\n',name{i},Easting(i),Northing(i));
% end
% disp('transfer completed! Look for output file "outCOORDS.txt"')
% fclose all;








