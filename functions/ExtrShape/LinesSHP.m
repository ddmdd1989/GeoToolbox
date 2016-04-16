function LinesSHP(file)
%==========================================================================
%  
%   |===========================================|
%   |**     DIONYSOS SATELLITE OBSERVATORY    **|
%   |**        HIGHER GEODESY LABORATORY      **|
%   |** National Tecnical University of Athens**|
%   |===========================================|
%  
%   filename              : LinesSHP.m
%                           NAME=LinesSHP
%   version               : v-0.1
%                           VERSION=v-0.1
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





%Extract shape file
%global input_dir
%global output_dir
global outshp
if outshp == 1
fid=fopen(file,'r');
cor=textscan(fid,'%f %f %f %f %f %f %f %f %f %f');
lat1=cor{2};
lat2=cor{4};
long1=cor{1};
long2=cor{3};
dip=cor{5};
depth=cor{6};
SS=cor{7};
sigSS=cor{8};
NS=cor{9};
sigNS=cor{10};
s=size(lat1);
k=s(1,1);
[corx1,cory1]=wgs2ggrs(lat1,long1);
[corx2,cory2]=wgs2ggrs(lat2,long2);

%==========================================================================
%PolyLine
%==========================================================================
% Call the new geostruct Tracks and give it a line geometry:
[Reg(1:k).Geometry] = deal('PolyLine');
%Create Tables
for i=1:k
    X(i,1)=corx1(i);
    X(i,2)=corx2(i);
    Y(i,1)=cory1(i);
    Y(i,2)=cory2(i);

end
%create structures
for i=1:k
    Reg(i).code=i;
    Reg(i).X=[X(i,1) X(i,2)];
    Reg(i).Y=[Y(i,1) Y(i,2)];
    Reg(i).Lat1=lat1(i);
    Reg(i).Long1=long1(i);
    Reg(i).Lat2=lat2(i);
    Reg(i).Long2=long2(i);
    Reg(i).Dip=dip(i);
    Reg(i).Depth=depth(i);
    Reg(i).SS=SS(i);
    Reg(i).sigSS=sigSS(i);
    Reg(i).NS=NS(i);
    Reg(i).sigNS=sigNS(i);
    
end

shapewrite(Reg,'regions');
% cirname=sprintf('%s.prj',name);
% outname=fullfile(output_dir,cirname);
project=fopen('regions.prj','w');
fprintf(project,'PROJCS["Greek_Grid",GEOGCS["GCS_GGRS_1987",DATUM["D_GGRS_1987",SPHEROID["GRS_1980",6378137.0,298.257222101]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]],PROJECTION["Transverse_Mercator"],PARAMETER["False_Easting",500000.0],PARAMETER["False_Northing",0.0],PARAMETER["Central_Meridian",24.0],PARAMETER["Scale_Factor",0.9996],PARAMETER["Latitude_Of_Origin",0.0],UNIT["Meter",1.0]]');
fclose all;
disp('Shapefile extracted')
else
disp('shapefile was not created')
end





