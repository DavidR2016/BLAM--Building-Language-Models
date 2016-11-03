#!/bin/bash
# Step 03  

set -eu	

BASEDIR="/home/petri/tekskorpora/NWU-studiegidse/nwu-sg-2012"
clear
echo Check the following variables before running this script:
echo ---------------------------------------------------------
BASEDIR=/home/petri/tekskorpora
WORKDIR=$BASEDIR/NWU-studiegidse
SCRIPTDIR=$WORKDIR/scripts
INSTEPDIR="step04a.outdir"
OUTSTEPDIR="step03d.outdir"

LANGLIST="Afr Eng"
YEARLIST="2014"

#FLIST="00_testdir"
FLIST="P_11  P_12  P_13  P_14  P_15  P_16  P_17  P_18  V_1907  V_1908"

# First check the existence of the input directories
for Y in $YEARLIST; do
   for L in $LANGLIST; do
	for SUBDIR in $FLIST; do
		INDIR="$WORKDIR/nwu-sg-$Y/$INSTEPDIR/$SUBDIR/$L.txt"
		if [ ! -d $INDIR ]; then 
			echo "$INDIR does not exist"
		fi
	done
   done
done

echo BASEDIR = $BASEDIR
echo WORKDIR = $WORKDIR
echo SCRIPTDIR = $SCRIPTDIR
echo Study guide language = $LANGLIST
echo YEARLIST = $YEARLIST
echo Faculties to be processed for each year:
echo $FLIST
echo Where faculty names are as follows: 
echo P_11=Lettere  P_12=NW  P_13=Teologie  P_14=OPV  P_15=EW  P_16=REG  P_17=ING  P_18=PHARM  V_1907=BW-EDU  V_1908=EW-IT
echo
echo 
echo Press Ctrl-C to stop or Enter to continue
#read TMP

for Y in $YEARLIST; do
   for L in $LANGLIST; do
	for SUBDIR in $FLIST; do
		INDIR="$WORKDIR/nwu-sg-$Y/$INSTEPDIR/$SUBDIR/$L.txt"
		OUTDIR="$WORKDIR/nwu-sg-$Y/$OUTSTEPDIR/$SUBDIR/$L.txt"
		mkdir -p $OUTDIR
   		find $INDIR -type f -name "*.txt" -printf "%P\0" | parallel -0 "echo Processing {} ; perl $SCRIPTDIR/drop-non-sentences.pl $INDIR/{} $OUTDIR/{} "
	done
   done
done   



