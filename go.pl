use strict;
my $cat = $ARGV[0];  #category
my $infile = $ARGV[1]; 
my $outfile = $ARGV[2];
my $isa = "0.4"; 
my $partof = "0.3";
my $c = 0.67;
my $father = "data/dag_$cat\_ancestor.txt";
my $son = "data/dag_$cat\_descendant.txt";
my %father;
open FA, $father or die $!;
while(<FA>){
  my $line = $_;
  $line =~ s/\n//;
  my @array = split /\s+/,$line;
  $array[0] =~ s/GO://;
  my @son;
  for( my $i = 2; $i < @array; $i++){
	  my @items = split /\:/, $array[$i];
	  my $value;
	  if( $items[2] eq "isa"){
	    $value = $isa;
	  }
	  elsif($items[2] eq "partof"){
	    $value = $partof;
	  }
	  else{
	    die "$items[2] not isa || partof\n";
	  }
	  my $element = "$items[1]:$value";
	  push @son, $element;
	}
  $father{$array[0]} = \@son;
}
close FA;
my %children;
open CHI, $son or die $!;
while(<CHI>){
	my $line = $_;
  $line =~ s/\n//;
  my @array = split /\s+/,$line;
  $array[0] =~ s/GO://;
  my @son;
  for( my $i = 2; $i < @array; $i++){
    my $items =~ s/GO://;
    push @son, $items;
  }
  $children{$array[0]} = \@son;
}
close CHI;
open IN, "$infile" or die $!;
open OUT, ">$outfile" or die $!;
while(<IN>){
	my $line = $_;
  $line =~ s/\n//;
  my @array = split /\s+/,$line;
	my $goa = $array[0];
	my $gob = $array[1];
	$goa =~ s/GO://;
	$gob =~ s/GO://;
  if(!exists $father{$goa} || !exists $father{$gob}){
    print OUT "GO:$goa GO:$gob $cat NA\n";
    next;
  }
	my %Ta = own_set($goa); #S-value
	my %Tb = own_set($gob); #S-value
	my $sim = local_sesame(\%Ta,\%Tb); #semantic simlarity
	print OUT "GO:$goa GO:$gob $cat $sim\n";
}
close IN;
close OUT;
sub own_set{
  my %hash;
  my %s_f;
  my $go = shift;
  $hash{$go} = 1;
  $s_f{$go} = 2;
  for( my $i = 0; $i < 1; ){
  	my %up_generation;
  	foreach my $son (keys %s_f){
		  foreach my $dad (@{$father{$son}}){
		    my @array = split /\:/, $dad;
		    $up_generation{$array[0]} = 2;
		  	if(!$children{$array[0]}){
					next;
				}
  		  my $number = @{$children{$array[0]}};
 		   	my $weight = 1 / ($c + $number) + $array[1]; #we of edge
  	   	my $sv = $hash{$son} * $weight;
  	    if( exists $hash{$array[0]}){
  	   		if( $sv < $hash{$array[0]}){
  	 	     	next;
  	     	}
  	    }
  	    $hash{$array[0]} = $hash{$son} * $weight;
  	  }
  	}
  	%s_f = %up_generation;
  	if(! keys %s_f){
  	  $i++;
  	}
  }
  return %hash;
}
sub local_sesame{
  my $sva = $_[0];
  my $svb = $_[1];
  my $down;
  my $up;
  foreach my $a (keys %{$sva}){
	  if( exists $svb->{$a}){
  	  $up += $sva->{$a} + $svb->{$a};
  	}
  	$down += $sva->{$a};
  }
  foreach my $b (keys %{$svb}){
    $down += $svb->{$b};
  }
  my $sim = $up/$down;
  $sim = sprintf "%0.3f", $sim;
  return $sim;
}
