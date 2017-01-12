#!/usr/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --job-name=fastaSelf
#SBATCH --mem-per-cpu=500M

module load fasta

CPU=$SLURM_JOB_CPUS_PER_NODE

if [ ! $CPU ]; then
 CPU=4
fi

N=$SLURM_ARRAY_TASK_ID
if [ ! $N ]; then
 N=$1
fi
if [ ! $N ]; then 
 echo "Need a cmdline or SLURM_ARRAY_TASK_ID value"
 exit
fi
INFILE=files
F=`sed -n ${N}p $INFILE`
OUT=results
base=`basename $F .aa.fasta`
fasta36 -T $CPU -E 1e-15 -m 8c $F $F > $OUT/$base.FASTA.tab
