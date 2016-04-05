#!/bin/bash
echo "start installation for GeoToolbox"
if ! [ -x "$(command -v matlab)" ]
then
	echo 'MATLAB is not installed. Install MATLAB and then run GeoToolbox' >&2
else 
	pth2mtlb=$(which matlab)
	echo "MATLAB path :" $pth2mtlb
	pth2GTb=$(pwd)
	pth2inputdir=$pth2GTb/input/
	pth2outputdir=$pth2GTb/output/
    if [ -d "$pth2inputdir" -a -d "$pth2outputdir" ]; then
	pth2pathdef=$pth2GTb/pathdef.m
	cp .GeoTool GeoTool.m
	cp .runGTb runGTb.sh
	sed -i "s|pth2GTb|${pth2GTb}|g" "runGTb.sh"
	sed -i "s|pth2inputdir|${pth2inputdir}|g" "GeoTool.m"
	sed -i "s|pth2outputdir|${pth2outputdir}|g" "GeoTool.m"
#	gnome-terminal -x $pth2mtlb -nodisplay -nodesktop -r "addpath(genpath('$pth2GTb'));savepath;quit;"
	$pth2mtlb -nodisplay -nodesktop -r "addpath(genpath('$pth2GTb'));savepath '$pth2pathdef';quit;"
	echo "GeoTool dir set to : ${pth2GTb}"
	echo "Input dir set to : ${pth2inputdir}"
	echo "Output dir set to : ${pth2outputdir}"
	echo "execute matlab file GeoTool.m"

	echo "Finished succesfully"
    else
	echo "Check Folder input and output"
	exit 1
    fi
fi
