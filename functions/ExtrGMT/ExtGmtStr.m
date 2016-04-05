function ExtGmtStr(gmt_plot)
%==========================================================================
%  
%   |===========================================|
%   |**     DIONYSOS SATELLITE OBSERVATORY    **|
%   |**        HIGHER GEODESY LABORATORY      **|
%   |** National Tecnical University of Athens**|
%   |===========================================|
%  
%   filename              : ExtGmtStr.m
%                           NAME=ExtGmtStr
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
%global input_dir
global output_dir
%global param_file
global outname

lat=gmt_plot(:,1);
lon=gmt_plot(:,2);
Kmax=gmt_plot(:,3);
Kmin=gmt_plot(:,5);
Az=gmt_plot(:,7);
s=size(lat);
p=s(1,1);

% for cross strain tensors
ext_name=sprintf('%s.ext',outname);
ext_pth=fullfile(output_dir,ext_name);
comp_name=sprintf('%s.comp',outname);
comp_pth=fullfile(output_dir,comp_name);
ext=fopen(ext_pth,'w');
comp=fopen(comp_pth,'w');
for i=1:p
    if Kmax(i)>=0 && Kmin(i)<=0
        fprintf(ext,'%.5f %.5f %.3f 0 %.3f\n',lon(i), lat(i), Kmax(i), Az(i)+90);
        fprintf(comp,'%.5f %.5f 0 %.3f %.3f\n',lon(i), lat(i),  Kmin(i), Az(i)+90);
    elseif Kmax(i)>=0 && Kmin(i)>0
        fprintf(ext,'%.5f %.5f %.3f %.3f %.3f\n',lon(i), lat(i), Kmax(i), Kmin(i), Az(i)+90);
    elseif Kmax(i) < 0 && Kmin(i) <=0
        fprintf(comp,'%.5f %.5f %.3f %.3f %.3f\n',lon(i), lat(i), Kmax(i), Kmin(i), Az(i)+90);
    end
end

% for ellipse in gmt plots
ell_name=sprintf('%s.ell',outname);
ell_pth=fullfile(output_dir,ell_name);
ell=fopen(ell_pth,'w');
fprintf(ell,'%.5f %.5f %.3f %.3f %.3f\n',lon(i), lat(i), 90-Az(i), 2+10*Kmax(i), 2+10*Kmin(i));

axx_name=sprintf('%s.axx',outname);
axx_pth=fullfile(output_dir,axx_name);
axx=fopen(axx_pth,'w');
fprintf(axx,'%.5f %.5f %.3f %.3f %.3f\n',lon(i), lat(i), 2+10*Kmax(i), 2+10*Kmin(i), Az(i)+90);



disp('Extract GMT plots OK!!!!.....')

