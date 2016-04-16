function velocities
%==========================================================================
%DIONYSOS SATELLITE OBSERVATORY - HIGHER GEODESY LABORATORY
%Calculate velocity  vectors create shapefile
%Three options are available:
% 1 : Velocities from the file (ITRF)
% 2 : Velocities with respect to a fixed Europe
% 3 : Velocities with respect to a fixed station
% Extract shapefile only for velocities....
%INPUT FILE: code,lat,long,vn,ve,vu,svn,sve,svu
%--------------------------------------------------------------------------
%velocity vectors for arcGIS
%--------------------------------------------------------------------------
global input_dir
global output_dir
global param_file
global outname
clc
%clear all
format compact
format long

% %input-output directories
% input_dir=fullfile('C:','Documents and Settings','gps\My Documents\GeoTool\input');
% output_dir=fullfile('C:','Documents and Settings','gps\My Documents\GeoTool\output');
fprintf(param_file,'\n****************\tVelocities\t******************\n\n');

%--------------------------------------------------------------------------
%Coordinate file format 'name,x,y'
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
cor=textscan(crd,'%s %f  %f %f %f %f %f %f %f','delimiter',',');
%cor=textscan(crd,'%s %f %f ','delimiter',',');
code=cor{1};
lat=cor{2};
long=cor{3};
%alt=cor{4};
%corx1=cor{2};
%cory1=cor{3};
veln=cor{4};
vele=cor{5};
velu=cor{6};
errn=cor{7};
erre=cor{8};
erru=cor{9};
[corx1,cory1]=wgs2ggrs(lat,long);
arr_s=size(lat);
k=arr_s(1);
%m=0;k=-1;
%crd=fopen(filename, 'r');
% while m~=-1
%     k=k+1;
%     m=fgetl(crd);
% end
%--------------------------------------------------------------------------
%Velocities file format 'name,Vn,Ve,Vu'
%--------------------------------------------------------------------------
%vel=0;
%while vel < 1 
%   filename=input('Open file velocities: ', 's');
%   [vel,message] = fopen(filename, 'r');
%   if vel == -1
%     disp(message)
%   end
%end
%fprintf(param_file,'Input Velocity files : %s\n',filename);
%vel=textscan(vel,'%*s %f %f %f','delimiter',',');
disp('Velocities')
disp('****************************')
disp('|   1:from file            |')
disp('|   2:ITRF->fixed Europe   |')
disp('|   3:ITRF->fixed station  |')
disp('****************************')
p=input('select which velocities use :');
switch p
    case 1
%     veln=vel{1};
%     vele=vel{2};
%     velu=vel{3};
    foutname=sprintf('%s_ITRF',outname);
    cirname=sprintf('%s_ITRF.txt',outname);
    outvel=fopen(fullfile(input_dir,cirname),'w');
    fprintf(param_file,'Calculated velocities in ITRF... output file : fixITRF.txt\n');
    for q=1:k
        fprintf(outvel,'%s,',code{q});
        fprintf(outvel,'%.10f,',lat(q));
        fprintf(outvel,'%.10f,',long(q));
        fprintf(outvel,'%.4f,',veln(q));
        fprintf(outvel,'%.4f,',vele(q));
        fprintf(outvel,'%.4f\n',velu(q));
    end
    fclose(outvel);
    case 2
    veln=veln-0.0114;
    vele=vele-0.0236;
    %velu=velu;
    foutname=sprintf('%s_EUR',outname);
    cirname=sprintf('%s_EUR.txt',outname);
    outvel=fopen(fullfile(input_dir,cirname),'w');
    fprintf(param_file,'Calculated velocities with respect to a fixed Europe... \n output file : fixEUR.txt\n');
    for q=1:k
        fprintf(outvel,'%s,',code{q});
        fprintf(outvel,'%.10f,',lat(q));
        fprintf(outvel,'%.10f,',long(q));
        fprintf(outvel,'%.4f,',veln(q));
        fprintf(outvel,'%.4f,',vele(q));
        fprintf(outvel,'%.4f\n',velu(q));
    end
    fclose(outvel);
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
    outvel=fopen(fullfile(input_dir,cirname),'w');
    fprintf(param_file,'Calculated velocities with fixed station %s \n',code{InputSta});
    foutname=sprintf('%s_%s',outname,code{InputSta});
    for q=1:k
        fprintf(outvel,'%s,',code{q});
        fprintf(outvel,'%.10f,',lat(q));
        fprintf(outvel,'%.10f,',long(q));
        fprintf(outvel,'%.4f,',veln(q));
        fprintf(outvel,'%.4f,',vele(q));
        fprintf(outvel,'%.4f\n',velu(q));
    end
    fclose(outvel);
end

% err=0;
%     while err < 1 
%        filename=input('Open file errors: ', 's');
%        [err,message] = fopen(filename, 'r');
%        if err == -1
%            disp(message)
%        end
%     end
%     fprintf(param_file,'Input errors file : %s\n',filename);
%     err=textscan(err,'%*s %f %f %f','delimiter',',');
%     errn=err{1};
%     erre=err{2};
%     erru=err{3};
%--------------------------------------------------------------------------
%scale factor
sc=input('scale factor: ');
fprintf(param_file,'Velocities sc : %.0f\n',sc);
%--------------------------------------------------------------------------
%calculate horizontal component of velocities
%--------------------------------------------------------------------------
corx2=corx1+vele*sc;
cory2=cory1+veln*sc;
%write output file for horizontal component
%output=input('dwse to onoma tou output arxeiou for horizontal velocities: ', 's');
fprintf(param_file,'Output shapefile : %s\n',outname);
cirname=sprintf('%s_vel.txt',outname);
hfile=fopen(fullfile(output_dir,cirname),'w');
fprintf(hfile,'polyline\n');
for l=1:k
    fprintf(hfile,'%1.0f 0\n',l-1);
    fprintf(hfile,'0 %.3f',corx1(l));
    fprintf(hfile,'% .3f 0.0 0.0\n',cory1(l));
    fprintf(hfile,'1 %.3f',corx2(l));
    fprintf(hfile,'% .3f 0.0 0.0\n',cory2(l));
end
fprintf(hfile,'END');
%==========================================================================
ExtShpVel(foutname,k,code,corx1,cory1,corx2,cory2,veln,vele,velu,errn,erre,erru)
ExtGmtVel(foutname,k,code,lat,long,veln,vele,errn,erre)
ExtGmtSites(foutname,k,code,lat,long)
%==========================================================================

%--------------------------------------------------------------------------
%calculate error ellipses in horizontal components!!!!!!!!!
%--------------------------------------------------------------------------
p=input('calculate error ellipses in horizontal components?? 1:yes 2:no :');
if p==1
    %write output file for error ellipses
    %output2=input('dwse to onoma tou output arxeiou for error ellipses: ', 's');
    cirname=sprintf('%s_herr.txt',outname);
    efile=fopen(fullfile(output_dir,cirname),'w');
    fprintf(efile,'polygon\n');
    for l=1:k
        fprintf(efile,'%1.0f 0\n',l-1);
        q=0;
        for t=0.0: 0.01: 2*pi
            erry=cory2(l)+errn(l)*sin(t)*sc;
            errx=corx2(l)+erre(l)*cos(t)*sc;
            fprintf(efile,'%.0f',q);
            fprintf(efile,'% .3f',errx);
            fprintf(efile,'% .3f 1.#QNAN 1.#QNAN\n',erry);
            q=q+1;
        end    
    end
fprintf(efile,'END');
end
fclose all;
%--------------------------------------------------------------------------
%calculate vertical component of velocities
%--------------------------------------------------------------------------
p=input('do you want to calculate vertical velocities 1:yes 2:no :');
if p==1
    %calculate vertical component of velocities
    coryu=cory1+velu*sc;
    corxu=corx1;
    %write output file for vertical component
    %output1=input('dwse to onoma tou output arxeiou for vertical velocities: ', 's');
    cirname=sprintf('%s_vvert.txt',outname);
    ufile=fopen(fullfile(output_dir,cirname),'w');
    fprintf(ufile,'polyline\n');
    for l=1:k
        fprintf(ufile,'%1.0f 0\n',l-1);
        fprintf(ufile,'0 %.3f',corx1(l));
        fprintf(ufile,'% .3f 0.0 0.0\n',cory1(l));
        fprintf(ufile,'1 %.3f',corxu(l));
        fprintf(ufile,'% .3f 0.0 0.0\n',coryu(l));
    end
    fprintf(ufile,'END');
end
fclose all;
%--------------------------------------------------------------------------
%calculate error ellipses in vertical component!!!!!!!!!
%--------------------------------------------------------------------------
p=input('calculate error bar in vertical component?? 1:yes 2:no :');
if p==1
    %write output file for error ellipses
    %output3=input('dwse to onoma tou output arxeiou for error ellipses: ', 's');
    cirname=sprintf('%s_verterr.txt',outname);
    evfile=fopen(fullfile(output_dir,cirname),'w');
    fprintf(evfile,'polyline\n');
    for l=1:k
        corey1=coryu+erru*sc;
        corey2=coryu-erru*sc;
        fprintf(evfile,'%1.0f 0\n',l-1);
        fprintf(evfile,'0 %.3f',corxu(l));
        fprintf(evfile,'% .3f 0.0 0.0\n',corey1(l));
        fprintf(evfile,'1 %.3f',corxu(l));
        fprintf(evfile,'% .3f 0.0 0.0\n',corey2(l));
    end
fprintf(evfile,'END');
end

fclose all;
%--------------------------------------------------------------------------
disp('Finished..!!! Look for the output files.')








