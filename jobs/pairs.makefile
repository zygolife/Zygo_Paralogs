PEPS =  $(wildcard *.pep)
PEPALN = $(patsubst %.pep, %.pep.fasaln, $(PEPS)) 
CDSALN = $(patsubst %.pep, %.cds.fasaln, $(PEPS))

MRTRANS=../../scripts/bp_mrtrans.pl
TRIMAL=/opt/linux/centos/7.x/x86_64/pkgs/trimal/1.4.1/bin/trimal
MUSCLE=/opt/linux/centos/7.x/x86_64/pkgs/muscle/3.8.425/bin/muscle

.PHONY: all 

all: $(CDSALN) $(PEPALN)
	echo "Making all"

%.pep.fasaln: %.pep
	 ${MUSCLE} -in $*.pep -out $@ -quiet

%.cds.fasaln: %.pep.fasaln %.cds
	${TRIMAL} -in $*.pep.fasaln -backtrans $*.cds -out $@
#	perl ${MRTRANS} -if fasta -of fasta -o $@ -i $*.pep.fasaln -s $*.cds
