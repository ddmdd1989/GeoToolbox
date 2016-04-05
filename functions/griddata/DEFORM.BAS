DEFDBL A-Z
DECLARE SUB FunAffine1 (s#(), X#, Y#, XDiffComp#, YDiffComp#)
DECLARE SUB FunAffine2 (s#(), X#, Y#, XDiffComp#, YDiffComp#)
DECLARE SUB matmul (a1#(), a2#(), a3#(), o%, c%, h%)
DECLARE SUB matinv (a#(), ainv#(), c%)
'
' ----------------------------------------------------------------
'
' NATIONAL TECHNICAL UNIVERSITY OF ATHENS
' HIGHER GEODESY AND CARTOGRAPHY LABORATORY
' PROGRAM STRAIN VERSION 1.0
' THIS PROGRAM CALCULATES THE TRANSLATION, ROTATION AND SCALE FROM
' OBSERVED DIFFERENCES OF COORDINATES (X,Y)  WITH  SIX  PARAMETERS
' GIVING A TOTAL TRANSLATION, ROTATION AND SCALE FOR ALL POINTS
' BYRON NAKOS                                    DATE : JAN . 1991
'
'                             UPDATED: VANGELIS ZACHARIS, MAY 1994
'                             UPDATED: JORDAN GALANIS   , SEP 1997
'
' ALGORITHM ABSTRACT :
'
' FIRST PART :
' ДДДДДДДДДДДД
'
' ѓX = Xnew - Xold = Ex + Escale * X + Erotation * Y
' ѓY = Ynew - Yold = Ey - Erotation * X + Escale * Y
'
' SHIFT    : Sx = Ex
'            Sy = Ey
'
' ROTATION : њ  = Erotation
'
' SCALE    : Ў  = Escale
'
'
' SECOND PART :
' ДДДДДДДДДДДД
'
' ѓX = Xnew - Xold = Ex + Exx * X + Exy * Y
' ѓY = Ynew - Yold = Ey + Eyx * X + Eyy * Y
'
' SHIFT    : Sx = Ex
'            Sy = Ey
'
' ROTATION : њx = -Eyx
'            њy =  Exy
'
' SCALE    : Ўx = Exx
'            Ўy = Eyy
'            Kx = 1 + Exx
'            Ky = 1 + Eyy
'
'
' іЎ maxі
' іЎ minі = 1/2 * {(Exx + Eyy) с ы[(Exx - Eyy)э + (Exy + Eyx)э]}
'
' tan 2Az = (Exy + Eyx)/(Eyy - Exx)
'
' STRAIN         : љ max = Ў max - Ў min = ы[(Exx - Eyy)э + (Exy + Eyx)э]
'
' TOTAL ROTATION : њ = (њx + њy)/2 = (Exy - Eyx)/2
'
' MEAN SCALE     : Ў = (Ў max + Ў min)/2 = (Exx + Eyy)/2
'
' ----------------------------------------------------------------
'
pi = 4 * ATN(1)
Kil = 1000!
mil = Kil * Kil
AngConst = 180 / pi
CLS
Nul$ = "ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД"
PRINT Nul$
PRINT
PRINT "MODULE : Deformation                          NTUA / D.S.O."
PRINT
PRINT Nul$
PRINT
PRINT "DATA INPUT PROCEDURE :"
PRINT
INPUT "Enter the input filename of the common points : ", Name$
INPUT "Enter the output filename of the calculated parameters : ", Nameout$
'INPUT "Enter the input filename of the uncorrected coordinates : ", Name1$
INPUT "Enter the output filename of the corrected coordinates : ", Nameout1$
INPUT "Type the number of working points to save memory : ", NumWorkPoin%
PRINT
'Name$ = UCASE$(Name$)
'Name1$ = Name$ + ".NE"
'Name2$ = Name$ + ".DIF"
'PRINT
'PRINT Nul$
PRINT
PRINT
PRINT
PRINT "Check your entries and PRESS ANY KEY to proceed with part one : "
t$ = INPUT$(1)
DIM XBase(1 TO NumWorkPoin%), YBase(1 TO NumWorkPoin%)
DIM XDiffBase(1 TO NumWorkPoin%), YDiffBase(1 TO NumWorkPoin%)
DIM CodeBase&(1 TO NumWorkPoin%)

OPEN Name$ FOR INPUT AS #1

FOR i% = 1 TO NumWorkPoin%
    INPUT #1, aa$, XBase, YBase, YDiffBase(i%), XDiffBase(i%)
'    YDiffBase(i%) = YDiffBase(i%) * 1000#
'    XDiffBase(i%) = XDiffBase(i%) * 1000#
'    PRINT CodeBase&(i%), aa$, XBase, YBase, YDiffBase(i%), XDiffBase(i%)
'    SLEEP
    XBase(i%) = XBase / mil
    YBase(i%) = YBase / mil
NEXT
CLOSE
CLS
PRINT Nul$
PRINT
PRINT "FIRST PART"
PRINT
PRINT "TRANSFORMATION WITH FOUR PARAMETERS"
PRINT
PRINT "Results are goint to be stored in the following files :"
PRINT
'Name3$ = Name$ + "_MOD"
'Name4$ = Name3$ + ".NE"
'Name5$ = Name$ + ".DIF"
'Name6$ = Name$ + ".OUT"
PRINT
'PRINT "Transformed (X,Y) coordinates           : "; Name4$
'PRINT "Differences (DN,DE) after tranformation : "; Name5$
'PRINT "Full report of the transformation       : "; Name6$
PRINT
PRINT " Input terminated, now processing !!!"
PRINT
PRINT Nul$
REDIM ObsMat(4, 2 * NumWorkPoin%), ObsMatTrn(2 * NumWorkPoin%, 4)
REDIM RegMat(4, 4), RegMatInv(4, 4)
REDIM DiffXYMat(1, 2 * NumWorkPoin%), MulMat(1, 4), ParMat(1, 4)
REDIM XDiffComp(1 TO NumWorkPoin%), YDiffComp(1 TO NumWorkPoin%)
REDIM XRes(NumWorkPoin%), YRes(NumWorkPoin%)
XBaseCen = 0
YBaseCen = 0
FOR i% = 1 TO NumWorkPoin%
    XBaseCen = XBaseCen + XBase(i%)
    YBaseCen = YBaseCen + YBase(i%)
NEXT
XBaseCen = XBaseCen / NumWorkPoin%
YBaseCen = YBaseCen / NumWorkPoin%

FOR i% = 1 TO NumWorkPoin%
    XBase(i%) = XBase(i%) - XBaseCen
    YBase(i%) = YBase(i%) - YBaseCen
NEXT
FOR i% = 1 TO NumWorkPoin%
    DiffXYMat(1, i%) = XDiffBase(i%)
    DiffXYMat(1, NumWorkPoin% + i%) = YDiffBase(i%)
NEXT
FOR i% = 1 TO NumWorkPoin%
    ObsMat(1, i%) = 1
    ObsMat(2, i%) = 0
    ObsMat(3, i%) = XBase(i%)
    ObsMat(4, i%) = YBase(i%)
    ObsMat(1, NumWorkPoin% + i%) = 0
    ObsMat(2, NumWorkPoin% + i%) = 1
    ObsMat(3, NumWorkPoin% + i%) = YBase(i%)
    ObsMat(4, NumWorkPoin% + i%) = -XBase(i%)
NEXT
FOR i% = 1 TO 4
    FOR j% = 1 TO 2 * NumWorkPoin%
        ObsMatTrn(j%, i%) = ObsMat(i%, j%)
    NEXT
NEXT
matmul ObsMatTrn(), ObsMat(), RegMat(), 2 * NumWorkPoin%, 4, 4
matmul ObsMatTrn(), DiffXYMat(), MulMat(), 2 * NumWorkPoin%, 4, 1
matinv RegMat(), RegMatInv(), 4
matmul RegMatInv(), MulMat(), ParMat(), 4, 4, 1
FOR i% = 1 TO NumWorkPoin%
    X = XBase(i%)
    Y = YBase(i%)
    FunAffine1 ParMat(), X, Y, XDiffComp, YDiffComp
    XDiffComp(i%) = XDiffComp
    YDiffComp(i%) = YDiffComp
    XRes(i%) = XDiffBase(i%) - XDiffComp(i%)
    YRes(i%) = YDiffBase(i%) - YDiffComp(i%)
NEXT
Var = 0
FOR i% = 1 TO NumWorkPoin%
    Var = Var + XRes(i%) ^ 2 + YRes(i%) ^ 2
NEXT
IF NumWorkPoin% = 2 THEN
    Var = 0
  ELSE
    Var = Var / (2 * NumWorkPoin% - 4)
END IF
StanDev = SQR(Var)
Sx = ParMat(1, 1)
Sy = ParMat(1, 2)
SxVar = SQR(Var * RegMatInv(1, 1))
SyVar = SQR(Var * RegMatInv(2, 2))
Escale = ParMat(1, 3)
Erotation = ParMat(1, 4)
EscVar = SQR(Var * RegMatInv(3, 3))
ErtVar = SQR(Var * RegMatInv(4, 4))
'OPEN Name4$ FOR OUTPUT AS #1
'OPEN Nameout$ FOR OUTPUT AS #2
'PEN Name6$ FOR OUTPUT AS #3
'PRINT #3, "NATIONAL TECHNICAL UNIVERSITY OF ATHENS"
'PRINT #3, "DIONYSOS SATELLITE OBSERVATORY"
'PRINT #3, "ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД"
'PRINT #3,
'PRINT #3,
'PRINT #3,
'PRINT #3, "FILENAME   : "; Name6$
'PRINT #3, "ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД"
'PRINT #3,
'PRINT #3,
'PRINT #3, USING "&#####.###&"; "CENTER's COORDINATES :  Xcen = "; XBaseCen * Kil; " Km"
'PRINT #3, USING "&#####.###&"; "                        Ycen = "; YBaseCen * Kil; " Km"
'PRINT #3,
'PRINT #3,
'PRINT #3, "ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД"
'PRINT #3, "ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД"
FOR i% = 1 TO NumWorkPoin%
    CodeBase& = CodeBase&(i%)
    XBase = XBase(i%) * Kil
    YBase = YBase(i%) * Kil
    X = XBase + XBaseCen * Kil
    Y = YBase + YBaseCen * Kil

    XDiffBase = XDiffBase(i%)
    YDiffBase = YDiffBase(i%)
    XDiffComp = XDiffComp(i%)
    YDiffComp = YDiffComp(i%)
    XRes = XRes(i%)
    YRes = YRes(i%)
'    WRITE #1, CodeBase&, XBase, YBase
'    WRITE #2, YRes, XRes
NEXT
'PRINT #3, "ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД"
'PRINT #3,
'PRINT #3,
'PRINT #3, USING "&###.###&"; "A POSTERIORI STANDARD DEVIATION :   с "; StanDev * 100; "   in cm"
'PRINT #3,
'PRINT #3,
'PRINT #3, "DEFORMATION PARAMETERS :"
'PRINT #3, "ДДДДДДДДДДДДДДДДДДДДДДДД"
'PRINT #3,
'PRINT #3, USING "&####.###&###.###&"; "Shift :  Sx = "; Sx * 100; "   с"; 100 * SxVar; " in cm"
'PRINT #3, USING "&####.###&###.###&"; "         Sy = "; Sy * 100; "   с"; 100 * SyVar; " in cm"
'PRINT #3,
'PRINT #3,
'PRINT #3, USING "&####.###&###.###&"; "Rotation :        њ = "; Erotation; "  с "; ErtVar; " in ppm"
'PRINT #3,
'PRINT #3, USING "&####.###&###.###&"; "Scale    :        Ў = "; Escale; "  с "; EscVar; " in ppm"
'CLOSE
CLS
PRINT Nul$
PRINT
PRINT "SECOND PART"
PRINT
PRINT "TRANSFORMATION WITH SIX PARAMETERS"
PRINT
'PRINT "Coordinates are going to be retreved from file : "; Name1$  ' vz
'PRINT "Differences are going to be retreved from file : "; Name2$  ' vz
PRINT

'{vz
CLOSE #1
OPEN Name$ FOR INPUT AS #1
FOR i% = 1 TO NumWorkPoin%
    INPUT #1, aa$, XBase(i%), YBase(i%), YDiffBase(i%), XDiffBase(i%)
    XBase(i%) = XBase(i%) / mil
    YBase(i%) = YBase(i%) / mil
'vz}

NEXT
'CLOSE
VIEW PRINT 11 TO 23
'DO
    CLS
REM    INPUT "Type the name of block (output filename) : ", Name7$
REM     Name7$ = UCASE$(Name7$)
REM     LOCATE 11, 44
REM     PRINT Name7$
    PRINT
    PRINT
REM     INPUT "Type the number of points : ", n%
n% = NumWorkPoin%
    PRINT
    REDIM CountBase%(n%)
    FOR i% = 1 TO n%
       LOCATE 16, 9
       PRINT "                                                   "
         LOCATE 16, 4
        PRINT "Point : "; i%;
'         INPUT "   Enter counter number : ", CountBase%(i%)
        CountBase%(i%) = i%
    NEXT
    PRINT
    PRINT " Input terminated, now processing !!!"
    PRINT
    PRINT Nul$
    REDIM ObsMat(6, 2 * n%), ObsMatTrn(2 * n%, 6), RegMat(6, 6)
    REDIM RegMatInv(6, 6), DiffXYMat(1, 2 * n%), MulMat(1, 6), ParMat(1, 6)
    REDIM X(n%), Y(n%), Code&(n%), DiffXComp(n%), DiffYcomp(n%), XRes(n%)
    REDIM YRes(n%), DiffXValue(n%), DiffYValue(n%), XValue(n%), YValue(n%)
    FOR i% = 1 TO n%
        Code&(i%) = CodeBase&(CountBase%(i%))
        X(i%) = XBase(CountBase%(i%))
        Y(i%) = YBase(CountBase%(i%))
        DiffXValue(i%) = XDiffBase(CountBase%(i%))
        DiffYValue(i%) = YDiffBase(CountBase%(i%))
    NEXT
    XvalueCen = 0
    YvalueCen = 0
    FOR i% = 1 TO n%
        XvalueCen = XvalueCen + X(i%)
        YvalueCen = YvalueCen + Y(i%)
    NEXT
    XvalueCen = XvalueCen / n%
    YvalueCen = YvalueCen / n%
    FOR i% = 1 TO n%
        XValue(i%) = X(i%) - XvalueCen
        YValue(i%) = Y(i%) - YvalueCen
    NEXT
    FOR i% = 1 TO n%
        DiffXYMat(1, i%) = DiffXValue(i%)
        DiffXYMat(1, n% + i%) = DiffYValue(i%)
    NEXT
    FOR i% = 1 TO n%
        ObsMat(1, i%) = 1
        ObsMat(2, i%) = 0
        ObsMat(3, i%) = XValue(i%)
        ObsMat(4, i%) = YValue(i%)
        ObsMat(5, i%) = 0
        ObsMat(6, i%) = 0
        ObsMat(1, n% + i%) = 0
        ObsMat(2, n% + i%) = 1
        ObsMat(3, n% + i%) = 0
        ObsMat(4, n% + i%) = 0
        ObsMat(5, n% + i%) = XValue(i%)
        ObsMat(6, n% + i%) = YValue(i%)
    NEXT
    FOR i% = 1 TO 6
        FOR j% = 1 TO 2 * n%
            ObsMatTrn(j%, i%) = ObsMat(i%, j%)
        NEXT
    NEXT
    matmul ObsMatTrn(), ObsMat(), RegMat(), 2 * n%, 6, 6
    matmul ObsMatTrn(), DiffXYMat(), MulMat(), 2 * n%, 6, 1
    matinv RegMat(), RegMatInv(), 6
    matmul RegMatInv(), MulMat(), ParMat(), 6, 6, 1
    OPEN "res.out" FOR OUTPUT AS 5#
    FOR i% = 1 TO n%
        XValue = XValue(i%)
        YValue = YValue(i%)
        FunAffine2 ParMat(), XValue, YValue, DiffXComp, DiffYcomp
        DiffXComp(i%) = DiffXComp
        DiffYcomp(i%) = DiffYcomp
        XRes(i%) = DiffXValue(i%) - DiffXComp(i%)
        YRes(i%) = DiffYValue(i%) - DiffYcomp(i%)
        PRINT #5, USING "\            \  #######.## #######.## ##.###  ##.### "; STR$(CodeBase&(i%)); XBase(i%) * mil; YBase(i%) * mil; YRes(i%); XRes(i%)
    NEXT
    Var = 0
    FOR i% = 1 TO n%
        Var = Var + XRes(i%) ^ 2 + YRes(i%) ^ 2
    NEXT
    IF n% = 3 THEN
        Var = 0
      ELSE
        Var = Var / (2 * n% - 6)
    END IF
    StanDev = SQR(Var)
    ExxPyy = ParMat(1, 3) + ParMat(1, 6)
    ExxMyy = ParMat(1, 3) - ParMat(1, 6)
    ExyPyx = ParMat(1, 4) + ParMat(1, 5)
    ExyMyx = ParMat(1, 4) - ParMat(1, 5)
    Sx = ParMat(1, 1)
    Sy = ParMat(1, 2)
    SxVar = SQR(Var * RegMatInv(1, 1))
    SyVar = SQR(Var * RegMatInv(2, 2))
    Kx = ParMat(1, 3)
    Ky = ParMat(1, 6)
    KxVar = SQR(Var * RegMatInv(3, 3))
    KyVar = SQR(Var * RegMatInv(6, 6))
    Ex = -ParMat(1, 5)
    Ey = ParMat(1, 4)
    ExVar = SQR(Var * RegMatInv(5, 5))
    EyVar = SQR(Var * RegMatInv(4, 4))
    ETotal = ExyMyx / 2
    ETotalVar = .5 * SQR(Var * (RegMatInv(5, 5) + RegMatInv(4, 4)))
    KDummy = ExxMyy ^ 2 + ExyPyx ^ 2
    KDummy1 = .5 * (ExxPyy + SQR(KDummy))
    KDummy2 = .5 * (ExxPyy - SQR(KDummy))
    KDumVar = ExxMyy ^ 2 / (4 * KDummy)
    KDumVar1 = .25 * (1 + ExxMyy / SQR(KDummy)) ^ 2
    KDumVar2 = .25 * (1 - ExxMyy / SQR(KDummy)) ^ 2
    IF KDummy1 >= KDummy2 THEN
        Kmax = KDummy1
        Kmin = KDummy2
        KmaxVar = SQR(KDumVar1 * KxVar ^ 2 + KDumVar2 * KyVar ^ 2 + KDumVar * (ExVar ^ 2 + EyVar ^ 2))
        KminVar = SQR(KDumVar2 * KxVar ^ 2 + KDumVar1 * KyVar ^ 2 + KDumVar * (ExVar ^ 2 + EyVar ^ 2))
      ELSE
        Kmax = KDummy2
        Kmin = KDummy1
        KmaxVar = SQR(KDumVar2 * KxVar ^ 2 + KDumVar1 * KyVar ^ 2 + KDumVar * (ExVar ^ 2 + EyVar ^ 2))
        KminVar = SQR(KDumVar1 * KxVar ^ 2 + KDumVar2 * KyVar ^ 2 + KDumVar * (ExVar ^ 2 + EyVar ^ 2))
    END IF
    KMean = ExxPyy / 2
    KMeanVar = .5 * SQR(Var * (RegMatInv(3, 3) + RegMatInv(6, 6)))
    Azimuth = .5 * (ATN(ExyPyx / -ExxMyy))
    Azimuth = Azimuth * AngConst
    IF ExxMyy > 0 THEN Azimuth = Azimuth + 90
    AzimuthVar = .5 * SQR(Var * ((RegMatInv(3, 3) + RegMatInv(6, 6)) * ExyPyx ^ 2 + (RegMatInv(4, 4) + RegMatInv(5, 5)) * ExxMyy ^ 2)) / (ExyPyx ^ 2 + ExxMyy ^ 2)
    AzimuthVar = AzimuthVar * AngConst
    Gmax = SQR(ExxMyy ^ 2 + ExyPyx ^ 2)
    GmaxVar = SQR(KmaxVar ^ 2 + KminVar ^ 2)
'    OPEN Name7$ FOR OUTPUT AS #2
    OPEN Nameout$ FOR OUTPUT AS #2
    PRINT #2, "NATIONAL TECHNICAL UNIVERSITY OF ATHENS"
    PRINT #2, "DIONYSO  SATELLITE OBSERVATORY"
    PRINT #2, "ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД"
    PRINT #2,
'   PRINT #2,
'   PRINT #2,
'   PRINT #2, "DATA FILE   : "; Name3$
'   PRINT #2, "OUTPUT FILE : "; Name7$
'   PRINT #2, "ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД"
'   PRINT #2,
    PRINT #2,
    PRINT #2, USING "&#####.###&"; "BLOCK CENTER's COORDINATES :  Xcen = "; XvalueCen * Kil; " Km"
    PRINT #2, USING "&#####.###&"; "                              Ycen = "; YvalueCen * Kil; " Km"
    PRINT #2,
'    PRINT #2,
'    PRINT #2, "ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД"
'    PRINT #2, "ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД"
    FOR i% = 1 TO n%
        CountBase% = CountBase%(i%)
        Code& = Code&(i%)
        XValue = XValue(i%) * Kil
        YValue = YValue(i%) * Kil
'        X = XValue + (XValueCen + XBaseCen) * Kil
'        Y = YValue + (YValueCen + YBaseCen) * Kil
        X = XValue + (XvalueCen) * Kil
        Y = YValue + (YvalueCen) * Kil
        DiffXValue = DiffXValue(i%)
        DiffYValue = DiffYValue(i%)
        DiffXComp = DiffXComp(i%)
        DiffYcomp = DiffYcomp(i%)
        XRes = XRes(i%)
        YRes = YRes(i%)
    NEXT
    PRINT #2, "ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД"
    PRINT #2,
    PRINT #2,
    PRINT #2, USING "&###.###&"; "A POSTERIORI STANDARD DEVIATION :   с "; StanDev * 100; "   in cm"
    PRINT #2,
    PRINT #2,
    PRINT #2, "DEFORMATION PARAMETERS :"
    PRINT #2, "ДДДДДДДДДДДДДДДДДДДДДДДД"
    PRINT #2,
    PRINT #2, USING "&####.###&###.###&"; "Shift :  Sx = "; Sx * 100; "   с"; 100 * SxVar; " in cm"
    PRINT #2, USING "&####.###&###.###&"; "         Sy = "; Sy * 100; "   с"; 100 * SyVar; " in cm"
    PRINT #2,
    PRINT #2,
    PRINT #2, USING "&####.###&###.###&"; "Rotation :        њx = "; Ex; "  с "; ExVar; " in ppm"
    PRINT #2, USING "&####.###&###.###&"; "                  њy = "; Ey; "  с "; EyVar; " in ppm"
    PRINT #2,
    PRINT #2, USING "&####.###&###.###&"; "Total rotation :  њ = "; ETotal; "  с "; ETotalVar; " in ppm"
    PRINT #2,
    PRINT #2,
    PRINT #2, USING "&####.###&###.###&"; "Scale :      Ўx = "; Kx; "  с "; KxVar; " in ppm"
    PRINT #2, USING "&####.###&###.###&"; "             Ўy = "; Ky; "  с "; KyVar; " in ppm"
    PRINT #2,
    PRINT #2, USING "&####.###&###.###&"; "          Ў max = "; Kmax; "  с "; KmaxVar; " in ppm"
    PRINT #2, USING "&####.###&###.###&"; "          Ў min = "; Kmin; "  с "; KminVar; " in ppm"
    PRINT #2,
    PRINT #2, USING "&####.###&###.###&"; "Mean scale :  Ў = "; KMean; "  с "; KMeanVar; " in ppm"
    PRINT #2,
    PRINT #2,
    PRINT #2, USING "&####.###&###.###&"; "Azimuth :    Az = "; Azimuth; "  с "; AzimuthVar; " in deg"
    PRINT #2,
    PRINT #2, USING "&####.###&###.###&"; "Strain  : љ max = "; Gmax; "  с "; GmaxVar; " in ppm"
    CLOSE
OPEN Name$ FOR INPUT AS #3
OPEN Nameout1$ FOR OUTPUT AS #4
        WHILE NOT EOF(3)
                INPUT #3, aa$, X, Y, dn, de, du
                Xdiff = (X / mil) - XvalueCen
                Ydiff = (Y / mil) - YvalueCen
                FunAffine2 ParMat(), Xdiff, Ydiff, dde, ddn
                dddn = dn + ddn
                ddde = de + dde
                PRINT #4, USING "\             \ ########.## #######.## ##.### ##.###"; aa$; X; Y; dddn; ddde
        WEND
        CLOSE
LOCATE 22, 2
'    PRINT "Press Y to continue with next block else any other key : ";
'    t$ = UCASE$(INPUT$(1))
'    IF t$ <> "Y" THEN EXIT DO
'LOOP

VIEW PRINT 1 TO 25
CLS
END

SUB FunAffine1 (s(), X, Y, XDiffComp, YDiffComp) STATIC
    XDiffComp = s(1, 1) + s(1, 3) * X + s(1, 4) * Y
    YDiffComp = s(1, 2) - s(1, 4) * X + s(1, 3) * Y
END SUB

SUB FunAffine2 (s(), X, Y, XDiffComp, YDiffComp) STATIC
    XDiffComp = s(1, 1) + s(1, 3) * X + s(1, 4) * Y
    YDiffComp = s(1, 2) + s(1, 5) * X + s(1, 6) * Y
END SUB

SUB matinv (a(), ainv(), c%) STATIC
    DIM b(c%, c%)
        FOR i% = 1 TO c%
            FOR j% = 1 TO c%
                IF i% = j% THEN b(i%, j%) = 1 ELSE b(i%, j%) = 0
            NEXT
        NEXT
    FOR r% = 1 TO c% - 1
        FOR i% = r% TO c% - 1
            P = a(i% + 1, r%) / a(r%, r%)
            FOR j% = r% + 1 TO c%
                a(i% + 1, j%) = a(i% + 1, j%) - P * a(r%, j%)
            NEXT
            FOR t% = 1 TO c%
                b(i% + 1, t%) = b(i% + 1, t%) - P * b(r%, t%)
            NEXT
        NEXT
    NEXT
    FOR s% = 1 TO c%
        FOR m% = c% TO 1 STEP -1
            IF m% <> c% THEN
                FOR l% = c% TO m% + 1 STEP -1
                    b(m%, s%) = b(m%, s%) - a(m%, l%) * ainv(l%, s%)
                NEXT
            END IF
            ainv(m%, s%) = b(m%, s%) / a(m%, m%)
        NEXT
    NEXT
    ERASE b
END SUB

SUB matmul (a1(), a2(), a3(), o%, c%, h%) STATIC
    sum = 0
    FOR i% = 1 TO c%
        FOR j% = 1 TO h%
            FOR r% = 1 TO o%
                sum = sum + a1(r%, i%) * a2(j%, r%)
            NEXT
            a3(j%, i%) = sum
            sum = 0
        NEXT
    NEXT
END SUB

