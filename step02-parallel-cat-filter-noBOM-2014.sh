#!/bin/bash
# Step 02  	- Clean unwanted (hidden) control characters with filter. 
#  		  then Clear BOM if it exists in output files: 
#			perl -i -pe 's/^\x{FFFE}//' $OUTDIR/{} "
#		- Then cat files together per faculty and gzip


clear
echo Check the following variables before running this script:
echo ---------------------------------------------------------
BASEDIR=/home/petri/tekskorpora
WORKDIR=$BASEDIR/NWU-studiegidse
SCRIPTDIR=$WORKDIR/scripts
FILTER="$SCRIPTDIR/strip-unwanted-chars.pl";

LANGLIST="Afr Eng"
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
echo FILTERSCRIPT = $FILTER
echo 
echo Press Ctrl-C to stop or Enter to continue
read


for L in $LANGLIST; do
   for Y in $YEARLIST; do

	INDIR="$WORKDIR/nwu-sg-$Y/step01.outdir"
	OUTDIR="$WORKDIR/nwu-sg-$Y/step02.outdir"

	rm -f "$OUTDIR/step02.txt" # remove output from previous run
	rm -f "$OUTDIR/step02.txt.charlist" # remove output from previous run

	for SUBDIR in $FLIST; do

	   mkdir -p "$OUTDIR/$SUBDIR/$L.txt"
	   rm -f "$OUTDIR/$SUBDIR.step02.txt*" # remove output from previous run
	   cd $INDIR
	   # Note: {} starts with $SUBDIR included
	   find "$SUBDIR" -type f -name "*.txt" | parallel \
			"cat $INDIR/{}  | $FILTER > $OUTDIR/{} 
			echo Clear BOM if it exists from {} 
			perl -i -pe 's/^\x{FFFE}//' $OUTDIR/{} "
	 	cat $OUTDIR/$SUBDIR/$L.txt/*.txt >> $OUTDIR/$SUBDIR.step02.$L.txt 
	   	cat $OUTDIR/$SUBDIR*.txt >> $OUTDIR/step02.$L.txt
		gzip -f $OUTDIR/$SUBDIR.step02.$L.txt
	done   #done SUBDIR

	echo Creating a list of characters. Please wait.
	$SCRIPTDIR/create_vocab_charlist.pl "$OUTDIR/step02.$L.txt" 0 "$OUTDIR/step02.$L.txt.charlist"
	echo "List of characters written to $OUTDIR/step02.$L.txt.charlist"
	echo "Creating a list of words (vocabulary). Please wait."
	$SCRIPTDIR/create_vocab.pl "$OUTDIR/step02.$L.txt" 0 "$OUTDIR/step02.$L.txt.vocab"
	echo "List of characters written to $OUTDIR/step02.$L.txt.vocab"

   done
done

#echo "press ENTER to view the list of characters used in the step02 files with less"
#read
#less "$OUTDIR/step02.txt.charlist"

