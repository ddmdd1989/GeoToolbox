function ExtShpEPole(lat1,long1,w)
%==========================================================================
%  
%   |===========================================|
%   |**     DIONYSOS SATELLITE OBSERVATORY    **|
%   |**        HIGHER GEODESY LABORATORY      **|
%   |** National Tecnical University of Athens**|
%   |===========================================|
%  
%   filename              : ExtShpEPole.m
%                           NAME=ExtShpEPole
%   version               : v-0.5
%                           VERSION=v-0.5
%                           RELEASE=beta
%   created               : DEC-2012
%   usage                 :
%   exit code(s)          : 0 -> success
%                         : 1 -> error
%   discription           : 
%   uses                  : 
%   notes                 :
%   TODO                  :
%   detailed update list  : LAST_UPDATE=JAN-2015
%   contact               : Demitris Anastasiou (danast@mail.ntua.gr)
%                           Xanthos Papanikolaou (xanthos@mail.ntua.gr)
%==========================================================================
%Extract shape file
%global input_dir
global output_dir
global outshp

if outshp == 1
%==========================================================================
%Point
%==========================================================================
% Call the new geostruct Tracks and give it a line geometry:
[EulP(1).Geometry] = deal('Point');

    EulP(1).code='EulerPole';
    EulP(1).Lat=lat1;
    EulP(1).Lon=long1;
    EulP(1).latitude=lat1;
    EulP(1).Longtitude=long1;
    %write the velocities and corresponding errors in mm on th SHP
%    Vel(i).Vnorth=veln(i)*1000;
%    Vel(i).sVn=errn(i)*1000;
%    Vel(i).Veast=vele(i)*1000;
%    Vel(i).sVe=erre(i)*1000;
%    Vel(i).Vup=velu(i)*1000;
%    Vel(i).sVu=erru(i)*1000;
 %   SV=sqrt(veln(i)^2+vele(i)^2);
%    Vel(i).Svel=SV*1000;
    EulP(1).w=w;

name='EulP_pot';
shapewrite(EulP,fullfile(output_dir,name));
cirname=sprintf('%s.prj',name);
outname=fullfile(output_dir,cirname);
project=fopen(outname,'w');
fprintf(project,'GEOGCS["GCS_WGS_1984",DATUM["D_WGS_1984",SPHEROID["WGS_1984",6378137.0,298.257223563]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]]');
fclose all;
disp('Shapefile extracted')


else
disp('shapefile was not created')
end