function ITRFtrans
%-----------------------------------------------------------------------
%Transformation between ITRFyy to ITRF!!
%-----------------------------------------------------------------------
% File : ITRF.TP  ftp://itrf.ensg.ign.fr/pub/itrf/ITRF.TP
% TRANSFORMATION PARAMETERS AND THEIR RATES FROM ITRF2000 TO PREVIOUS FRAMES
% -------------------------------------------------------------------------------------
% SOLUTION         T1    T2    T3      D       R1      R2      R3    EPOCH   Ref. 
% UNITS----------> cm    cm    cm     ppb     .001"   .001"   .001"         IERS Tech.
%                  .     .     .       .       .       .       .            Note #
%         RATES    T1    T2    T3      D       R1      R2      R3
% UNITS----------> cm/y  cm/y  cm/y  ppb/y  .001"/y .001"/y .001"/y
% -------------------------------------------------------------------------------------
%    ITRF97       0.67  0.61 -1.85    1.55    0.00    0.00    0.00   1997.0   27
%         rates   0.00 -0.06 -0.14    0.01    0.00    0.00    0.02     
%    ITRF96       0.67  0.61 -1.85    1.55    0.00    0.00    0.00   1997.0   24
%         rates   0.00 -0.06 -0.14    0.01    0.00    0.00    0.02     
%    ITRF94       0.67  0.61 -1.85    1.55    0.00    0.00    0.00   1997.0   20
%         rates   0.00 -0.06 -0.14    0.01    0.00    0.00    0.02    
%    ITRF93       1.27  0.65 -2.09    1.95   -0.39    0.80   -1.14   1988.0   18
%         rates  -0.29 -0.02 -0.06    0.01   -0.11   -0.19    0.07   
%    ITRF92       1.47  1.35 -1.39    0.75    0.00    0.00   -0.18   1988.0   15
%         rates   0.00 -0.06 -0.14    0.01    0.00    0.00    0.02     
%    ITRF91       2.67  2.75 -1.99    2.15    0.00    0.00   -0.18   1988.0   12 
%         rates   0.00 -0.06 -0.14    0.01    0.00    0.00    0.02     
%    ITRF90       2.47  2.35 -3.59    2.45    0.00    0.00   -0.18   1988.0    9
%         rates   0.00 -0.06 -0.14    0.01    0.00    0.00    0.02     
%    ITRF89       2.97  4.75 -7.39    5.85    0.00    0.00   -0.18   1988.0    6
%         rates   0.00 -0.06 -0.14    0.01    0.00    0.00    0.02     
%    ITRF88       2.47  1.15 -9.79    8.95    0.10    0.00   -0.18   1988.0  IERS An. Rep.
%         rates   0.00 -0.06 -0.14    0.01    0.00    0.00    0.02           for 1988
% 
% 
% Note : These parameters are derived from those already published in the IERS
% Technical Notes indicated in the table above. The transformation parameters 
% should be used with the standard model (1) given below and are valid at the
% indicated epoch. 
% 
% : XS :    : X :   : T1 :   :  D   -R3   R2 : : X :
% :    :    :   :   :    :   :               : :   :
% : YS :  = : Y : + : T2 : + :  R3   D   -R1 : : Y :                       (1)
% :    :    :   :   :    :   :               : :   :
% : ZS :    : Z :   : T3 :   : -R2   R1   D  : : Z :
% 
% 
% Where X,Y,Z are the coordinates in ITRF2000 and XS,YS,ZS are the coordinates in 
% the other frames.
% On the other hand, for a given parameter P, its value at any epoch t 
% is obtained by using equation (2).
%                   .
% P(t) = P(EPOCH) + P * (t - EPOCH)                                        (2)
%                                                           .
% where EPOCH is the epoch indicated in the above table and P is the rate
% of that parameter.
%       ITRF2005 --> ITRF2000
%   	 T1 	 T2 	 T3 	 D 	 R1 	 R2 	 R3
%      	mm 	mm 	mm 	10-9 	mas 	mas 	mas
%   	0.1    -0.8    -5.8 	0.40 	0.000 	0.000 	0.000
% +/- 	0.3 	0.3 	0.3 	0.05 	0.012 	0.012 	0.012
%-----------------------------------------------------------------------
%       ITRF2008 --> ITRF2005
%      -0.5 	-0.9 	-4.7 	0.94 	0.000 	0.000 	0.000
%+/- 	0.2 	0.2 	0.2 	0.03 	0.008 	0.008 	0.008
%-----------------------------------------------------------------------
% INPUT FILE: code,X,Y,Z,inputITRF(1997),epoch(91.50)
% OUTPUT FILE: code ITRFoutput epoch Xout Yout Zout
clc
%clear all
format compact
format long
global input_dir
global output_dir

fid=0;
while fid < 1 
    dir(input_dir)
   filename=input('Open file coords: ', 's');
   [fid,message] = fopen(fullfile(input_dir,filename), 'r');
   if fid == -1
     disp(message)
   end
end
% format file of input data: code, X, Y, Z, ITRFin(e.g.1998),epoch
inpdata=textscan(fid,'%4s %12.4f %12.4f %12.4f %.0f %.2f','delimiter',',');
disp('Read input data...')

code=inpdata{1};
Xin=inpdata{2};
Yin=inpdata{3};
Zin=inpdata{4};
ITRFin=inpdata{5};
epoch=inpdata{6};
arr_s=size(Xin);
k=arr_s(1);
for i=1:k
    if epoch(i)<80;
        epoch(i)=epoch(i)+2000;
    else
        epoch(i)=epoch(i)+1900;
    end
end
ITRFout = input('Set the output ITRF : 2000, 2005, 2008 : ');
% m=0;k=-1;
% inp=fopen(fullfile(input_dir,filename), 'r');
% while m~=-1
%     k=k+1;
%     m=fgetl(inp);
%     %m=feof(crd);
% end

%-----------------------------------------------------------------------
%transformation without using rates!!!
%Transorm from ITRFyy to ITRF2000
%-----------------------------------------------------------------------
disp('Transform from ITRFyy to ITRF00...')
constR=0.000000277; %units of rotation table 0.001"=0.000000277 deg
for i=1:k
    switch ITRFin(i)
        case 1988
        T1=-0.0247;
        T2=-0.0115;
        T3=0.0979;
        D=-8.95/1000000000;
        R1=-constR*0.10;
        R2=-constR*0.00;
        R3=-constR*(-0.18);
        case 1989
        T1=-0.0297;
        T2=-0.0475;
        T3=0.0739;
        D=-5.85/1000000000;
        R1=-constR*0.00;
        R2=-constR*0.00;
        R3=-constR*(-0.18);
        case 1990
        T1=-0.0247;
        T2=-0.0235;
        T3=0.0359;
        D=-2.45/1000000000;
        R1=-constR*0.00;
        R2=-constR*0.00;
        R3=-constR*(-0.18);
        case 1991
        T1=-0.0267;
        T2=-0.0275;
        T3=0.0199;
        D=-2.15/1000000000;
        R1=-constR*0.00;
        R2=-constR*0.00;
        R3=-constR*(-0.18);
        case 1992
        T1=-0.0147;
        T2=-0.0135;
        T3=0.0139;
        D=-0.75/1000000000;
        R1=-constR*0.00;
        R2=-constR*0.00;
        R3=-constR*(-0.18);
        case 1993
        T1=-0.0127;
        T2=-0.0065;
        T3=0.0209;
        D=-1.95/1000000000;
        R1=-constR*(-0.39);
        R2=-constR*0.80;
        R3=-constR*(-1.14);
        case 1994
        T1=-0.0067;
        T2=-0.0061;
        T3=0.0185;
        D=-1.55/1000000000;
        R1=-constR*0.00;
        R2=-constR*0.00;
        R3=-constR*0.00;
        case 1996
        T1=-0.0067;
        T2=-0.0061;
        T3=0.0185;
        D=-1.55/1000000000;
        R1=-constR*0.00;
        R2=-constR*0.00;
        R3=-constR*0.00;
        case 1997
        T1=-0.0067;
        T2=-0.0061;
        T3=0.0185;
        D=-1.55/1000000000;
        R1=-constR*0.00;
        R2=-constR*0.00;
        R3=-constR*0.00;
        case 2000
        T1=0;
        T2=0;
        T3=0;
        D=0;
        R1=0;
        R2=0;
        R3=0;
        case 2005
        T1=0.0001;
        T2=-0.0008;
        T3=-0.0058;
        D=0.40/1000000000;
        R1=constR*0.00;
        R2=constR*0.00;
        R3=constR*0.00;
        case 2008
            T1=-0.0005;
            T2=-0.0009;
            T3=-0.0047;
            D=0.94/1000000000;
            R1=constR*0.00;
            R2=constR*0.00;
            R3=constR*0.00;
            T=[T1; T2; T3];
            R=[D -R3 -R2; R3 D -R1; -R2 R1 D];
%             for i=1:k
                Xs=[Xin(i); Yin(i); Zin(i)];
                x05=Xs + T + R*Xs;
                Xin(i)=x05(1);
                Yin(i)=x05(2);
                Zin(i)=x05(3);
%             end
            T1=0.0001;
            T2=-0.0008;
            T3=-0.0058;
            D=0.40/1000000000;
            R1=constR*0.00;
            R2=constR*0.00;
            R3=constR*0.00;
%             T=[T1; T2; T3];
%             R=[D -R3 -R2; R3 D -R1; -R2 R1 D];
%             for i=1:k
%                 Xs=[X05(i); Y05(i); Z05(i)];
%                 x00=Xs + T + R*Xs;
%                 X00(i)=x00(1);
%                 Y00(i)=x00(2);
%                 Z00(i)=x00(3);
%             end
    end
    R1=R1*pi/180;
    R2=R2*pi/180;
    R3=R3*pi/180;
    T=[T1; T2; T3];
    Xs=[Xin(i); Yin(i); Zin(i)];
    R=[D -R3 -R2; R3 D -R1; -R2 R1 D];
    
    x00=Xs + T + R*Xs;
    X00(i)=x00(1);
    Y00(i)=x00(2);
    Z00(i)=x00(3);
end
if ITRFout==2000
    Xout = X00;
    Yout = Y00;
    Zout = Z00;
else
%-----------------------------------------------------------------------
%Tranformation from ITRF00 to ITRF05
%-----------------------------------------------------------------------
disp('Transform from ITRF00 to ITRF05...')
%Transformation parameters from ITRF00 to ITRf05
T1=-0.0001;
T2=0.0008;
T3=0.0058;
D=-0.40/1000000000;
R1=-constR*0.00;
R2=-constR*0.00;
R3=-constR*0.00;
T=[T1; T2; T3];
R=[D -R3 -R2; R3 D -R1; -R2 R1 D];
for i=1:k
    Xs=[X00(i); Y00(i); Z00(i)];
    x05=Xs + T + R*Xs;
    X05(i)=x05(1);
    Y05(i)=x05(2);
    Z05(i)=x05(3);
end
end
if ITRFout == 2005
    Xout = X05;
    Yout = Y05;
    Zout = Z05;
elseif ITRFout == 2008
     disp('Transform from ITRF05 to ITRF08...')
    %Transformation parameters from ITRF00 to ITRf05
    T1=0.0005;
    T2=0.0009;
    T3=0.0047;
    D=-0.94/1000000000;
    R1=-constR*0.00;
    R2=-constR*0.00;
    R3=-constR*0.00;
    T=[T1; T2; T3];
    R=[D -R3 -R2; R3 D -R1; -R2 R1 D];
    for i=1:k
        Xs=[X05(i); Y05(i); Z05(i)];
        x08=Xs + T + R*Xs;
        X08(i)=x08(1);
        Y08(i)=x08(2);
        Z08(i)=x08(3);
    end
    Xout = X08;
    Yout = Y08;
    Zout = Z08;
else
      disp(message)
end
%Write output file
cirname = sprintf('outITRF%.0f.crd',ITRFout);
out=fopen(fullfile(output_dir,cirname),'w');
fprintf(out,'Transformation from ITRFyy to ITRF%.0f\n\n',ITRFout);
fprintf(out,'code \t ITRFref \t epoch \t\t X(m) \t\t Y(m) \t\t Z(m) \n');
fprintf(out,'---------------------------------------------------------------------\n');
for i=1:k
    fprintf(out,'%s \t %.0f \t %.2f \t %.4f \t %.4f \t %.4f\n',code{i},ITRFin(i),epoch(i),Xout(i),Yout(i),Zout(i));
%     fprintf(out,'%s \t',code{i});
%     fprintf(out,'%.2f \t',epoch(i));
%     fprintf(out,'%.4f \t',X05(i));
%     fprintf(out,'%.4f \t',Y05(i));
%     fprintf(out,'%.4f \n',Z05(i));
end

fclose all;











