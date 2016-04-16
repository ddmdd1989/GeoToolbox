function ExtShpEP(name,k,code,corx1,cory1,corx2,cory2,veln,vele)
%==========================================================================
%  
%   |===========================================|
%   |**     DIONYSOS SATELLITE OBSERVATORY    **|
%   |**        HIGHER GEODESY LABORATORY      **|
%   |** National Tecnical University of Athens**|
%   |===========================================|
%  
%   filename              : ExtShpEP.m
%                           NAME=ExtShpEP
%   version               : v-1.0
%                           VERSION=v-1.0
%                           RELEASE=beta
%   created               : DEC-2013
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
%Extract shape file
%global input_dir
global output_dir
global outshp

if outshp == 1

%==========================================================================
%PolyLine
%==========================================================================
% Call the new geostruct Tracks and give it a line geometry:
[Vel(1:k).Geometry] = deal('PolyLine');
%Create Tables
for i=1:k
    X(i,1)=corx1(i);
    X(i,2)=corx2(i);
    Y(i,1)=cory1(i);
    Y(i,2)=cory2(i);
end
%create structures
for i=1:k
    Vel(i).code=code(i);
    Vel(i).X=[X(i,1) X(i,2)];
    Vel(i).Y=[Y(i,1) Y(i,2)];
    %write the velocities and corresponding errors in mm on th SHP
    Vel(i).Vnorth=veln(i)*1000;
%    Vel(i).sVn=errn(i)*1000;
    Vel(i).Veast=vele(i)*1000;
%    Vel(i).sVe=erre(i)*1000;
%    Vel(i).Vup=velu(i)*1000;
%    Vel(i).sVu=erru(i)*1000;
    SV=sqrt(veln(i)^2+vele(i)^2);
    Vel(i).Svel=SV*1000;
    
end

shapewrite(Vel,fullfile(output_dir,name));
cirname=sprintf('%s.prj',name);
outname=fullfile(output_dir,cirname);
project=fopen(outname,'w');
fprintf(project,'PROJCS["Greek_Grid",GEOGCS["GCS_GGRS_1987",DATUM["D_GGRS_1987",SPHEROID["GRS_1980",6378137.0,298.257222101]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]],PROJECTION["Transverse_Mercator"],PARAMETER["False_Easting",500000.0],PARAMETER["False_Northing",0.0],PARAMETER["Central_Meridian",24.0],PARAMETER["Scale_Factor",0.9996],PARAMETER["Latitude_Of_Origin",0.0],UNIT["Meter",1.0]]');
fclose all;
disp('Shapefile extracted')

else
disp('shapefile was not created')
end