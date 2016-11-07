#!/bin/bash
# Step 03  	Normalise apostrophe and diacritics

# This script ... 
# * needs user interaction only at the start to confirm variables
# * was tested with: GNU Parallel - The Command-Line Power Tool, The USENIX Magazine, February 2011:42-47.
# * repeatedly calls: $SCRIPTDIR/normalise-apostrophe-and-diacritics.pl


clear
echo Check the following variables before running this script:
echo ---------------------------------------------------------
BASEDIR=/mnt/data2/home2/davidr/petri/tekskorpora
WORKDIR=$BASEDIR/NWU-studiegidse
SCRIPTDIR=$WORKDIR/scripts

# To test this script on a small data subset, 
# change the commenting of the folowing pairs of lines 

#FLIST="00_testdir"
FLIST="P_11  P_12  P_13  P_14  P_15  P_16  P_17  P_18  V_1907  V_1908 M_9010 M_9040 M_9100 M_9230 M_9240"

#LANGLIST="Afr"
LANGLIST="Afr Eng"

#YEARLIST="2011"
YEARLIST="2015 2016"
#YEARLIST="2011 2012 2013 2014 2015 2016"


echo BASEDIR = $BASEDIR
echo WORKDIR = $WORKDIR
echo SCRIPTDIR = $SCRIPTDIR
echo Study guide language = $LANGLIST
echo YEARLIST = $YEARLIST
echo Faculties to be processed for each year:
echo $FLIST
#echo Where faculty names are as follows: 
#echo P_11=Lettere  P_12=NW  P_13=Teologie  P_14=OPV  P_15=EW  P_16=REG  P_17=ING  P_18=PHARM  V_1907=BW-EDU  V_1908=EW-IT
echo
echo 

#echo Press Ctrl-C to stop or Enter to continue
#read

echo "Creating empty output directories:"
for Y in $YEARLIST; do
   OUTDIR="$WORKDIR/nwu-sg-$Y/step03.outdir"
   for SUBDIR in $FLIST; do
      for L in $LANGLIST; do
           echo "$OUTDIR/$SUBDIR/$L.txt"
	   mkdir -p $OUTDIR/$SUBDIR/$L.txt
      done
   done
done

for Y in $YEARLIST; do
   for SUBDIR in $FLIST; do
	INDIR="$WORKDIR/nwu-sg-$Y/step02.outdir"
	OUTDIR="$WORKDIR/nwu-sg-$Y/step03.outdir"
	rm -f "$OUTDIR/step03.txt" # remove output from previous run
	rm -f "$OUTDIR/step03.txt.charlist" # remove output from previous run
        for L in $LANGLIST; do
   	   cd $INDIR
   	   find "$SUBDIR/$L.txt" -type f -name "*.txt" | parallel \
		"echo LANG = $L.   Processing {} ...
		 $SCRIPTDIR/normalise-apostrophe-and-diacritics.pl $INDIR/{} $OUTDIR/{} "
	   # Note: the script called here could take into account the language of the study guide Afr/Eng
	done #L  
   done #SUBDIR
done #Y



