#!/usr/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=1G

N=${SLURM_ARRAY_TASK_ID}
if [ ! $N ]; then
 N=$1
fi
if [ ! $N ]; then
 echo "Need a cmdline or SLURM array value"
 exit
fi

CDSdir=CDS
PEPdir=pep
file=`ls $CDSdir/*.cds.fasta | sed -n ${N}p`
base=`basename $file .cds.fasta`
if [ ! -f $PEPdir/$base.aa.fasta ]; then
  perl scripts/bp_translate_seq.pl $file > $PEPdir/$base.aa.fasta
else
 echo "skipping $file - already have $PEPdir/$base.aa.fasta"
fi
