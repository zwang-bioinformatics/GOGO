use strict;
my $infile = $ARGV[0];
my $outfile = $ARGV[1];
my $outbpo = $outfile."bpo";
my $outcco = $outfile."cco";
my $outmfo = $outfile."mfo";
`perl gene_pair.pl BPO $infile $outbpo`;
`perl gene_pair.pl CCO $infile $outcco`;
`perl gene_pair.pl MFO $infile $outmfo`;
my %pairs;
my $count = 0;
my %bpo;
open IN, $infile;
while(<IN>){
	$count++;
	my $line = $_;
	$line =~ s/\n//;
	$pairs{$count} = $line;
}
close IN;
$count = 0;
open BPO, $outbpo;
while(<BPO>){
	$count++;
	my $line = $_;
  $line =~ s/\n//;
  my @array = split /\s+/,$line;
	$bpo{$count} = "$array[-2] $array[-1]";
}
close BPO;
$count = 0;
my %cco;
open CCO, $outcco;
while(<CCO>){
	$count++;
  my $line = $_;
  $line =~ s/\n//;
  my @array = split /\s+/,$line;
  $cco{$count} = "$array[-2] $array[-1]";
}
close CCO;
$count = 0;
my %mfo;
open MFO, $outmfo;
while(<MFO>){
	$count++;
  my $line = $_;
  $line =~ s/\n//;
  my @array = split /\s+/,$line;
  $mfo{$count} = "$array[-2] $array[-1]";
}
close MFO;
$count = 0;
my $out = $outfile;
open OUT, ">$out";
for my $key (sort{$a<=>$b} keys %pairs){
		print OUT "$pairs{$key} $bpo{$key} $cco{$key} $mfo{$key}\n";
}
close OUT;
if(-e $outbpo){
  `rm $outbpo`;
}
if(-e $outcco){
  `rm $outcco`;
}
if(-e $outmfo){
  `rm $outmfo`;
}
