use strict;
my ($cat, $gene_file, $sim_file) = @ARGV;
my $father = "data/dag_$cat\_ancestor.txt";
my $son = "data/dag_$cat\_descendant.txt";
my $pre_file;
my $isa = "0.4";
my $partof = "0.3";
my $c = 0.67;
my %father;
open FA, $father or die $!;
while(<FA>){
  my $line = $_;
  $line =~ s/\n//;
  my @array = split /\s+/,$line;
  $array[0] =~ s/GO://;
  my @son;
  my $size = @array;
  for( my $i = 2; $i < $size; $i++){
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
  $line =~ s/\n|^\s+|\s+$//g;
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
my %gene;
my @lines;
my @genes;
my @genes2;
open IN, $gene_file or die $!;
while(<IN>){
	my $line = $_;
	$line =~ s/\s+$//;
  $line =~ s/\n|^\s+|\s+$//g;
	my @two = split /\;/, $line;#print "$two[0]\n$two[1]\n";
	$two[0] =~ s/\n|^\s+|\s+$//g;
	$two[1] =~ s/\n|^\s+|\s+$//g;
	my @array = split /\s+/, $two[0];
	my @brray = split /\s+/, $two[1];  
	push @genes, $array[0];push @genes2, $brray[0];
	for(my $i=1; $i<@array; $i++){
		$array[$i] =~ s/GO://;
		if($father{$array[$i]}){
			$gene{$array[0]}{$array[$i]} = 1; #unique GO terms 
    }
	}
	if(!$gene{$array[0]}){
		push @lines, $line." $cat NA";
		next;
	}
	for(my $j=1; $j<@brray; $j++){
		$brray[$j] =~ s/GO://;
    if($father{$brray[$j]}){
      $gene{$brray[0]}{$brray[$j]} = 1;
    }
	}
	if(!$gene{$brray[0]}){
		push @lines, $line." $cat NA";
    next;
	}
	push @lines, $line;
}
close IN;
my %simed;
open SIM, ">$sim_file" or die $!;
my @simi;
for(my $i = 0; $i < @genes; $i++){
	my ($gsim,$up,$down);
	my %max;
	if($lines[$i] =~ "$cat NA"){
		print SIM "$lines[$i]\n";
		next;
	}
	for(keys %{$gene{$genes[$i]}}){
		my $a = $_;
		$a =~ s/GO://;
		my %Ta = own_set($a);
		for(keys %{$gene{$genes2[$i]}}){
			my $b = $_;
			$b =~ s/GO://;
			my $pair = "$a"."$b";
			my $riap = "$b"."$a";
			my $sim;
			my %Tb;
			if(exists $simed{$pair}){
				$sim = $simed{$pair};
			}
			elsif(exists $simed{$riap}){
        $sim = $simed{$riap};
      }
			else{
				%Tb = own_set($b);
				$sim = local_sesame(\%Ta,\%Tb);
				$simed{$pair} = $sim;
			}
			if($sim > $max{$a}){
				$max{$a} = $sim;
			}
			if($sim > $max{$b}){
        $max{$b} = $sim;
      }
		}
	}
	$down = keys %{$gene{$genes[$i]}};
	$down += keys %{$gene{$genes2[$i]}};
	for(keys %{$gene{$genes[$i]}}){
		$_ =~ s/GO://;
		$up += $max{$_};
	}
	for(keys %{$gene{$genes2[$i]}}){
		$_ =~ s/GO://;
    $up += $max{$_};
  }
	if($down ==0){$gsim = 0;}
	else{$gsim = $up/$down;}
	$gsim = sprintf "%0.3f", $gsim;
	print SIM "$lines[$i] $cat $gsim\n";
	push @simi, $gsim;
}
close SIM;
open PRE, ">$pre_file";
my @sort = sort{$a<=>$b} @simi;
my $index = @simi/2;
my $t;
if($index == int($index)){
	$t = ($sort[$index-1]+$sort[$index])/2;
}else{
	$t = $sort[$index];
}
for(my $i = 0; $i < @genes; $i++) {
        print PRE "$t\n";
}
close PRE;
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
        my $weight = 1 / ($c + $number) + $array[1];
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
  return $sim;
}
