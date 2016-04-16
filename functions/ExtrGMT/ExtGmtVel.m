function ExtGmtVel(name,k,code,lat,long,veln,vele,errn,erre)
%==========================================================================
%  
%   |===========================================|
%   |**     DIONYSOS SATELLITE OBSERVATORY    **|
%   |**        HIGHER GEODESY LABORATORY      **|
%   |** National Tecnical University of Athens**|
%   |===========================================|
%  
%   filename              : ExtGmtVel.m
%                           NAME=ExtGmtVel
%   version               : v-1.0
%                           VERSION=v-1.0
%                           RELEASE=beta
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
%==========================================================================
%Extract GMT file to plot velocities
%global input_dir
global output_dir


cirname=sprintf('%s.vel',name);
gmt_vel=fopen(fullfile(output_dir,cirname),'w');
fprintf(gmt_vel,'Long. Lat. Evel Nvel Esig Nsig CorEN SITE');
for i=1:k
    fprintf(gmt_vel,'\n%.5f %.5f %.2f %.2f %.2f %.2f %.2f %s',long(i),lat(i),vele(i),veln(i),erre(i),errn(i),sqrt(errn(i)^2+erre(i)^2),code{i});
end
fclose all;
disp('GMT file to plot velocities extracted')




