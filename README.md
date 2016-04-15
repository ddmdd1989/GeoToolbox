# GeoToolbox
Matlab subToolbox for Geodesy and geodynamics

# Introduction
This repository includes bash script to call MATLAB functions for geodynamic applications.
MATLAB functions:
- Calculate velocity field of surfaces.
- Create profile of velocity field
- Calculate strain tensor parameters (algorithm after Veis et al. (1992))
- Calculate grid data for strain tensors

**Structure**

- functions: all matlab source placed here
- gmt_src: gmt script to plot your results
- input: input files
- output: output files
- install.sh: installation bash script
- clear.sh: clear installation

**INSTALLATION**

run $ ./install.sh 

MATLAB must have already installed in your machine

After a succesfull installation two scripts must be in your directory:

- GeoTool.m: Main matlab script
- runGTb.sh: bash script call GeoTool.m

**run GeoToolbox**
---

**INPUT FILES**

input file for velocities, use mm for velocities and uncertenties
also use comma(,) as delimiter
```
code, lat, lon, alt, vN, svN, vE, svE, vU, svU
```
**RUN GeoTool**

Run main Script
```
$ ./runGTb.sh
```

GeoTool will open in a new commant line.

It will ask you to select your region... all output files will start with this string.
```
Give the region of your work : 
```

Second screen will ask for the function you would like to use
```
    Region of the Study : test
   ======================================================
   |   1 : Velocities                                   |
   |   2 : Allignment                                   |
   |   3   1D strain rate (baselines)                   |
   |   4 : StrainTensor                                 |
   |   5 : GridData                                     |
   |  ------------------------                          |
   |  10 : Plot scripts                                 |
   |   0 : EXIT                                         |
   ======================================================
...select your work : 
```
Then you can follow the instruction displayed in the next screens.

**OUTPUT FILES**

many files!! will be udated!


----------


# Updates

- 21 Feb 2016: First release of GeoToolbox

# References

Veis, G., Billiris, H., Nakos, B., and Paradissis, D. (1992). Tectonic strain in greece from geodetic measurements. C.R.Acad.Sci.Athens, 67:129--166.

Wessel, P., W. H. F. Smith, R. Scharroo, J. F. Luis, and F. Wobbe (2013) Generic Mapping Tools: Improved version released, EOS Trans. AGU, 94, 409-410.

# Contact

Demitris Anastasiou, danast@mail.ntua.gr

Xanthos Papanikolaou, xanthos@mail.ntua.gr

















