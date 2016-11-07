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

LANGLIST="Afr Eng"
YEARLIST="2015 2016"

#FLIST="00_testdir"
FLIST="P_11  P_12  P_13  P_14  P_15  P_16  P_17  P_18  V_1907  V_1908  M_9010 M_9040 M_9100 M_9230 M_9240"

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

date > starting-time-step02.txt

for Y in $YEARLIST; do
   INDIR="$WORKDIR/nwu-sg-$Y/step01.outdir"
   OUTDIR="$WORKDIR/nwu-sg-$Y/step02.outdir"

   rm -f "$OUTDIR/step02.txt" # remove output from previous run
   rm -f "$OUTDIR/step02.txt.charlist" # remove output from previous run

   for SUBDIR in $FLIST; do
	rm -f "$OUTDIR/$SUBDIR.step02.txt*" # remove output from previous run

	for L in $LANGLIST; do

	   mkdir -p "$OUTDIR/$SUBDIR/$L.txt"
	   cd $INDIR
	   # Note: {} starts with $SUBDIR included
	   find "$SUBDIR/$L.txt" -type f -name "*.txt" | parallel \
			"cat $INDIR/{}  | $FILTER > $OUTDIR/{} 
			echo Clear BOM if it exists from {} 
			perl -i -pe 's/^\x{FFFE}//' $OUTDIR/{} "
	done #L
   done   #done SUBDIR
done #YEAR

# Collect text per year, faculty, language and compress
   
for Y in $YEARLIST; do
   INDIR="$WORKDIR/nwu-sg-$Y/step01.outdir"
   OUTDIR="$WORKDIR/nwu-sg-$Y/step02.outdir"

   # Remove output per year
   for L in $LANGLIST; do
	rm -f "$OUTDIR/step02.$L.txt" # remove output from previous run
	rm -f "$OUTDIR/step02.$L.txt.charlist" # remove output from previous run
   	echo "# Removing previous collected output per faculty"
   	for SUBDIR in $FLIST; do
	   echo "rm -f $OUTDIR/$SUBDIR.step02.$L.txt"
	   rm -f "$OUTDIR/$SUBDIR.step02.$L.txt" # remove output from previous run
	done
   done

   # Collect per faculty and language
   echo "# Collecting per faculty and language"
   for SUBDIR in $FLIST; do
	for L in $LANGLIST; do
	   echo "$OUTDIR/$SUBDIR.step02.$L.txt"
	   cat $OUTDIR/$SUBDIR/$L.txt/*.txt >> $OUTDIR/$SUBDIR.step02.$L.txt 
	   cat $OUTDIR/$SUBDIR/$L.txt/*.txt >> $OUTDIR/step02.$L.txt 
	done
   done

   for L in $LANGLIST; do
      echo Creating a list of characters. Please wait.
      $SCRIPTDIR/create_vocab_charlist.pl "$OUTDIR/step02.$L.txt" 0 "$OUTDIR/step02.$L.txt.charlist"
      echo "List of characters written to $OUTDIR/step02.$L.txt.charlist"
      echo "Creating a list of words (vocabulary). Please wait."
      $SCRIPTDIR/create_vocab.pl "$OUTDIR/step02.$L.txt" 0 "$OUTDIR/step02.$L.txt.vocab"
      echo "List of characters written to $OUTDIR/step02.$L.txt.vocab"
   done

   # Optional compressing of collected data
	#   rm -f $OUTDIR/*.gz # remove output from previous run
	#   for L in $LANGLIST; do
	#	gzip -f "$OUTDIR/step02.$L.txt"
	#   	for SUBDIR in $FLIST; do
	#   	   gzip -f "$OUTDIR/$SUBDIR.step02.$L.txt"
	#	done
	#   done

done # End of loop for collecting per YEAR

#echo "press ENTER to view the list of characters used in the step02 files with less"
#read
#less "$OUTDIR/step02.txt.charlist"

