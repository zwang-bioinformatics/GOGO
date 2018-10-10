 use strict;
my $obo = $ARGV[0]; # go.obo /*download from http://purl.obolibrary.org/obo/go.obo*/ generate files of diret ancestor and children basd on three categories
my $father = $ARGV[1]; #for one category, the file containing each GO term and it's diret ancestor
my $son = $ARGV[2]; #for one category, the file containing each GO term and it's diret descendant
my $go_ontology = $ARGV[3]; # the category of go ontology. Choosing from BPO, CCO and MFO
my ($body, %cat, %anc, %son, %nspace);
$nspace{"BPO"} = "biological_process";
$nspace{"CCO"} = "cellular_component";
$nspace{"MFO"} = "molecular_function";
open(IN,$obo);
while(<IN>){
  my $line = $_;
  chomp($line);
  $line =~ s/^\s+//;
  $line =~ s/\s+$//;
  my @items = split(/\s+/,$line);
	if($items[0] eq "id:"){
		if(substr($items[1],0,3) eq "GO:"){
			$body = $items[1];
		}
	}
	elsif($items[0] eq "namespace:"){
		if($items[1] eq "$nspace{$go_ontology}"){
			$cat{$body} = "";
		}
	}
	elsif($items[0] eq "is_obsolete:"){
		delete $anc{$body};
		delete $cat{$body};
	}
	elsif($items[0] eq "is_a:"){
		if(substr($items[1],0,3) eq "GO:"){
			$anc{$body} .= "$items[1]:isa ";
		}
	}
	elsif($items[0] eq "relationship:"){
		if($items[1] eq "part_of"){
			$anc{$body} .= "$items[2]:partof ";
		}
	}
}
close IN;
my $i = 0;
open(FAT,">$father");
foreach my $key (sort{$a cmp $b} keys %cat){
	print FAT "$key $i $anc{$key}\n";
	$i++;
	my @items = split(/\s+/,$anc{$key});
  my $ele = substr $key,3;
  if(! exists $anc{$ele}){
    $anc{$ele} = "";
  }
  for(my $i = 0; $i < @items; $i++ ){
    my @combo = split /\:/,$items[$i];
    $son{"GO:".$combo[1]} .= "$key ";
  }
}
close FAT;
$i = 0;
open(SON,">$son");
foreach my $key (sort{$a cmp $b} keys %cat){
  print SON "$key $i $son{$key}\n";
  $i++;
}
close SON;
