use strict;
use warnings;
my $infile = $ARGV[0];
my $outfile = $ARGV[1];
my $cluster = $ARGV[2];
my @cat = ("BPO", "CCO", "MFO");
for my $key (@cat){
	my $sim = $outfile.$key."sim";
	my $pre = $outfile.$key."pre";
	my $cls = $outfile.$key."cls";
	`perl gene_list.pl $key $infile $sim $pre`;
	if(-e $pre){
		`./apcluster $sim $pre $cls`;
	}
}
my %lists;
my %names;
my $count = 0;
open IN, $infile;
while(<IN>){
	$count++;
	my $line = $_;
	$line =~ s/\n//;
  my @array = split /\s+/,$line;
	$lists{$count} = $line;
	$names{$count} = $array[0];
}
close IN;
my %simout;
for my $key (@cat){
	$count = 0;
	my $sim = $outfile.$key."sim";
	my $cls = $outfile.$key."cls";
	open CAT, $sim;
	while(<CAT>){
		$count++;
		my $line = $_;
	  $line =~ s/\n//;
	  my @array = split /\s+/,$line;
		if($key eq "BPO"){
			$simout{$count} = "$names{$array[0]} $names{$array[1]} $key $array[-1]";
		}
		else{
			$simout{$count} .= " $key $array[-1]";
		}
	}
	close CAT;
}
my $out = $outfile;
open OUT, ">$out";
for my $key (sort{$a<=>$b} keys %simout){
		print OUT "$simout{$key}\n";
}
close OUT;
open CLU, ">$cluster";
for my $key (@cat){
  my $sim = $outfile.$key."sim";
  my $pre = $outfile.$key."pre";
  my $cls = $outfile.$key."cls";
	$count = 0;
	my %class;
  #`perl gene_list.pl $key $infile $sim $pre`;
  if(-e $pre){
		print CLU "$key:\n";
    open FL, "$cls";
		#print "$cls\n";
		while(<FL>){
			$count++;
			my $line = $_;
			$line =~ s/\n//;
			#print "$count $names{$count} $line\n";
			if($line == $count){
				if(!exists $class{$names{$line}}){
					$class{$names{$line}} = "";
				}
			}
			else{
		  	$class{$names{$line}} .= " $names{$count}";
			}
		}
		close FL;
		for my $ele (keys %class){
			print CLU "$ele$class{$ele}\n";
		}
  }
}
close CLU;
for my $key (@cat){
	my $sim = $outfile.$key."sim";
  my $pre = $outfile.$key."pre";
  my $cls = $outfile.$key."cls";
  if(-e $sim){ 
		`rm $sim`;
	}
	if(-e $pre){
		`rm $pre`;
	}
  if(-e $cls){
    `rm $cls`;
  }
}
