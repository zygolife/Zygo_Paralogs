#!/usr/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=0:10:00 
#SBATCH --job-name=yn00.cds
N=$SLURM_ARRAY_TASK_ID
if [ ! $N ]; then
 N=$1
fi
if [ ! $N ]; then
 echo "Need a cmdline or PBS_ARRAYID value"
 exit
fi
SUBOPT=subopt-kaks/bin
INFILE=prefix_dirs.txt
INDIR=pairs
pairdir=`sed -n ${N}p $INFILE`
DIR=kaks
if [ ! -d $DIR ]; then
 mkdir -p $DIR
fi

if [ ! -f $DIR/$pairdir.yn00.tab ]; then
 cat lib/header > $DIR/$pairdir.yn00.tab
 $SUBOPT/yn00_cds_prealigned $INDIR/$pairdir/*.cds.fasaln | grep -v kappa >> $DIR/$pairdir.yn00.tab
else
 echo "not running $dir, $DIR/$pairdir.yn00.tab already exists"
fi
