%draw strain tensor for gis
%paramorfwshs
format compact
format long
%--------------------------------------------------------------------------
%arxeio parametrwn tou tanusth
fid=0;
while fid < 1 
   filename=input('Open file parameters: ', 's');
   [fid,message] = fopen(filename, 'r');
   if fid == -1
     disp(message)
   end
end
%diavasma tou arxeiou
for m=1:40
    a=fgetl(fid);
    if m==6
        str=[a(37) a(38) a(39) a(40) a(41) a(42) a(43) a(44) a(45) a(46)];
        xcen1=str2double(str);
        xcen=xcen1*1000;
    end
    if m==7
        str=[a(37) a(38) a(39) a(40) a(41) a(42) a(43) a(44) a(45) a(46)];
        ycen1=str2double(str);
        ycen=ycen1*1000;
    end
    if m==18
        str=[a(16) a(17) a(18) a(19) a(20) a(21) a(22) a(23)];
        sx1=str2double(str);
        sx=sx1/100;
    end
    if m==19
        str=[a(16) a(17) a(18) a(19) a(20) a(21) a(22) a(23)];
        sy1=str2double(str);
        sy=sy1/100;
    end
    if m==28
        str=[ a(18) a(19) a(20) a(21) a(22) a(23) a(24) a(25) a(26) a(27)];
        kx=str2double(str);
    end
    if m==29
        str=[ a(18) a(19) a(20) a(21) a(22) a(23) a(24) a(25) a(26) a(27)];
        ky=str2double(str);
    end
    if m==31
        str=[ a(18) a(19) a(20) a(21) a(22) a(23) a(24) a(25) a(26) a(27)];
        kmax=str2double(str);
    end
    if m==32
        str=[ a(18) a(19) a(20) a(21) a(22) a(23) a(24) a(25) a(26) a(27)];
        kmin=str2double(str);
    end
    if m==34
        str=[ a(18) a(19) a(20) a(21) a(22) a(23) a(24) a(25) a(26) a(27)];
        ms=str2double(str);
    end
    if m==37
        str=[ a(18) a(19) a(20) a(21) a(22) a(23) a(24) a(25) a(26) a(27)];
        az=str2double(str);
    end
    if m==39
        str=[ a(18) a(19) a(20) a(21) a(22) a(23) a(24) a(25) a(26) a(27)];
        gmax=str2double(str);
    end   
end
%pinakas parametrwn
%strain=[ms xcen ycen sx sy kx ky kmax kmin az gmax];
sc=input('scale factor: ');
r=1;
a=1+kmax;
b=1+kmin;
f=(90-az)*pi/180;
%--------------------------------------------------------------------------
%circle
%output1=input('dwse to onoma tou output arxeiou for circle: ', 's');
    cfile=fopen('cir.txt','w');
    fprintf(cfile,'polygon\n');
    cfile=fopen('cir.txt','a');
    fprintf(cfile,'0 0\n');
    q=0;
    for t=0.0: 0.01: 2*pi
        xcir=xcen+r*cos(t)*sc;
        ycir=ycen+r*sin(t)*sc;
        fprintf(cfile,'%.0f',q);
        fprintf(cfile,'% .3f',xcir);
        fprintf(cfile,'% .3f 1.#QNAN 1.#QNAN\n',ycir);
        q=q+1;
    end
    fprintf(cfile,'END');
%--------------------------------------------------------------------------
%ellipses
%output2=input('dwse to onoma tou output arxeiou for error ellipses: ', 's');
    efile=fopen('ell.txt','w');
    fprintf(efile,'polygon\n');
    efile=fopen('ell.txt','a');
    fprintf(efile,'0 0\n');
    q=0;
        for t=0.0: 0.01: 2*pi
            errx=xcen+a*cos(t)*cos(f)*sc-b*sin(t)*sin(f)*sc;
            erry=ycen+a*cos(t)*sin(f)*sc+b*sin(t)*cos(f)*sc;
            fprintf(efile,'%.0f',q);
            fprintf(efile,'% .3f',errx);
            fprintf(efile,'% .3f 1.#QNAN 1.#QNAN\n',erry);
            q=q+1;
        end    
    fprintf(efile,'END');
fclose all;
%--------------------------------------------------------------------------
%axes of ellipses
%output3=input('dwse to onoma tou output gia axes of ellipses: ','s');
afile=fopen('axx.txt','w');
fprintf(afile,'polyline\n');
afile=fopen('axx.txt','a');
q=0;
for t=0: pi/2: 3*pi/2
    fprintf(afile,'%.0f 0\n',q);
    errx=xcen+a*cos(t)*cos(f)*sc-b*sin(t)*sin(f)*sc;
    erry=ycen+a*cos(t)*sin(f)*sc+b*sin(t)*cos(f)*sc;
    fprintf(afile,'0 %.3f',xcen);
    fprintf(afile,'% .3f 0.0 0.0\n',ycen);
    fprintf(afile,'0 %.3f',errx);
    fprintf(afile,'% .3f 0.0 0.0\n',erry);
    q=q+1;
end
fprintf(afile,'END');
fclose all;


















