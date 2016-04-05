function ExtShpPoint(name,np,code,X,Y,veln,vele,resn,rese)
%==========================================================================
%  
%   |===========================================|
%   |**     DIONYSOS SATELLITE OBSERVATORY    **|
%   |**        HIGHER GEODESY LABORATORY      **|
%   |** National Tecnical University of Athens**|
%   |===========================================|
%  
%   filename              : ExtShpPoint.m
%                           NAME=ExtShpPoint
%   version               : v-1.0
%                           VERSION=v-1.0
%                           RELEASE=beta
%   created               : OCT-2010
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
global output_dir
global outshp

if outshp == 1

[Sta(1:np).Geometry] = deal('Point');

for i=1:np
    Sta(i).code = code{i};
    Sta(i).X = X(i);
    Sta(i).Y = Y(i);
    Sta(i).East = X(i);
    Sta(i).North = Y(i);
    Sta(i).Vn = veln(i)*1000;
    Sta(i).Ve = vele(i)*1000;
    Sta(i).Resn = resn(i)*1000;
    Sta(i).Rese = rese(i)*1000;
   
end

shapewrite(Sta,fullfile(output_dir,name));
cirname=sprintf('%s.prj',name);
outname=fullfile(output_dir,cirname);
project=fopen(outname,'w');
%fprintf(project,'GEOGCS["GCS_WGS_1984",DATUM["D_WGS_1984",SPHEROID["WGS_1984",6378137.0,298.257223563]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]]');
fprintf(project,'PROJCS["Greek_Grid",GEOGCS["GCS_GGRS_1987",DATUM["D_GGRS_1987",SPHEROID["GRS_1980",6378137.0,298.257222101]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]],PROJECTION["Transverse_Mercator"],PARAMETER["False_Easting",500000.0],PARAMETER["False_Northing",0.0],PARAMETER["Central_Meridian",24.0],PARAMETER["Scale_Factor",0.9996],PARAMETER["Latitude_Of_Origin",0.0],UNIT["Meter",1.0]]');
%fclose all;
disp('Shapefile extracted')

else
disp('shapefile was not created')
end