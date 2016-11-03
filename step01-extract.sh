#!/bin/bash
clear
echo Check the following variables before running this script:
echo ---------------------------------------------------------
BASEDIR=/home/petri/tekskorpora
WORKDIR=$BASEDIR/NWU-studiegidse
SCRIPTDIR=$WORKDIR/scripts
LANGLIST="Afr Eng"
YEARLIST="2014"
#FOR REFERENCE TO FACULTY NAMES: P_11_Lettere  P_12_NW  P_13_Teologie  P_14_OPV  P_15_EW  P_16_REG  P_17_ING  P_18_PHARM  V_1907_BW-EDU  V_1908_EW-IT
#FLIST="00_testdir"
FLIST="P_11  P_12  P_13  P_14  P_15  P_16  P_17  P_18  V_1907  V_1908"
#needed for gnu parallel .. ECHOFLIST="00_testdir\nP_13"
#needed for gnu parallel .. ECHOFLIST="P_11\nP_12\nP_13\nP_14\nP_15\nP_16\nP_17\nP_18\nV_1907\nV_1908"

echo BASEDIR = $BASEDIR
echo WORKDIR = $WORKDIR
echo SCRIPTDIR = $SCRIPTDIR
echo Study guide language = $LANGLIST
echo YEARLIST = $YEARLIST
echo Faculties to be processed for each year:
echo $FLIST
#echo -ne $ECHOFLIST
#echo
echo Where faculty names are as follows: 
echo P_11=Lettere  P_12=NW  P_13=Teologie  P_14=OPV  P_15=EW  P_16=REG  P_17=ING  P_18=PHARM  V_1907=BW-EDU  V_1908=EW-IT
echo
echo "Notes for script: dir-convert_doc-docx-pdf.pl :";
echo "	outputdir will be created";
echo "	existing files in outputdir will be overwritten";
echo 
echo Press Ctrl-C to stop or Enter to continue
read

### Step through subdirs and convert to *.txt
###############
for SGLANG in $LANGLIST; do
   for Y in $YEARLIST; do
	cd  $WORKDIR/nwu-sg-$Y/
	touch P_11_Lettere  P_12_NW  P_13_Teologie  P_14_OPV  P_15_EW  P_16_REG  P_17_ING  P_18_PHARM  V_1907_BW-EDU  V_1908_EW-IT
	mkdir -p step01.log
#	echo -ne $ECHOFLIST | parallel \
#		"echo $FDIR $SGLANG
#		mkdir -p $WORKDIR/nwu-sg-$Y/step01.outdir/{}/$SGLANG.txt
#		$SCRIPTDIR/dir-convert_doc-docx-pdf.pl \
#			$WORKDIR/nwu-sg-$Y/symlinks/{}/$SGLANG \
#			$WORKDIR/nwu-sg-$Y/step01.outdir/{}/$SGLANG.txt"

	for FDIR in $FLIST; do	# Note that this loop invokes the .pl script with nohup and & which should run it in parallel
		echo "Starting $FDIR $SGLANG"
		mkdir -p $WORKDIR/nwu-sg-$Y/step01.outdir/$FDIR/$SGLANG.txt
		nohup $SCRIPTDIR/dir-convert_doc-docx-pdf.pl \
			$WORKDIR/nwu-sg-$Y/symlinks/$FDIR/$SGLANG \
			$WORKDIR/nwu-sg-$Y/step01.outdir/$FDIR/$SGLANG.txt > $WORKDIR/nwu-sg-$Y/step01.log/step01.$FDIR.$SGLANG.log &
	done
	echo =================================
	echo "Started all requested extractions for nwu-sg-$Y/ for language $SGLANG"
   done
done

echo "END OF THE SCRIPT"
