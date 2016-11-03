#!/bin/bash
# Step 04
#	- lowercase ALLCAPS-words
#	- Write out abbreviations  	
#	- Write out digits and numbers
#


clear
echo Check the following variables before running this script:
echo ---------------------------------------------------------
echo
echo THIS SCRIPT IS 4d which is run in the step sequence: 1-2-3-4a-3d-4d
echo "It is a (slightly) modified version of the 4b part of the step04 script"

BASEDIR=/home/petri/tekskorpora
WORKDIR=$BASEDIR/NWU-studiegidse
SCRIPTDIR=$WORKDIR/scripts
TOOLDIR="$SCRIPTDIR/standalone_tts_normalizer"
MINCOUNT=1

#LANGLIST="Afr Eng"
LANGLIST="Afr"
#YEARLIST="2011 2012 2013"
YEARLIST="2014"

#FLIST="00_testdir"
FLIST="P_11  P_12  P_13  P_14  P_15  P_16  P_17  P_18  V_1907  V_1908"

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
read 


# Now begin with step04 d


for L in $LANGLIST; do
      for Y in $YEARLIST; do
	
	# Step 04 d
	echo "Starting with Step 04 d - tts_normalizer.py for language $L in year $Y"
	INDIR="$WORKDIR/nwu-sg-$Y/step03d.outdir"
	OUTDIR="$WORKDIR/nwu-sg-$Y/step04d.outdir"
	mkdir -p $OUTDIR
	if [ $L = "Afr" ] ; then NORMLANG="afrikaans";
	  elif [ $L = "Eng" ] ; then NORMLANG="english";
	  else NORMLANG="unknown";
	fi
	for SUBDIR in $FLIST; do
		mkdir -p $OUTDIR/$SUBDIR/$L.txt
		cd $TOOLDIR
		find "$INDIR/$SUBDIR/$L.txt" -type f -name "*.txt" -printf "%f\n" \
		|  parallel python tts_normalizer.py $NORMLANG  "$INDIR/$SUBDIR/$L.txt/"{} "$OUTDIR/$SUBDIR/$L.txt/"{} 
	done   #SUBDIR
   done #L
done #Y



