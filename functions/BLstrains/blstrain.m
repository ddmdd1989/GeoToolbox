function blstrain
%==========================================================================
%  
%   |===========================================|
%   |**     DIONYSOS SATELLITE OBSERVATORY    **|
%   |**        HIGHER GEODESY LABORATORY      **|
%   |** National Tecnical University of Athens**|
%   |===========================================|
%  
%   filename              : blstrain.m
%                           NAME=blstrain
%   version               : v-1.0
%                           VERSION=v-1.0
%                           RELEASE=beta
%   created               : OCT-2015
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

%--------------------------------------------------------------------------
%change topocentric system for the velocities
% | Vy1i | = | cosa*cosa  cosa*sina |   | Vni |
% | Vx2i | = | sina*cosa  sina*sina | * | Vei |

% a: direction angle -90 < a < 90
%--------------------------------------------------------------------------

global input_dir
global output_dir
global param_file
global outname
clc
%clear all
format compact
format long

fprintf(param_file,'\n****************\tBaselines strain rates\t******************\n\n');

%--------------------------------------------------------------------------
% Read input file INPUT FILE: code,lat,long, up ,vn,svn,ve,sve,vu,svu
%--------------------------------------------------------------------------
crd=0;
dir (input_dir)
while crd < 1 
   filename=input('Open Input File: ', 's');
   [crd,message] = fopen(filename, 'r');
   if crd == -1
     disp(message)
   end
end
fprintf(param_file,'Input file : %s\n',filename);
cor=textscan(crd,'%s %f  %f %f %f %f %f %f %f %f','delimiter',',');
%cor=textscan(crd,'%s %f %f ','delimiter',',');
code=cor{1};
lat=cor{2};
long=cor{3};
alt=cor{4};
%corx1=cor{2};
%cory1=cor{3};
veln=cor{5};
vele=cor{7};
velu=cor{9};
errn=cor{6};
erre=cor{8};
erru=cor{10};
%  [corx,cory]=wgs2ggrs(lat,long);
arr_s=size(lat);
k=arr_s(1);

%--------------------------------------------------------------------------
% SELECT BASELINE
%--------------------------------------------------------------------------
disp('a/a   code :    Vn     Ve');
for i=1:k
    fprintf('%4.0f %5s : %7.3f  %7.3f\n',i,code{i},veln(i),vele(i));
end
sta1=input('Set first station of baseline: ');
sta2=input('Set second station of baseline: ');
%--------------------------------------------------------------------------
% calculate diff and strain rates for 1d
%--------------------------------------------------------------------------
diffn = veln(sta2) - veln(sta1)
diffe = vele(sta2) - veln(sta1)

%  
%  
%  a=input('Set the direction angle of new topocentric system (-90<a<90) : ');
%  fprintf(param_file,'Direction of new topocentric system: %.2f deg\n',a);
%  arad=a*pi/180;
%  A=[cos(arad)*cos(arad) cos(arad)*sin(arad); sin(arad)*cos(arad) sin(arad)*sin(arad)];
%  
%  %scale factor
%  sc=input('scale factor (used for shape files): ');
%  fprintf(param_file,'Scale factor used for shapefiles: %.2f\n',sc);
%  velname=sprintf('%+04.0fdirvel.txt',a);
%  fprintf(param_file,'Output file for profile vel: %s \n',velname);
%  dfile=fopen(fullfile(output_dir,velname),'w');
%  fprintf(dfile,'Rotated Angle: %.3f\n',a);
%  
%  for i=1:k
%      V=[veln(i);vele(i)];
%      Vnew=A*V;
%      SV=sqrt(Vnew(1)^2+Vnew(2)^2);
%      if veln(i) < 0
%          SV=-SV;
%      end
%      fprintf(dfile, '%4s,%.4f,%.4f,%.4f\n',code{i},lat(i),long(i),SV);
%      cory1=cory(i)+(Vnew(1))*sc;
%      corx1=corx(i)+(Vnew(2))*sc;
%      v1(i)=Vnew(1);
%      v2(i)=Vnew(2);
%  end
%  foutname=sprintf('%s_along',outname);
%  fprintf(param_file,'Output gmt file for profile vel: %s.vel \n',foutname);
%  
%  %==================================================
%  ExtGmtVel(foutname,k,code,lat,long,v1,v2,errn,erre)
%  %==================================================
%  
%  %////////////////Tranverse velocities
%  a=a+90;
%  arad=a*pi/180;
%  A=[cos(arad)*cos(arad) cos(arad)*sin(arad); sin(arad)*cos(arad) sin(arad)*sin(arad)];
%  %scale factor
%  %  sc=input('scale factor (used for shape files): ');
%  velname=sprintf('%+04.0fdirvel.txt',a);
%  %  fprintf(param_file,'Output file for tranverse vel: %s \n',velname);
%  d2file=fopen(fullfile(output_dir,velname),'w');
%  fprintf(d2file,'Rotated Angle: %.3f\n',a);
%  
%  for i=1:k
%      V=[veln(i);vele(i)];
%      Vnew=A*V;
%      SV=sqrt(Vnew(1)^2+Vnew(2)^2);
%      if veln(i) < 0
%          SV=-SV;
%      end
%      fprintf(d2file, '%4s,%.4f,%.4f,%.4f\n',code{i},lat(i),long(i),SV);
%      cory1=cory(i)+(Vnew(1))*sc;
%      corx1=corx(i)+(Vnew(2))*sc;
%      v1(i)=Vnew(1);
%      v2(i)=Vnew(2);
%  end
%  foutname=sprintf('%s_tranv',outname);
%  %  fprintf(param_file,'Output gmt file for tranverse vel: %s.vel \n',foutname);
%  
%  %==================================================
%  ExtGmtVel(foutname,k,code,lat,long,v1,v2,errn,erre)
%  %==================================================

% ///////// feb16 add here  danast
%  %dhmiourgia mhkotomwn 
%  mik=input('Make alingment for the points 1.yes  :');
%  
%  alname=sprintf('%+3.0falfile.txt',a);
%  alfile=fopen(alname,'w');
%  fprintf(alfile,'polyline\n');
%  
%  while mik == 1
%      xmin=input('xmin=');
%      ymin=input('ymin=');
%     
%      inpvel=fopen(velname,'r');
%      inp=textscan(inpvel,'%s %f %f %f','delimiter',',');
%      code=inp{1};
%      corx=inp{2};
%      cory=inp{3};
%      svel=inp{4};
%      j=0;
%      width=input('Give the width of the zone in meters : ');
%      ymax=ymin;
%      for i=1:k
%          y1=cory(i);
%          x1=tan(arad)*(y1-ymin)+xmin;
%          d1=sqrt((x1-corx(i))^2+(y1-cory(i))^2);
%          if d1 <= width
%              j=j+1;
%              if x1 >= corx(i)
%                  d2=sqrt((x1-xmin)^2+(y1-ymin)^2)-cos(arad)*d1;
%              else
%                  d2=sqrt((x1-xmin)^2+(y1-ymin)^2)+cos(arad)*d1;
%              end
%              Dist(j)=d2/1000;
%              veld(j)=svel(i)*1000;
%              coded(j)=code(i);
%              if cory(i) > ymax
%                  ymax=cory(i);
%              end
%          end
%      end
%      xmax=xmin+(ymax-ymin)*tan(arad);
%      fprintf(alfile,'1 0\n');
%      fprintf(alfile,'0 %.4f %.4f 0.0 0.0\n',xmin,ymin);
%      fprintf(alfile,'1 %.4f %.4f 0.0 0.0\n',xmax,ymax);
%      
%      plot(Dist,veld,'o','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',4)
%      xlabel('Distance (km)')
%      ylabel('Velocities (mm/y)')
%         text (Dist+2, veld, coded,...
%             'HorizontalAlignment','left');
%      
%      mik=input('Make alingment for the points 1.yes  :');
%  end
%  fprintf(alfile,'END');

fclose all;






