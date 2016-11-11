#!/bin/bash
# Step 02  	- Clean unwanted (hidden) control characters with filter. 
#  		  then Clear BOM if it exists in output files: 
#			perl -i -pe 's/^\x{FFFE}//' $OUTDIR/{} "
#		- Then cat files together per faculty and gzip


clear
echo Check the following variables before running this script:
echo ---------------------------------------------------------
BASEDIR=/home2/davidr/petri/tekskorpora
WORKDIR=$BASEDIR/NWU-studiegidse
SCRIPTDIR=$WORKDIR/scripts
FILTER="$SCRIPTDIR/strip-unwanted-chars.pl";

YEARLIST="2015 2016"

#LANGLIST="Afr Eng"

#FLIST="P_11  P_12  P_13  P_14  P_15  P_16  P_17  P_18  V_1907  V_1908  M_9010 M_9040 M_9100 M_9230 M_9240"

echo BASEDIR = $BASEDIR
echo WORKDIR = $WORKDIR
echo SCRIPTDIR = $SCRIPTDIR
#echo Study guide language = $LANGLIST
echo YEARLIST = $YEARLIST
#echo $FLIST
echo
echo 
#echo Press Ctrl-C to stop or Enter to continue
#read

# Create output directories to match the input directories
for Y in $YEARLIST; do
   INDIR="$WORKDIR/nwu-sg-$Y/step01.outdir"
   OUTDIR="$WORKDIR/nwu-sg-$Y/step02.outdir"
   OUTDIR3="$WORKDIR/nwu-sg-$Y/step03.outdir"
   cd $INDIR
   mkdir -p `find . -type d -printf "$OUTDIR/%p " `
   mkdir -p `find . -type d -printf "$OUTDIR3/%p " `
done


for Y in $YEARLIST; do
   INDIR="$WORKDIR/nwu-sg-$Y/step01.outdir"
   OUTDIR="$WORKDIR/nwu-sg-$Y/step02.outdir"
   OUTDIR3="$WORKDIR/nwu-sg-$Y/step03.outdir"

	   cd $INDIR
	   # Note: {} starts with $SUBDIR included
	   find . -type f -name "*.txt" | parallel \
			"cat $INDIR/{}  | $FILTER > $OUTDIR/{} 
			echo Clear BOM if it exists from {} 
			perl -i -pe 's/^\x{FFFE}//' $OUTDIR/{} 
		 	$SCRIPTDIR/normalise-apostrophe-and-diacritics.pl $OUTDIR/{} $OUTDIR3/{} "
done #YEAR

