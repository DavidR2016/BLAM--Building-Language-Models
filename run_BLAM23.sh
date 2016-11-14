#!/bin/bash

#  step02-and-03.sh of running BLAM (Building Language Models)

# Add some headings to the output file
echo -e "The command run was: nice -n 0 .... bash petri/tekskorpora/NWU-studiegidse/scripts/run_step02-and-03.sh " > time_BLAM23.txt
#echo -e "The command run was: nice -n 0 .... bash asr/exp/src/system.sh" > time_SVMvsASR.txt
#echo -e "Seconds\t%CPU\tUser(s)\tSystem(s)\tfs-inputs\tfs-outputs\tcs-vol.\tcs-invol.\tD-size(kb)\tAvgMem(kb)\tMaxMem(kb)" >> time_SVM2.txt
echo -e "Seconds\t%Real_hrs\t%real_sec\t%System\t%User\t%CPU\t%Avg_res\t%Max_res\t%Avg_mem\t%fs-inputs\t%fs-outputs" >> time_BLAM23.txt
# Repeat timed experiment
for i in `seq 1 5`; do 
	nice -n 0 /usr/bin/time -o time_BLAM23.txt -a -f "%E\t%e\t%S\t%U\t%P\t%t\t%M\t%K\t%I\t%O\t"\
	bash petri/tekskorpora/NWU-studiegidse/scripts/step02-and-03.sh
done

