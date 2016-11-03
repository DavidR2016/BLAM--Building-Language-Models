#!/bin/bash
# Step 02  	- Clean unwanted (hidden) control characters.  (currently only check for BOM at start of each file)
#		- Then cat files together per faculty
clear
echo Check the following variables before running this script:
echo ---------------------------------------------------------

FILTER="/home/corpusadmin/textcorpora/study_guides_per_faculty/scripts/strip-unwanted-chars.pl";

BASEDIR=/home/petri/tekskorpora
WORKDIR=$BASEDIR/NWU-studiegidse
SCRIPTDIR=$WORKDIR/scripts
YEARLIST="2011 2012 2013"
#FOR REFERENCE TO FACULTY NAMES: P_11_Lettere  P_12_NW  P_13_Teologie  P_14_OPV  P_15_EW  P_16_REG  P_17_ING  P_18_PHARM  V_1907_BW-EDU  V_1908_EW-IT
#FLIST="P_11  P_12  P_13  P_14  P_15  P_16  P_17  P_18  V_1907  V_1908"
FLIST="00_testdir"
LANGLIST="Afr Eng"
OUTDIR="step02.outdir"


echo BASEDIR = $BASEDIR
echo WORKDIR = $WORKDIR
echo SCRIPTDIR = $SCRIPTDIR
echo Years = $YEARLIST
echo Faculties = $FLIST
echo Study guide languages = $LANGLIST

for SGLANG in $LANGLIST; do
   for Y in $YEARLIST; do
	for F in $FLIST; do
	mkdir -p $OUTDIR/$SUBDIR/$SGLANG.txt
   rm "$OUTDIR/$SUBDIR.step02.txt" # remove output from previous run
   cd $INDIR
   find "$SUBDIR/Afr.txt" -type f -name "*.txt" | while read FILENAME
	do
		cat $FILENAME | $FILTER > $OUTDIR/$FILENAME.txt
		echo "Clear BOM (if it exists) from $FILENAME"
		perl -i -pe 's/^\x{FFFE}//' $OUTDIR/$FILENAME.txt   # Remove BOM if the file starts with it
		#$SCRIPTDIR/removebad.pl-todo

   		cat $OUTDIR/$FILENAME.txt >> "$OUTDIR/$SUBDIR.step02.txt"
	done
   
   $SCRIPTDIR/create_vocab_charlist.pl "$OUTDIR/$SUBDIR.step02.txt" 0 "$OUTDIR/$SUBDIR.step02.txt.charlist"

done   #done SUBDIR
