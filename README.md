Steps
* find paralogs in a protein set (FastaSelf)
* generate pairwise files, align protein, then back translate to the original codons
* calculate kaks for all pairs
* plot distribution of pairwise ks to look for WGD patterns

sbatch --array=1-88 jobs/make_pep.sh
ls pep/*.aa.fasta > list
sbatch --array=1-88 jobs/run_fasta.sh
