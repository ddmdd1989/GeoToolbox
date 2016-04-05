function ExtGmtRegion(name,k,code,lat,long)
%==========================================================================
%  
%   |===========================================|
%   |**     DIONYSOS SATELLITE OBSERVATORY    **|
%   |**        HIGHER GEODESY LABORATORY      **|
%   |** National Tecnical University of Athens**|
%   |===========================================|
%  
%   filename              : ExtGmtRegion.m
%                           NAME=ExtGmtRegion
%   version               : v-1.0
%                           VERSION=v-1.0
%                           RELEASE=beta
%   created               : DEC-2015
%   usage                 :
%   exit code(s)          : 0 -> success
%                         : 1 -> error
%   discription           : 
%   uses                  : 
%   notes                 :
%   TODO                  :
%   detailed update list  : LAST_UPDATE=MAR-2016
%   contact               : Demitris Anastasiou (danast@mail.ntua.gr)
%                           Xanthos Papanikolaou (xanthos@mail.ntua.gr)
%==========================================================================
%Extract GMT file to plot velocities
%global input_dir
global output_dir
%  global outname

%  cirname=sprintf('%s.site',outname);
%  gmt_site=fopen(fullfile(output_dir,cirname),'w');
%  for i=1:k
%      fprintf(gmt_site,'%.11f %.11f\n',long(i),lat(i));
%  end

cirname=sprintf('%s.reg',name);
gmt_label=fopen(fullfile(output_dir,cirname),'w');
fprintf(gmt_label,'>region %s\n', name);
for i=1:k
    fprintf(gmt_label,'%.11f %.11f %s\n',long(i),lat(i),code{i});
end
fprintf(gmt_label,'%.11f %.11f %s\n',long(1),lat(1),code{1});



fclose(gmt_label)
disp('GMT file to plot station used')

