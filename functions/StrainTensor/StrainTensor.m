function StrainTensor
%==========================================================================
%  
%   |===========================================|
%   |**     DIONYSOS SATELLITE OBSERVATORY    **|
%   |**        HIGHER GEODESY LABORATORY      **|
%   |** National Tecnical University of Athens**|
%   |===========================================|
%  
%   filename              : StrainTensor.m
%                           NAME=StrainTensor
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
%   detailed update list  : LAST_UPDATE=FEB-2016
%   contact               : Demitris Anastasiou (danast@mail.ntua.gr)
%                           Xanthos Papanikolaou (xanthos@mail.ntua.gr)
%   ----------------------------------------------------------------------
%   THIS PROGRAM IS TRANSLATION OF AN OLDER PROGRAM IN QUICKBASIC
%   CALCULATES THE TRANSLATION, ROTATION AND SCALE FROM OBSERVED
%   DIFFERENCES OF COORDINATES (X,Y)  WITH  SIX  PARAMETERS
%   GIVING A TOTAL TRANSLATION, ROTATION AND SCALE FOR ALL POINTS
%   
%   BYRON NAKOS                                    DATE : JAN . 1991
%  
%                             UPDATED: VANGELIS ZACHARIS  , MAY 1994
%                             UPDATED: JORDAN GALANIS     , SEP 1997
%                 TRANSLATE TO MATLAB: DEMITRIS ANASTASIOU, OCT 2009      
%==========================================================================
%==========================================================================
%CALCULATE STRAIN TENSOR PARAMETERS
% INPUT FILE: code,lat,long,alt,up,vn,svn,ve,sve,vu,svu
%==========================================================================
global input_dir
global output_dir
global param_file
global outname
clc
format compact
format long
fprintf(param_file,'\n****************\tStrain Tensor\t******************\n\n');
%--------------------------------------------------------------------------
disp('Calculate strain tensors parameters');
disp(' 1:calculate new strain tensor ');
disp(' 0:EXIT ');
do=input('Selection : ');

%--------------------------------------------------------------------------
% start poccesses
treksimo=0;
while do==1
    treksimo=treksimo+1; 
    fprintf(param_file,'\na/a of strain tensor : %.0f\n',treksimo);
    inp=0;
    dir (input_dir)
    while inp < 1 
        filename=input('Open file parameters: ', 's');
        [inp,message] = fopen(fullfile(input_dir,filename), 'r');
        if inp == -1
            disp(message)
        end
    end
    fprintf(param_file,'Input file : %s\n',filename);
    inpt=textscan(inp,'%s %f %f %*f %f %*f %f %*f %*f %*f','delimiter',','); %ORIGINAL
    codeinp=inpt{1};
    lat=inpt{2};
    long=inpt{3};
    [x1inp,y1inp]=wgs2ggrs(lat,long);
    %x1inp=inpt{2};
    %y1inp=inpt{3};
    vninp=inpt{4};
    veinp=inpt{5};
    %svninp=inpt{6};
    %sveinp=inpt{7};
    arr_s=size(lat);
    k=arr_s(1);  % calculate stations
%     m=0;k=-1;
%     inp=fopen(fullfile(input_dir,filename), 'r');
%     while m~=-1
%         k=k+1;
%         m=fgetl(inp);
%     end
    %2 option use all the stations aor select
    disp('Stations Selections ... 2 options')
    disp('   1: Use all the stations')
    disp('   2: Select Stations')
    sta_use=input('Optrion : ');
  switch sta_use
    case 1 % use all stations
        np=k;
        code=codeinp;
        x1=x1inp; 
        y1=y1inp;
        vn=vninp/1000;
        ve=veinp/1000;
        %svn=svninp;
        %sve=sveinp;
        fprintf('%.0f Network points selected\n',k);
        fprintf(param_file,'Network points used : %.0f\n',k);
    case 2 % select stations
%%BUG%%Be careful...don't select the same staτion 3 times!!!!!! tha to lusw!
        disp('select the station for the calculation (at least 3)');
        for i=1:k
            fprintf('%.0f : %s\n',i,codeinp{i});
        end
        disp('0 : finish the selection');
        fprintf('tensor code %03.0f\n',treksimo);
        np=0;
        sel_sta=input('First station : ');
        sel_staq=sel_sta;
        while sel_sta~=0 
            np=np+1;
            code(np)=codeinp(sel_sta);
            x1(np)=x1inp(sel_sta); 
            y1(np)=y1inp(sel_sta);
            vn(np)=vninp(sel_sta)/1000;
            ve(np)=veinp(sel_sta)/1000;
            %svn(np,1)=svninp(sel_sta);
            %sve(np,1)=sveinp(sel_sta);
            sel_sta=input('Next station : ');
            for i=1:np
                if sel_sta~=sel_staq(i)
                    ki=i;
                else
                   disp('You have already give this stations:');
                   disp(sel_staq);
                   sel_sta=input('Give an other station : ');
                   ki=0;
                end
            end
           if ki==np
               sel_staq=[sel_staq sel_sta];
           end
        end
        fprintf('%.0f Network points selected\n',np);
        fprintf(param_file,'Network points selected : %.0f\n',np);
  end % END of switch for select station
    %--------------------------------------------------------------------------
    %TRANSFORMATION WITH SIX PARAMETERS
    %==========================================================================
    %   DX = Xnew - Xold = Ex + Exx * X + Exy * Y
    % ' DY = Ynew - Yold = Ey + Eyx * X + Eyy * Y
    % '
    % ' SHIFT    : Sx = Ex
    % '            Sy = Ey
    % '
    % ' ROTATION : ex = -Eyx
    % '            ey =  Exy
    % '
    % ' SCALE    : Kx = Exx
    % '            Ky = Eyy
    % '            Kx = 1 + Exx
    % '            Ky = 1 + Eyy
    % '
    % '
    % ' Kmax³ = 1/2 * {(Exx + Eyy) + sqrt[(Exx - Eyy)^2 + (Exy + Eyx)^2]}
    % ' Kmin³ = 1/2 * {(Exx + Eyy) - sqrt[(Exx - Eyy)^2 + (Exy + Eyx)^2]}
    % '
    % ' tan 2Az = (Exy + Eyx)/(Eyy - Exx)
    % '
    % ' STRAIN         : Gmax = ¡ max - ¡ min = sqrt[(Exx - Eyy)^2 + (Exy + Eyx)^2]
    % '
    % ' TOTAL ROTATION : E =  (Exy - Eyx)/2
    % '
    % ' MEAN SCALE     : K =  (Exx + Eyy)/2
    %==========================================================================

    xcen=0;
    ycen=0;
    for i=1:np
        xcen=xcen+x1(i);
        ycen=ycen+y1(i);
    end
    xcen=xcen/np;
    ycen=ycen/np;
    x2=x1-xcen;
    y2=y1-ycen;
    for i=1:np
        VelneMat(i,1)=ve(i);
        VelneMat(np+i,1)=vn(i);
    end
    %make the observation matrix
    for i=1:np
        ObsMat(1,i)=1;
        ObsMat(2,i)=0;
        ObsMat(3,i)=x2(i);
        ObsMat(4,i)=y2(i);
        ObsMat(5,i)=0;
        ObsMat(6,i)=0;
        ObsMat(1,np+i)=0;
        ObsMat(2,np+i)=1;
        ObsMat(3,np+i)=0;
        ObsMat(4,np+i)=0;
        ObsMat(5,np+i)=x2(i);
        ObsMat(6,np+i)=y2(i);
    end
    %Variance matrix
%     for i=1:np
%         svn(i)=svn(i)^2;
%         sve(i)=sve(i)^2;
%     end
%     VarVel=[sve' svn'];
    %VarVel=[1 1 1 1 1 1 1 1];
%     VarVelMat=diag(VarVel);
    
    ObsMatTrn=ObsMat';
   
    %Theory from least square solution
    %E=[Ex Ey Exx Exy Eyx Eyy]
    %E = inv(A'*inv(V)*A)*A'*inv(V)*B
    %mse = B'*(inv(V) - inv(V)*A*inv(A'*inv(V)*A)*A'*inv(V))*B./(m-n)
    %S = inv(A'*inv(V)*A)*mse
    %stdE = sqrt(diag(S))
    [E,stdE,mse,S] = lscov(ObsMatTrn,VelneMat);
    StanDev=sqrt(mse);
    Sx = E(1);
    SxVar = stdE(1);
    Sy = E(2);
    SyVar = stdE(2);
    Exx = E(3);
    Exy = E(4);
    Eyx = E(5);
    Eyy = E(6);
    ExxPyy = E(3)+E(6);
    ExxMyy = E(3)-E(6);
    ExyPyx = E(4)+E(5);
    ExyMyx = E(4)-E(5);
%      e0 = (Eyy - Exx)/2;
%      IIE = (Exx* Eyy - e0^2)
    Kx = E(3);
    Ky = E(6);
    KxVar = stdE(3);
    KyVar = stdE(6);
    Ex = -E(5);
    Ey = E(4);
    ExVar = stdE(5);
    EyVar = stdE(4);
    ETotal = ExyMyx/2;
    ETotalVar = 0.5 * sqrt( S(5,5) + S(4,4));
    KDummy = ExxMyy^2 + ExyPyx^2;
    KDummy1 = 0.5 * (ExxPyy + sqrt(KDummy));
    KDummy2 = 0.5 * (ExxPyy - sqrt(KDummy));
    KDumVar = ExxMyy^2 / (4 * KDummy);
    KDumVar1 = 0.25 * (1 + ExxMyy / sqrt(KDummy)) ^ 2;
    KDumVar2 = 0.25 * (1 - ExxMyy / sqrt(KDummy)) ^ 2;
    if KDummy1 >= KDummy2
            Kmax = KDummy1;
            Kmin = KDummy2;
            KmaxVar = sqrt(KDumVar1 * KxVar ^ 2 + KDumVar2 * KyVar ^ 2 + KDumVar * (ExVar ^ 2 + EyVar ^ 2));
            KminVar = sqrt(KDumVar2 * KxVar ^ 2 + KDumVar1 * KyVar ^ 2 + KDumVar * (ExVar ^ 2 + EyVar ^ 2));
    else
            Kmax = KDummy2;
            Kmin = KDummy1;
            KmaxVar = sqrt(KDumVar2 * KxVar ^ 2 + KDumVar1 * KyVar ^ 2 + KDumVar * (ExVar ^ 2 + EyVar ^ 2));
            KminVar = sqrt(KDumVar1 * KxVar ^ 2 + KDumVar2 * KyVar ^ 2 + KDumVar * (ExVar ^ 2 + EyVar ^ 2));
    end
    KMean = ExxPyy / 2;
    KMeanVar = 0.5 * sqrt(S(3, 3) + S(6, 6));
    %Az = 0.5 * (atan(ExyPyx / -ExxMyy));
    Az = 0.5 * (atan2(ExyPyx,-ExxMyy));
    Az = Az * 180/pi;
    if ExxMyy > 0 
        Az = Az + 90;
    end
    AzVar = 0.5 * sqrt((S(3,3)+S(6,6))*ExyPyx^2 + (S(4,4)+S(5,5)) * ExxMyy^2) / (ExyPyx^2 + ExxMyy^2);
    AzVar = AzVar * 180/pi;
    Gmax = sqrt(ExxMyy ^ 2 + ExyPyx ^ 2);
    GmaxVar = sqrt(KmaxVar ^ 2 + KminVar ^ 2);
    IIE = sqrt(Kmax^2 + Kmin^2);
%      IIEVar = 
    %compute residuals
    %ResN = Vn - Sy - DX*Eyx - DY*Eyy
    %ResE = Ve - Sx - DX*Exx - DY*Exy
    for i=1:np
        residuals(1,i) = vn(i) - Sy - (x1(i)-xcen)*Exx - (y1(i)-ycen)*Exy;
        residuals(2,i) = ve(i) - Sx - (x1(i)-xcen)*Eyx - (y1(i)-ycen)*Eyy;
    end
    %======================================================================
    %print output file of strain tensor parameters
    %======================================================================
    strname=sprintf('%s%03.0fstr.out',outname,treksimo);
    parfile=fopen(fullfile(output_dir,strname),'w');
    fprintf(parfile,'NATIONAL TECHNICAL UNIVARSITY OF ATHENS\n');
    fprintf(parfile,'DIONYSOS SATELLITE OBSERVATORY\n');
    fprintf(parfile,'*******************************************\n');
    fprintf(parfile,'NETWORK POINTS USED : %.0f\n',np);
    fprintf(parfile,'BLOCK CENTER s COORDINATES :  %.3f m\n',xcen);
    fprintf(parfile,'                             %.3f m\n',ycen);
    fprintf(parfile,'*******************************************\n');
    fprintf(parfile,'A POSTERIORI STANDARD DEVIATION : %.2f mm\n\n',StanDev*1000);
    fprintf(parfile,'Deformation Parameters\n');
    fprintf(parfile,'***********************\n\n');
    fprintf(parfile,'Shift :     Sx= %+7.2f   +-%7.2f mm\n',Sx*1000,SxVar*1000);
    fprintf(parfile,'            Sy= %+7.2f   +-%7.2f mm\n\n',Sy*1000,SyVar*1000);
    fprintf(parfile,'Rotation :  Ex= %+7.3f   +-%7.3f ppm\n',Ex*1000000,ExVar*1000000);
    fprintf(parfile,'            Ey= %+7.3f   +-%7.3f ppm\n\n',Ey*1000000,EyVar*1000000);
    fprintf(parfile,'Total Rot:   E= %+7.3f   +-%7.3f ppm\n\n',ETotal*1000000,ETotalVar*1000000);
    fprintf(parfile,'Scale :     Kx= %+7.3f   +-%7.3f ppm\n',Kx*1000000,KxVar*1000000);
    fprintf(parfile,'            Ky= %+7.3f   +-%7.3f ppm\n\n',Ky*1000000,KyVar*1000000);
    fprintf(parfile,'          Kmax= %+7.3f   +-%7.3f ppm\n',Kmax*1000000,KmaxVar*1000000);
    fprintf(parfile,'          Kmin= %+7.3f   +-%7.3f ppm\n\n\n',Kmin*1000000,KminVar*1000000);
    fprintf(parfile,'Mean Scale : K= %+7.3f   +-%7.3f ppm\n\n',KMean*1000000,KMeanVar*1000000);
    fprintf(parfile,'Azimouth :  Az= %+7.3f   +-%7.3f deg\n\n',Az,AzVar);
    fprintf(parfile,'Strain : G max= %+7.3f   +-%7.3f ppm\n\n',Gmax*1000000,GmaxVar*1000000);
    fprintf(parfile,'2nd Inv :  IIE= %+7.3f           ppm\n\n',IIE*1000000);
    fprintf(parfile,'*******************************************\n');
    fprintf(parfile,'NETWORK POINTS USED TO CALCULATE STRAIN TENSOR\n');
    fprintf(parfile,'a/a:  code        X(m)          Y(m)         ResN  ResE(mm/yr)\n');
    for i=1:np
        fprintf(parfile,'%4.0f : %5s  %13.4f  %14.4f  %+5.1f   %+5.1f\n',i,code{i},x1(i),y1(i),residuals(1,i)*1000,residuals(2,i)*1000);
    end


%      %--------------------------------------------------------------------------
%      %print output file for gis stain tensor
%      sc=input('scale factor: ');
%      fprintf(param_file,'Global scale factor : %.f\n',sc);
%      fprintf(param_file,'Strain Scale factor : 1000000\n');
%      r=1;
%      a=1+Kmax*1000000;
%      b=1+Kmin*1000000;
%      f=(90-Az)*pi/180;
%   
%   
%      %create outfiles for input on GIS no Shape files!SHPfiles -> line 305
%      %--------------------------------------------------------------------------
%      %circle
%          cirname=sprintf('%s%03.0fcir.txt',outname,treksimo);
%          cfile=fopen(fullfile(output_dir,cirname),'w');
%          fprintf(cfile,'polygon\n');
%          %cfile=fopen('cir.txt','a');
%          fprintf(cfile,'0 0\n');
%          q=0;
%          for t=0.0: 0.01: 2*pi
%              xcir=xcen+r*cos(t)*sc;
%              ycir=ycen+r*sin(t)*sc;
%              fprintf(cfile,'%.0f',q);
%              fprintf(cfile,'% .3f',xcir);
%              fprintf(cfile,'% .3f 1.#QNAN 1.#QNAN\n',ycir);
%              q=q+1;
%          end
%          fprintf(cfile,'END');
%      %--------------------------------------------------------------------------
%      %ellipses
%          ellname=sprintf('%s%03.0fell.txt',outname,treksimo);
%          efile=fopen(fullfile(output_dir,ellname),'w');
%          fprintf(efile,'polygon\n');
%          %efile=fopen('ell.txt','a');
%          fprintf(efile,'0 0\n');
%          q=0;
%              for t=0.0: 0.01: 2*pi
%                  errx=xcen+a*cos(t)*cos(f)*sc-b*sin(t)*sin(f)*sc;
%                  erry=ycen+a*cos(t)*sin(f)*sc+b*sin(t)*cos(f)*sc;
%                  fprintf(efile,'%.0f',q);
%                  fprintf(efile,'% .3f',errx);
%                  fprintf(efile,'% .3f 1.#QNAN 1.#QNAN\n',erry);
%                  q=q+1;
%              end    
%          fprintf(efile,'END');
%      %--------------------------------------------------------------------------
%      %axes of ellipses
%      axxname=sprintf('%s%03.0faxx.txt',outname,treksimo);
%      afile=fopen(fullfile(output_dir,axxname),'w');
%      fprintf(afile,'polyline\n');
%      %afile=fopen('axx.txt','a');
%      q=0;
%      for t=0: pi/2: 3*pi/2
%          fprintf(afile,'%.0f 0\n',q);
%          errx=xcen+a*cos(t)*cos(f)*sc-b*sin(t)*sin(f)*sc;
%          erry=ycen+a*cos(t)*sin(f)*sc+b*sin(t)*cos(f)*sc;
%          fprintf(afile,'0 %.3f',xcen);
%          fprintf(afile,'% .3f 0.0 0.0\n',ycen);
%          fprintf(afile,'0 %.3f',errx);
%          fprintf(afile,'% .3f 0.0 0.0\n',erry);
%          q=q+1;
%      end
%      fprintf(afile,'END');
    %--------------------------------------------------------------------------
    
%     %Stations used to calculate the strain tensor
%     staname=sprintf('%03.0fsta.txt',treksimo);
%     sfile=fopen(fullfile(output_dir,staname),'w');
%     fprintf(sfile,'Point\n');
%     %afile=fopen('axx.txt','a');
%     q=0;
%     for i=1:np
%         fprintf(sfile,'%.0f %.4f %.4f 0.0 1.0\n',i,x1(i),y1(i));
%     %     fprintf(sfile,'0 %.3f',xcen);
%     %     fprintf(sfile,'% .3f 0.0 0.0\n',ycen);
%     %     fprintf(sfile,'0 %.3f',errx);
%     %     fprintf(sfile,'% .3f 0.0 0.0\n',erry);
%     %     q=q+1;
%     end
%     fprintf(sfile,'END');
%      %-------------------------------------------------------------------------
%      %compression and extension arrows
%      %id of compression : 0   id of extension : 1
%      q=1;
%      for t=0: pi/2: 3*pi/2
%          errx(q)=xcen+Kmax*cos(t)*cos(f)*sc-Kmin*sin(t)*sin(f)*sc;
%          erry(q)=ycen+Kmax*cos(t)*sin(f)*sc+Kmin*sin(t)*cos(f)*sc;
%      %     fprintf(deffile,'0 %.3f',xcen);
%      %     fprintf(deffile,'% .3f 0.0 0.0\n',ycen);
%      %     fprintf(deffile,'0 %.3f',errx);
%      %     fprintf(deffile,'% .3f 0.0 0.0\n',erry);
%          q=q+1;
%      end
%      %======================================================================
%      %Extract shape files and GMT outputs
%      %======================================================================
%      strname=sprintf('%s%03.0fstr',outname,treksimo);
%      ExtShpStrain(strname,xcen,ycen,errx,erry,Kmax,Kmin)
%      staname=sprintf('%s%03.0fsta',outname,treksimo);
%      ExtShpPoint(staname,np,code,x1,y1,vn,ve,residuals(1,:),residuals(2,:))
%    [latcen,longcen]=ggrs2wgs(xcen,ycen);
%   gmt_name=sprintf('%s%03.0fgmt',outname,treksimo);
%    ExtGmtStr(gmt_name,latcen,longcen,Kmax*10^6,Kmin*10^6,Az, ETotal,ETotalVar)
    [latcen,loncen]=ggrs2wgs(xcen,ycen);
    gmt_plot(treksimo,1) = latcen;
    gmt_plot(treksimo,2) = loncen;
    gmt_plot(treksimo,3) = Kmax*10^6;
    gmt_plot(treksimo,4) = KmaxVar*10^6;
    gmt_plot(treksimo,5) = Kmin*10^6;
    gmt_plot(treksimo,6) = KminVar*10^6;
    gmt_plot(treksimo,7) = Az;
    gmt_plot(treksimo,8) = AzVar;
    gmt_plot(treksimo,9) = ETotal*1000000;
    gmt_plot(treksimo,10)= ETotalVar*1000000;
    gmt_plot(treksimo,11)= Gmax*1000000;
    gmt_plot(treksimo,12)= GmaxVar*1000000;
    gmt_plot(treksimo,13)= IIE*10^6;
    
    [lat_staUsed,lon_staUsed] = ggrs2wgs(x1,y1);
%=========================================================
    gmtstaname=sprintf('%s%03.0f',outname,treksimo);
    fprintf(param_file,'Output file for station gmt plot: %s.sta\n',gmtstaname);
    fprintf(param_file,'Output file for region  gmt plot: %s.reg\n',gmtstaname);
    ExtGmtSites(gmtstaname,np,code,lat_staUsed,lon_staUsed)
    ExtGmtRegion(gmtstaname,np,code,lat_staUsed,lon_staUsed)
%=========================================================

    disp('Calculate strain tensors');
    disp(' 1:calculate new strain tensor ');
    disp(' 0:EXIT ');
    do=input('Selection : ');
   clear inpt codeinp lat long x1inp y1inp vninp veinp arr_s ObsMat ObsMatTrn VelneMat residuals E stdE mse S
end
% output file ???
%  cirname=sprintf('%sstr_par',outname);
%  outfile=fopen(fullfile(output_dir,cirname),'w');
%  for i=1:treksimo
%      fprintf(outfile,' %4.0f %10.3f %10.3f %10.3f %10.3f %10.3f\n',i,gmt_plot(i,1),gmt_plot(i,2),gmt_plot(i,3),gmt_plot(i,5),gmt_plot(i,7));
%      fprintf(outfile,' %37.3f %10.3f %10.3f\n',gmt_plot(i,4),gmt_plot(i,6),gmt_plot(i,8));
%      fprintf(outfile,'----------------------------------------------------------------\n');
%  end

%-------------------------------------------------------------------------
% outfile strain file all variables.
cirname=sprintf('%spar.str',outname);
outfile=fopen(fullfile(output_dir,cirname),'w');
for i=1:treksimo
    fprintf(outfile,'%5.0f %7.3f %7.3f %7.3f %7.3f  %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f  %7.3f %7.3f\n',i,gmt_plot(i,1),gmt_plot(i,2),gmt_plot(i,3),gmt_plot(i,4),gmt_plot(i,5),gmt_plot(i,6),gmt_plot(i,7),gmt_plot(i,8),gmt_plot(i,9),gmt_plot(i,10),gmt_plot(i,11),gmt_plot(i,12),gmt_plot(i,13));
end
fprintf(param_file,'\nOutput file for gmt plot: %s\n',cirname);

fclose(outfile);
ExtGmtStr(gmt_plot)
clc
disp('********************************************');
fprintf('\n%.0f Strain Tensors have been calculated\n',treksimo);
disp('********************************************');
fprintf(param_file,'\n%.0f Strain Tensors have been calculated\n',treksimo);










 
    
    
