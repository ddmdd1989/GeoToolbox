function velocities
%==========================================================================
%  
%   |===========================================|
%   |**     DIONYSOS SATELLITE OBSERVATORY    **|
%   |**        HIGHER GEODESY LABORATORY      **|
%   |** National Tecnical University of Athens**|
%   |===========================================|
%  
%   filename              : velocities.m
%                           NAME=velocities
%   version               : v-1.0
%                           VERSION=v-1.0
%                           RELEASE=beta
%   created               : DEC-2011
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

%Calculate velocity  vectors create shapefile
%Three options are available:
% 1 : Velocities from the file (ITRF)
% 2 : Velocities with respect to a fixed Europe
% 3 : Velocities with respect to a fixed station
% Extract shapefile only for velocities....
%INPUT FILE: code,lat,long,vn,ve,vu,svn,sve,svu
%--------------------------------------------------------------------------
%velocity vectors for arcGIS
% out file for gmt plots
%--------------------------------------------------------------------------
global input_dir
global output_dir
global param_file
global outname
clc
%clear all
format compact
format long

fprintf(param_file,'\n****************\tVelocities\t******************\n\n');

%--------------------------------------------------------------------------
% Read input file INPUT FILE: code,lat,long, up ,vn,svn,ve,sve,vu,svu (mm input)
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
[corx1,cory1]=wgs2ggrs(lat,long);
arr_s=size(lat);
k=arr_s(1);

%--------------------------------------------------------------------------
% Compute special velocities
% ITRF - Fixed Europe - Fixed station
%--------------------------------------------------------------------------
disp('Velocities')
disp('****************************')
disp('|   1:from file            |')
disp('|   2:ITRF->fixed Europe   |')
disp('|   3:ITRF->fixed station  |')
disp('****************************')
p=input('select which velocities use :');
switch p
%###### FILE INPUT
	case 1
		foutname=sprintf('%s_ITRF',outname);
		cirname=sprintf('%s_ITRF.txt',outname);
		outvel=fopen(fullfile(output_dir,cirname),'w');
		fprintf(param_file,'Calculated velocities in ITRF ... \n output file : %s_ITRF.txt\n',outname);
		for q=1:k
		svel=sqrt(veln(q)^2 + vele(q)^2);
		sdsvel=sqrt(errn(q)^2 + erre(q)^2);
			fprintf(outvel,'%4s %12.7f %12.7f %9.3f %8.2f %6.2f %8.2f %6.2f %8.2f %6.2f %8.2f %6.2f\n',code{q},lat(q),long(q),alt(q),veln(q),errn(q),vele(q),erre(q),velu(q),erru(q),svel,sdsvel);
%  			fprintf(outvel,'%.5f,',lat(q));
%  			fprintf(outvel,'%.5f,',long(q));
%  			fprintf(outvel,'%.3f,',alt(q));
%  			fprintf(outvel,'%.2f,',veln(q));
%  			fprintf(outvel,'%.2f,',errn(q));
%  			fprintf(outvel,'%.2f,',vele(q));
%  			fprintf(outvel,'%.2f,',erre(q));
%  			fprintf(outvel,'%.2f,',velu(q));
%  			fprintf(outvel,'%.2f\n',erru(q));
		end
		fclose(outvel);

%###### FIXED EUROPE
	case 2
		veln=veln-11.4;
		vele=vele-23.6;
		%velu=velu;
		foutname=sprintf('%s_EUR',outname);
		cirname=sprintf('%s_EUR.txt',outname);
		outvel=fopen(fullfile(output_dir,cirname),'w');
		fprintf(param_file,'Calculated velocities with respect to a fixed Europe... \n output file : %s_EUR.txt\n',outname);
		for q=1:k
		svel=sqrt(veln(q)^2 + vele(q)^2);
		sdsvel=sqrt(errn(q)^2 + erre(q)^2);
			fprintf(outvel,'%4s %12.7f %12.7f %9.3f %8.2f %6.2f %8.2f %6.2f %8.2f %6.2f %8.2f %6.2f\n',code{q},lat(q),long(q),alt(q),veln(q),errn(q),vele(q),erre(q),velu(q),erru(q),svel,sdsvel);
%  			fprintf(outvel,'%s,',code{q});
%  			fprintf(outvel,'%.5f,',lat(q));
%  			fprintf(outvel,'%.5f,',long(q));
%  			fprintf(outvel,'%.3f,',alt(q));
%  			fprintf(outvel,'%.2f,',veln(q));
%  			fprintf(outvel,'%.2f,',errn(q));
%  			fprintf(outvel,'%.2f,',vele(q));
%  			fprintf(outvel,'%.2f,',erre(q));
%  			fprintf(outvel,'%.2f,',velu(q));
%  			fprintf(outvel,'%.2f\n',erru(q));
		end
		fclose(outvel);
%###### FIXED STATION
	case 3
		%veln=veln;
		%vele=vele;
		%velu=velu;
		for q=1:k
		fprintf('%.0f : %s  %+.4f  %+.4f  %+.4f\n',q,code{q},veln(q),vele(q),velu(q));
		end
		InputSta=input('Input Permanent Station : ');
		vn=veln(InputSta);
		ve=vele(InputSta);
		vu=velu(InputSta);
		veln=veln-vn;
		vele=vele-ve;
		velu=velu-vu;
		cirname=sprintf('%s_fixSTA.txt',outname);
		outvel=fopen(fullfile(output_dir,cirname),'w');
		fprintf(param_file,'Calculated velocities with fixed station %s \n',code{InputSta});
		foutname=sprintf('%s_%s',outname,code{InputSta});
		for q=1:k
		svel=sqrt(veln(q)^2 + vele(q)^2);
		sdsvel=sqrt(errn(q)^2 + erre(q)^2);
			fprintf(outvel,'%4s %12.7f %12.7f %9.3f %8.2f %6.2f %8.2f %6.2f %8.2f %6.2f %8.2f %6.2f\n',code{q},lat(q),long(q),alt(q),veln(q),errn(q),vele(q),erre(q),velu(q),erru(q),svel,sdsvel);
%  			fprintf(outvel,'%s,',code{q});
%  			fprintf(outvel,'%.5f,',lat(q));
%  			fprintf(outvel,'%.5f,',long(q));
%  			fprintf(outvel,'%.3f,',alt(q));
%  			fprintf(outvel,'%.2f,',veln(q));
%  			fprintf(outvel,'%.2f,',errn(q));
%  			fprintf(outvel,'%.2f,',vele(q));
%  			fprintf(outvel,'%.2f,',erre(q));
%  			fprintf(outvel,'%.2f,',velu(q));
%  			fprintf(outvel,'%.2f\n',erru(q));
		end
		fclose(outvel);
	end

%--------------------------------------------------------------------------
%scale factor for GIS outputs
%--------------------------------------------------------------------------
sc=input('scale factor for Shape File: ');
fprintf(param_file,'Velocities sc for shapefile: %.0f\n',sc);

%--------------------------------------------------------------------------
%calculate horizontal component of velocities
%--------------------------------------------------------------------------
corx2=corx1+vele*sc;
cory2=cory1+veln*sc;
foutname=sprintf('%s_vhor',outname);
%==========================================================================
ExtShpVel(foutname,k,code,corx1,cory1,corx2,cory2,veln,vele,velu,errn,erre,erru)
ExtGmtVel(foutname,k,code,lat,long,veln,vele,errn,erre)
ExtGmtSites(foutname,k,code,lat,long)
%==========================================================================

%--------------------------------------------------------------------------
%calculate vertical velocities --- PRepei na allazei onoma
%--------------------------------------------------------------------------
p=input('do you want to calculate vertical velocities 1:yes 2:no :');
if p==1
%  BUG	fprintf(param_file,'Vertical Velocities calculated \n');
	coryu=cory1+velu*sc;
	corxu=corx1;
	foutname=sprintf('%s_vver',outname);
	%==========================================================================
	ExtShpVel(foutname,k,code,corx1,cory1,corxu,coryu,veln,vele,velu,errn,erre,erru)
	ExtGmtVel(foutname,k,code,lat,long,velu,velu-velu,erru,erru-erru)
	ExtGmtSites(foutname,k,code,lat,long)
	%==========================================================================
end
fclose all;




%%%%%TEST until HERE!!!!!!!!!!!!!!!!!!########################################
%###########################################################################
%  %--------------------------------------------------------------------------
%  %calculate error ellipses in horizontal components!!!!!!!!!
%  %--------------------------------------------------------------------------
%  p=input('calculate error ellipses in horizontal components?? 1:yes 2:no :');
%  if p==1
%      %write output file for error ellipses
%      %output2=input('dwse to onoma tou output arxeiou for error ellipses: ', 's');
%      cirname=sprintf('%s_herr.txt',outname);
%      efile=fopen(fullfile(output_dir,cirname),'w');
%      fprintf(efile,'polygon\n');
%      for l=1:k
%          fprintf(efile,'%1.0f 0\n',l-1);
%          q=0;
%          for t=0.0: 0.01: 2*pi
%              erry=cory2(l)+errn(l)*sin(t)*sc;
%              errx=corx2(l)+erre(l)*cos(t)*sc;
%              fprintf(efile,'%.0f',q);
%              fprintf(efile,'% .3f',errx);
%              fprintf(efile,'% .3f 1.#QNAN 1.#QNAN\n',erry);
%              q=q+1;
%          end    
%      end
%  fprintf(efile,'END');
%  end
%  fclose all;
%  %--------------------------------------------------------------------------
%  %calculate vertical component of velocities
%  %--------------------------------------------------------------------------
%  p=input('do you want to calculate vertical velocities 1:yes 2:no :');
%  if p==1
%      %calculate vertical component of velocities
%      coryu=cory1+velu*sc;
%      corxu=corx1;
%      %write output file for vertical component
%      %output1=input('dwse to onoma tou output arxeiou for vertical velocities: ', 's');
%      cirname=sprintf('%s_vvert.txt',outname);
%      ufile=fopen(fullfile(output_dir,cirname),'w');
%      fprintf(ufile,'polyline\n');
%      for l=1:k
%          fprintf(ufile,'%1.0f 0\n',l-1);
%          fprintf(ufile,'0 %.3f',corx1(l));
%          fprintf(ufile,'% .3f 0.0 0.0\n',cory1(l));
%          fprintf(ufile,'1 %.3f',corxu(l));
%          fprintf(ufile,'% .3f 0.0 0.0\n',coryu(l));
%      end
%      fprintf(ufile,'END');
%  end
%  fclose all;
%  %--------------------------------------------------------------------------
%  %calculate error ellipses in vertical component!!!!!!!!!
%  %--------------------------------------------------------------------------
%  p=input('calculate error bar in vertical component?? 1:yes 2:no :');
%  if p==1
%      %write output file for error ellipses
%      %output3=input('dwse to onoma tou output arxeiou for error ellipses: ', 's');
%      cirname=sprintf('%s_verterr.txt',outname);
%      evfile=fopen(fullfile(output_dir,cirname),'w');
%      fprintf(evfile,'polyline\n');
%      for l=1:k
%          corey1=coryu+erru*sc;
%          corey2=coryu-erru*sc;
%          fprintf(evfile,'%1.0f 0\n',l-1);
%          fprintf(evfile,'0 %.3f',corxu(l));
%          fprintf(evfile,'% .3f 0.0 0.0\n',corey1(l));
%          fprintf(evfile,'1 %.3f',corxu(l));
%          fprintf(evfile,'% .3f 0.0 0.0\n',corey2(l));
%      end
%  fprintf(evfile,'END');
%  end

fclose all;
%--------------------------------------------------------------------------
disp('Finished..!!! Look for the output files.')
