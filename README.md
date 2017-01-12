Steps to 
a) find paralogs in a protein set
b) generate pairwise files, protein then back translate to the original codons
c) calculate kaks for all pairs
d) plot distribution of pairwise ks to look for WGD patterns

sbatch --array=1-88 jobs/make_pep.sh
ls pep/*.aa.fasta > list
sbatch --array=1-88 jobs/run_fasta.sh
