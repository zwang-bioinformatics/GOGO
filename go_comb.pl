use strict;
my $infile = $ARGV[0];
my $outfile = $ARGV[1];
my $outbpo = $outfile."bpo";
my $outcco = $outfile."cco";
my $outmfo = $outfile."mfo";
`perl go.pl BPO $infile $outbpo`;
`perl go.pl CCO $infile $outcco`;
`perl go.pl MFO $infile $outmfo`;
my %pairs;
my $count = 0;
my %bpo;
open BPO, $outbpo;
while(<BPO>){
	$count++;
	my $line = $_;
  $line =~ s/\n//;
  my @array = split /\s+/,$line;
	$bpo{"$array[0] $array[1]"} = $array[3];
	$pairs{"$array[0] $array[1]"} = $count;
}
close BPO;
my %cco;
open CCO, $outcco;
while(<CCO>){
  my $line = $_;
  $line =~ s/\n//;
  my @array = split /\s+/,$line;
  $cco{"$array[0] $array[1]"} = $array[3];
}
close CCO;
my %mfo;
open MFO, $outmfo;
while(<MFO>){
  my $line = $_;
  $line =~ s/\n//;
  my @array = split /\s+/,$line;
  $mfo{"$array[0] $array[1]"} = $array[3];
}
close MFO;
my $out = $outfile;
open OUT, ">$out";
for my $key (sort{$pairs{$a}<=>$pairs{$b}} keys %pairs){
	if($bpo{$key} ne "NA"){
		print OUT "$key BPO $bpo{$key}\n";
	}
	elsif($cco{$key} ne "NA"){
    print OUT "$key CCO $cco{$key}\n";
  }
	elsif($mfo{$key} ne "NA"){
    print OUT "$key MFO $mfo{$key}\n";
  }
	else{
		print OUT "$key Error:not_in_the_same_ontology\n";
	}
}
close OUT;
#remove temporary files
if(-e $outbpo){
  `rm $outbpo`;
}
if(-e $outcco){
  `rm $outcco`;
}
if(-e $outmfo){
  `rm $outmfo`;
}
