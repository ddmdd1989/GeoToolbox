function ExtShpStrain(name,xcen,ycen,corx,cory,Kmax,Kmin)
%==========================================================================
%  
%   |===========================================|
%   |**     DIONYSOS SATELLITE OBSERVATORY    **|
%   |**        HIGHER GEODESY LABORATORY      **|
%   |** National Tecnical University of Athens**|
%   |===========================================|
%  
%   filename              : ExtShpStrain.m
%                           NAME=ExtShpStrain
%   version               : v-1.0
%                           VERSION=v-1.0
%                           RELEASE=beta
%   created               : DEC-2012
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

disp('Extracting Shapefile ...')
%==========================================================================
%Arrows for Strain Tensor Parameters
%==========================================================================
% Call the new geostruct Tracks and give it a line geometry:
[Str(1:4).Geometry] = deal('PolyLine');
%Create Tables
for i=1:4
    X(i,1)=xcen;
    X(i,2)=corx(i);
    Y(i,1)=ycen;
    Y(i,2)=cory(i);
end
%create structures  ...in progress create different struct for comp & ext
for i=1:4
    if i==1 || i==3
        Str(i).code='ext';
        Str(i).Kmax=Kmax*1000000;
        Str(i).Kmin=0;
        Str(i).X=[X(i,1) X(i,2)];
        Str(i).Y=[Y(i,1) Y(i,2)];
    else
        Str(i).code='comp';
        Str(i).Kmax=0;
        Str(i).Kmin=Kmin*1000000;
        Str(i).X=[X(i,2) X(i,1)];
        Str(i).Y=[Y(i,2) Y(i,1)];
    end
        %Str(i).X=[X(i,1) X(i,2)];
        %Str(i).Y=[Y(i,1) Y(i,2)];
    
    
end

shapewrite(Str,fullfile(output_dir,name));
cirname=sprintf('%s.prj',name);
outname=fullfile(output_dir,cirname);
project=fopen(outname,'w');
fprintf(project,'PROJCS["Greek_Grid",GEOGCS["GCS_GGRS_1987",DATUM["D_GGRS_1987",SPHEROID["GRS_1980",6378137.0,298.257222101]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]],PROJECTION["Transverse_Mercator"],PARAMETER["False_Easting",500000.0],PARAMETER["False_Northing",0.0],PARAMETER["Central_Meridian",24.0],PARAMETER["Scale_Factor",0.9996],PARAMETER["Latitude_Of_Origin",0.0],UNIT["Meter",1.0]]');
%fclose all;
disp('Shapefile extracted')
else
disp('shpaefile was na created')
end