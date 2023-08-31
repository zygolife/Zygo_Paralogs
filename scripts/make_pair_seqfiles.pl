#!/usr/bin/perl 
use strict;
use warnings;

use Bio::SeqIO;
use Bio::DB::Fasta;
use File::Spec;
use Getopt::Long;
my $zcat = 'zcat'; # can be replaced with `gzip -d -c";
my $cdsfolder = 'CDS';
my $pepfolder = 'pep';
my $outfolder = 'pairs';

GetOptions('z|zcat:s' => \$zcat,
	   'c|cds:s'  => \$cdsfolder,
	   'p|pep:s'  => \$pepfolder,
	   'o|out:s'  => \$outfolder);

my $file = shift || die"need a file";
my $fh;
my (undef,undef,$filename) = File::Spec->splitpath($file);
unless ( $filename =~ /(\S+)\.FASTA.tab(\.gz)?$/ ) {
 die "input report unexpected name: $filename"
}
my ($basename,$ext) = ($1,$2);
if( $ext ) {
 open($fh => "$zcat $file |") || die "Cannot open $file with zcat: $!";
} else {
 open($fh => $file) || die "cannot open $file";
}

if ( ! -d $outfolder ) {
 mkdir($outfolder);
}
my $pairct = 0;
my $pepdb = Bio::DB::Fasta->new(sprintf("%s/%s.aa.fasta",$pepfolder,$basename));
my $cdsdb = Bio::DB::Fasta->new(sprintf("%s/%s.cds.fasta",$cdsfolder,$basename));
my $min_aligned = 0.60;
my %seen;
while(<$fh>) {
 next if /^\#/;
 my ($q,$t,$pid,$alnlen) = split;
 next if $q eq $t; # skip self-vs-self
 my ($sp) = split(/\|/,$q);
 my $outfile = File::Spec->catdir($outfolder,$sp);
 mkdir($outfile);
 my $qseq = $pepdb->get_Seq_by_acc($q);
 my $tseq = $pepdb->get_Seq_by_acc($t); 
 if ( ! $qseq ) {
   warn("no qseq $q");
   next;
 }
 if ( ! $tseq ) {
   warn("no tseq $t");
   next;
 }
 # this is 1 selection criteria - make sure is at least (min_aligned)
 # aligned
 if(( $alnlen / $qseq->length)  < $min_aligned ) {
   next;
 }
 # only dump a gene/protein in a single pair, if it participated
 # as a 'query' or 'target' in any other results, skip it
 # This could have the effect of picking 2nd best hit for something
 # not sure should further restrict how this allows a pair to be written
 next if $seen{$q}++ || $seen{$t}++;
 $outfile = File::Spec->catfile($outfile,sprintf("p%06d",$pairct++));
 my $cdsout = Bio::SeqIO->new(-format => 'fasta', -file => ">$outfile.cds");
 my $pepout = Bio::SeqIO->new(-format => 'fasta', -file => ">$outfile.pep");
 my $qcds = $cdsdb->get_Seq_by_acc($q);
 my $tcds = $cdsdb->get_Seq_by_acc($t);
 
# deal with potential stop codons in these sequences for various reasons
# JGI doesn't produce clean CDS files, not sure why, recode these
# positions as 'X' then encode these as gaps after the alignment is performed
# see the mr_trans.pl script in this folder
 if( $qseq->seq =~ /[\*X]/ ) { 
    my $s = $qseq->seq;
    my $scds = $qcds->seq;
    if( $s =~ s/[\*X]$// ) { # drop trailing stop codon completely
	$s = substr($s,0,-1);
	$scds = substr($scds,0,-3)
    }
    # any other stop codon should be recoded as an X to be handled by
    # the aligner and then swapped out by mrtrans
    $s =~ s/\*/X/g;
    # have to rewrite the seq object because Bio::DB::Fasta essentially produces
    # read-only objects , otherwise would just update ->seq() in place   
    $qcds = Bio::PrimarySeq->new(-id => $qcds->id, -seq => $scds, -desc => $qcds->description);
    $qseq = $qcds->translate(); #Bio::PrimarySeq->new(-id => $qseq->id, -seq => $s, -desc => $qseq->description);
 } 
 if( $tseq->seq =~ /[\*X]/ ) {
    my $s = $tseq->seq; # the protein
    my $scds = $tcds->seq; # the CDS

    if( $s =~ s/[\*X]$// ) { # drop trailing stop codon completely
	$s = substr($s,0, -1);
	$scds = substr($scds,0, -3);
    }
    # any other stop codon should be recoded as an X to be handled by  
    # the aligner and then swapped out by mrtrans
    $s =~ s/\*/X/g;
    # have to rewrite the seq object because Bio::DB::Fasta essentially produces
    # read-only objects , otherwise would just update ->seq() in place   

    $tcds = Bio::PrimarySeq->new(-id => $tcds->id, -seq => $scds, -desc => $tcds->description);
    $tseq = $tcds->translate(); #Bio::PrimarySeq->new(-id => $tseq->id, -seq => $s, -desc => $tseq->description);
  }
    
 $cdsout->write_seq($qcds);
 $cdsout->write_seq($tcds);
 $pepout->write_seq($qseq);
 $pepout->write_seq($tseq);
}
