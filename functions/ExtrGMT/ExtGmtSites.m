function ExtGmtSites(name,k,code,lat,long)
%==========================================================================
%  
%   |===========================================|
%   |**     DIONYSOS SATELLITE OBSERVATORY    **|
%   |**        HIGHER GEODESY LABORATORY      **|
%   |** National Tecnical University of Athens**|
%   |===========================================|
%  
%   filename              : ExtGmtSites.m
%                           NAME=ExtGmtSites
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
%  global outname

%  cirname=sprintf('%s.site',outname);
%  gmt_site=fopen(fullfile(output_dir,cirname),'w');
%  for i=1:k
%      fprintf(gmt_site,'%.11f %.11f\n',long(i),lat(i));
%  end

cirname=sprintf('%s.sta',name);
gmt_label=fopen(fullfile(output_dir,cirname),'w');
for i=1:k
    fprintf(gmt_label,'%.11f %.11f  8 0 1 LT %s\n',long(i),lat(i),code{i});
end



fclose(gmt_label)
disp('GMT file to plot station used')

