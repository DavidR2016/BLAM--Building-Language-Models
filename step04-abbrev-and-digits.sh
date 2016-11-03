#!/bin/bash
# Step 04
#	- lowercase ALLCAPS-words
#	- Write out abbreviations  	
#	- Write out digits and numbers
#
# This script ... 
# * needs user interaction only at the start to confirm variables
# *  Uses:
#	- GNU Parallel - The Command-Line Power Tool, The USENIX Magazine, February 2011:42-47.
#	- Perl scripts:   anti-ALLCAPS-makelist.pl     anti-ALLCAPS.pl
#	- Python script:  tts_normalizer.py


clear
echo Check the following variables before running this script:
echo ---------------------------------------------------------
BASEDIR=/home/petri/tekskorpora
WORKDIR=$BASEDIR/NWU-studiegidse
SCRIPTDIR=$WORKDIR/scripts
TOOLDIR="$SCRIPTDIR/standalone_tts_normalizer"
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
#  TODO: Change the script itself to us these variables
#  NOTE: Currently there is a separate script for the d-variant data
#STEPINDIR=step03.outdir
#STEPINDIR=step03d.outdir
#STEPOUTDIR=step04.outdir
#STEPOUTDIR=step04d.outdir



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
# read 

# Generate a concatenated alltext file per language from the output of the previous step
# The generate a vocabulary from that file.
# This vocabulary will be used by the anti-ALLCAPS.pl script called later 
# to distinguish between ACRONYMS and other words in ALLCAPS HEADINGS
# This only needs to be done once for as many text as possible from the previous step.
# That is why the variables YEARLIST and FLIST are not used
ALLFLIST="P_11  P_12  P_13  P_14  P_15  P_16  P_17  P_18  V_1907  V_1908"

for L in $LANGLIST; do
   if [ -f "$WORKDIR/step03.$L.alltxt.vocab" ] ; then
	echo "The following file exists and will be used in this script: $WORKDIR/step03.$L.alltxt.vocab"
   else 
   	echo "The following file will be created and used in this script: $WORKDIR/step03.$L.alltxt.vocab"
	echo "It can be kept for future runs so that it does not have to be created again"
	echo "Press Enter to continue"
#	read
	# Firstly get all the text in one file
	TEMPFILE="$WORKDIR/step03.$L.alltxt"
	rm -f $TEMPFILE
	echo Creating $TEMPFILE
	for Y in $YEARLIST; do
		for SUBDIR in $ALLFLIST; do
			INDIR="$WORKDIR/nwu-sg-$Y/step03.outdir/$SUBDIR/$L.txt"
			find "$INDIR" -type f -name "*.txt" | xargs -I '{}' cat {} >> $TEMPFILE
		done
	done
	# Secondly generate a vocab file
     	VOCABFILE="$WORKDIR/step03.$L.alltxt.vocab"
	echo Creating $VOCABFILE
	perl $SCRIPTDIR/anti-ALLCAPS-makelist.pl $TEMPFILE $VOCABFILE 
	
   fi
done  # L


# Now begin with step04 


for L in $LANGLIST; do
   VOCABFILE="$WORKDIR/step03.$L.alltxt.vocab"
   for Y in $YEARLIST; do
	# Step 04a
	echo "Starting with Step 04a - anti-ALLCAPS for language $L in year $Y"
	INDIR="$WORKDIR/nwu-sg-$Y/step03.outdir"
	OUTDIR="$WORKDIR/nwu-sg-$Y/step04a.outdir"
	mkdir -p $OUTDIR

	for SUBDIR in $FLIST; do
		TEMPLIST="$OUTDIR/$SUBDIR/$L-list.tmp"
		mkdir -p $OUTDIR/$SUBDIR/$L.txt
		find "$INDIR/$SUBDIR/$L.txt" -type f -name "*.txt" -printf "%f\n" > $TEMPLIST
		# Ru
		perl $SCRIPTDIR/anti-ALLCAPS.pl $VOCABFILE $TEMPLIST $INDIR/$SUBDIR/$L.txt $OUTDIR/$SUBDIR/$L.txt $MINCOUNT &
	done

	# Step 04b
	echo "Starting with Step 04b - tts_normalizer.py for language $L in year $Y"
	INDIR="$WORKDIR/nwu-sg-$Y/step04a.outdir"
	OUTDIR="$WORKDIR/nwu-sg-$Y/step04b.outdir"
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



