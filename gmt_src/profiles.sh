#!/bin/bash
gmt gmtset FORMAT_DATE_IN yyyy-mm-dd

gmt gmtset FORMAT_DATE_MAP o
gmt gmtset FONT_ANNOT_PRIMARY +10p
gmt gmtset FORMAT_TIME_PRIMARY_MAP abbreviated
gmt gmtset PS_CHAR_ENCODING ISOLatin1+

source default-param
inputf=$1
EQPROJ=1
prclon=$2
prclat=$3
praz=$4
prlmin=$5
prlmax=$6
prwmin=$7
prwmax=$8
prmagn=$9
outfile=outputp.eps
out_jpg=outputp.jpg

pth2valong=${pth2inptf}/profile40_along.vel
pth2vtranv=${pth2inptf}/profile40_tranv.vel
	range="-R$west/$east/$south/$north"
	proj="-Jm24/37/1:1500000"

gmt	psbasemap $range $proj $scale -B$frame:."$maptitle": -P -K -Y12c> $outfile
gmt	pscoast -R -J -O -K -W0.25 -G225 -Df -Na>> $outfile
gmt	psxy $pth2faults -R -J -O -K  -W.5,204/102/0  >> $outfile
awk 'NR != 1 {print $1,$2,$3,$4,0,0,0,$8}' $pth2vtranv | gmt psvelo -R -Jm -Se${VSC}/0.95/0 -W2p,red -A10p+e -Gred -O -K -L -V >> $outfile  # 205/133/63.
awk 'NR != 1 {print $1,$2,$3,$4,0,0,0,$8}' $pth2valong | gmt psvelo -R -Jm -Se${VSC}/0.95/0 -W2p,blue -A10p+e -Gblue -O -K -L -V >> $outfile  # 205/133/63.

###scale
# # echo "$vsclon $vsclat $vscmagn 0 0 0 0 $vscmagn mm" | gmt psvelo -R -Jm -Se${VSC}/0.95/10 -W2p,blue -A10p+e -Gblue -O -K -L -V >> $outfile
# echo "22.48 37.16 $vscmagn 0 1 1 0 $vscmagn mm" | gmt psvelo -R -J -Se${VSC}/0.95/0 -W.5p,50 -A10p+e -Gblue -O -K -L -V >> $outfile
# echo "22.48 37.16 $vscmagn 0 0 0 0 $vscmagn mm" | gmt psvelo -R -J -Se${VSC}/0.95/0 -W2p,blue -A10p+e -Gblue -O -K -L -V >> $outfile
# 
# echo "22.48 37.11 $vscmagn 0 1 1 0 $vscmagn mm" | gmt psvelo -R -J -Se${VSC}/0.95/0 -W.5p,50 -A10p+e -Gblue -O -K -L -V >> $outfile
# echo "22.48 37.11 $vscmagn 0 0 0 0 $vscmagn mm" | gmt psvelo -R -J -Se${VSC}/0.95/0 -W2p,red -A10p+e -Gblue -O -K -L -V >> $outfile
# echo "22.45 37.15 8 0 1 LB $vscmagn \261 1 mm/y" | gmt pstext -J -R -Dj-.3c/0.5c  -O -K -V>> $outfile
# echo "22.48 37.16 8 0 1 RM Az = +  40\260" | gmt pstext -J -R -Dj0.4c/0.3c -Gwhite -O -K -V>> $outfile
# echo "22.48 37.11 8 0 1 RM Az = + 130\260" | gmt pstext -J -R -Dj0.4c/0.3c -Gwhite -O -K -V>> $outfile







# plot up component
# gmt psbasemap $Rup -JX10i/2i -K -Bsx1O -Bpxa1df12H -Bpy${a_up}+l"DUp (mm)" \
#   -BWSen+t"RedHat (RHT) Stock Price Trend since IPO"+gpalegreen > $ps
# gmt psxy -R -J -Sc.2 -Gblack -W1.4p,red -O -K .${station}.up >> $ps ## plot points
# gmt psxy -R -J -Wthin,150 -O -K .${station}.up >> $ps ## plot line
# ##  plot seismic events
# sun=$(echo $Rup | awk -F/ '{print $3}')
# nun=$(echo $Rup | awk -F/ '{print $4}')
# echo "
# 2015-11-17T07:10:07 $sun
# 2015-11-17T07:10:07 $nun
# " | gmt psxy -R -J -W1.6p,red -O -K  >> $ps

# ////////////////////////////////////////////////////PLOT PROJECTION!!! ////////////////////////////////
if [ "$EQPROJ" -eq 1 ]
then
	# awk '{print($8,$7,$9)}' tmp-eq45 | project -C21/36 -A90 -W-1/1 -L0/4 > projection.dat
	awk -F, ' NR>1 {print$3,$2,$4*-1}' $inputf | gmt project -C${prclon}/${prclat} -A${praz} -Fxyzpqrs -W${prwmin}/${prwmax} -L${prlmin}/${prlmax}  -V -Q> projection.dat
	awk '{print $1, $2}' projection.dat | gmt psxy -R -J -O -K -Sc0.1 -G0/0/0 >>$outfile
	awk '{print $6,$7}' projection.dat | gmt psxy -R -J -O -K -Sc0.1 -G0/0/255 >>$outfile

	west=${prlmin}
	east=${prlmax}
	dmin=0 
	dmax=$prmagn

	proj=-JX15.5/5
	tick=-B50:Distance\(km\):/10::WSen
	# proj="-Jx0.2/0.2"
	# tick="-Ba5f5g0/a5f5g0"
	R="-R$west/$east/$dmin/$dmax"
# gmt psbasemap $R $proj -K -P  -Bpy10+l"V - Az=40\260 (mm/y)" \
#   -BWSen+t"Profile Velocities tests"+gpalegreen > $outfile
# 	awk '{print $4,$3}' projection.dat | gmt psxy -R -J $tick -W1 -Sc.1 -G200 -O  -P >> $outfile
	
	awk '{print $4,$3}' projection.dat | gmt psxy $R $proj $tick -W1 -Sc.1 -G200 -O  -P -Y-6c >> $outfile
	
fi
	gs -sDEVICE=jpeg -dJPEGQ=100 -dNOPAUSE -dBATCH -dSAFER -r300 -sOutputFile=$out_jpg $outfile
