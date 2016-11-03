#!/bin/bash
# Step 05
#		- Cleanup unwanted chracters after tts_normalizer is done
#	  	- cat into one file per faculty
#	   	
clear
echo Check the following variables before running this script:
echo ---------------------------------------------------------
echo
echo THIS SCRIPT IS 05 which is run after step4 or step4d 

BASEDIR=/home/petri/tekskorpora
WORKDIR=$BASEDIR/NWU-studiegidse
SCRIPTDIR=$WORKDIR/scripts
FILTER="$SCRIPTDIR/post-tts-cleanup.pl"
MINCOUNT=1

# To test this script on a small data subset, 
# change the commenting of the folowing pairs of lines 

#FLIST="00_testdir"
FLIST="P_11  P_12  P_13  P_14  P_15  P_16  P_17  P_18  V_1907  V_1908"

#LANGLIST="Afr"
LANGLIST="Afr Eng"

#YEARLIST="2011"
YEARLIST="2011 2012 2013 2014"

# Choose the variant (d or not) of input/output data
STEPINDIR=step04.outdir
#STEPINDIR=step04d.outdir
STEPOUTDIR=step05.outdir
#STEPOUTDIR=step05d.outdir

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
echo FILTERSCRIPT = $FILTER
echo
echo STEPINDIR = $STEPINDIR
echo STEPOUTDIR = $STEPOUTDIR
echo 
echo Press Ctrl-C to stop or Enter to continue
read 

for L in $LANGLIST; do
   for Y in $YEARLIST; do

	INDIR="$WORKDIR/nwu-sg-$Y/$STEPINDIR"
	OUTDIR="$WORKDIR/nwu-sg-$Y/$STEPOUTDIR"

	rm -f "$OUTDIR/$STEPOUTDIR.$L.txt"  # remove output from previous run

	for SUBDIR in $FLIST; do

	   mkdir -p "$OUTDIR/$SUBDIR/$L.txt"
	   cd $INDIR
	   # Note: {} starts with $SUBDIR included
	   find "$SUBDIR" -type f -name "*.txt" | parallel \
			"cat $INDIR/{}  | $FILTER > $OUTDIR/{} "
	   # Now cat together and zip this faculty
	   rm -f $OUTDIR/$SUBDIR/$STEPOUTDIR.$L.txt # remove output from previous run
	   cat $OUTDIR/$SUBDIR/$L.txt/*.txt > $OUTDIR/$SUBDIR/$STEPOUTDIR.$L.txt # cat per faculty
	   cat $OUTDIR/$SUBDIR/$STEPOUTDIR.$L.txt >> $OUTDIR/$STEPOUTDIR.$L.txt # append to the file in higher subdir 
	   gzip -f  $OUTDIR/$SUBDIR/$STEPOUTDIR.$L.txt   # compress this faculty
	done   #done SUBDIR


	echo Creating a list of characters. Please wait.
	$SCRIPTDIR/create_vocab_charlist.pl "$OUTDIR/$STEPOUTDIR.$L.txt" 0 "$OUTDIR/$STEPOUTDIR.$L.txt.charlist"
	echo "List of characters written to $OUTDIR/$STEPOUTDIR.$L.txt.charlist"
	echo "Creating a list of words (vocabulary). Please wait."
	$SCRIPTDIR/create_vocab.pl "$OUTDIR/$STEPOUTDIR.$L.txt" 0 "$OUTDIR/$STEPOUTDIR.$L.txt.vocab"
	echo "List of characters written to $OUTDIR/step05.$L.txt.vocab"

  	gzip -f $OUTDIR/$STEPOUTDIR.$L.txt

   done
done




