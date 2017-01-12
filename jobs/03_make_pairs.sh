#!/usr/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=1:00:00
#SBATCH --job-name=make_pair_CDS

N=${SLURM_ARRAY_TASK_ID}
if [ ! $N ]; then
 N=$1
fi
if [ ! $N ]; then
 echo "Need a cmdline or SLURM array value"
 exit
fi

INFILE=fasta_results.txt
F=`sed -n ${N}p $INFILE`
perl scripts/make_pair_seqfiles.pl $F
