#!/bin/bash
# - Sort study guides using symlinks (Build a categorised tree of symlinks)
# - Rename the symlinks to remove spaces and ()

clear
echo "CHECK the following variables MANUALLY before running this script:"
echo ------------------------------------------------------------------
BASEDIR=/home2/davidr/petri/tekskorpora
WORKDIR=$BASEDIR/NWU-studiegidse
RAWDIR=$BASEDIR/NWU-studiegidse/original-doc-pdf
YEARLIST="2015 2016"
FLIST="P_11  P_12  P_13  P_14  P_15  P_16  P_17  P_18  V_1907  V_1908 M_9010 M_9040 M_9100 M_9230 M_9240"
#FLIST="00_testdir"

echo BASEDIR = $BASEDIR
echo WORKDIR = $WORKDIR
echo RAWDIR with doc, docx and pdf = $RAWDIR 
echo LOOPs currently set for
echo    Years = $YEARLIST
echo	Faculty list = $FLIST
echo 
echo FOR REFERENCE TO FACULTY NAMES: 
echo P_11_Lettere  P_12_NW  P_13_Teologie  P_14_OPV  P_15_EW  P_16_REG  P_17_ING  P_18_PHARM  V_1907_BW-EDU  V_1908_EW-IT
echo
echo Press Enter to continue
read

### 
ACTION="Create symlinks without spaces in names (separating /Afr, /Eng for the years $YEARLIST)"
#####################################################################
echo "busy with: $ACTION"
for YEAR in $YEARLIST; do
   DIRYEAR=$WORKDIR/nwu-sg-$YEAR/symlinks 
   for GIDS in $FLIST; do
	echo "mkdir -p $DIRYEAR/$GIDS/Afr"
	mkdir -p $DIRYEAR/$GIDS/Afr
	echo "mkdir -p $DIRYEAR/$GIDS/Eng"
	mkdir -p $DIRYEAR/$GIDS/Eng
	find $RAWDIR/nwu-sg-$YEAR/$GIDS \
		-type f -name "* ?A? $YEAR*" -printf "ln -s '%p' $DIRYEAR/$GIDS/Afr/'%f'\n" -o \
		-type f -name "* ?E? $YEAR*" -printf "ln -s '%p' $DIRYEAR/$GIDS/Eng/'%f'\n"     | sh
	echo "Renaming in nwu-sg-$YEAR only the symlinks - replacing spaces and () with _"
	rename 's/[ ()]/_/g'  $DIRYEAR/$GIDS/Afr/*
	rename 's/[ ()]/_/g'  $DIRYEAR/$GIDS/Eng/*
   done
   tree $DIRYEAR
done


