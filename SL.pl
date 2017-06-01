#!/usr/bin/perl -w


open proteome_1, "temp/blastp_1" or die "$!";
open proteome_2, "temp/blastp_2" or die "$!";

$searchcount = 0;

while (<proteome_1>){
	$searchcount++;
	$line = $_;
	if ($line =~ /[Q]+[u]+[e]+[r]+[y]+[=]+[ ]+[a-z]+[|]/){
		$queryid = substr($line,10,6);
		$searchcount = -1;
	}
	if ($searchcount == 0){
	   if ($line =~ /[*]{5}/){
		$besthit_1{$queryid} = "nohit";
	   }
	   elsif ($line =~ /[ ]{2}+[a-z]{2}+[|]/){
		$besthitid = substr($line,5,6);
		$besthit_1{$queryid} = $besthitid;
	   }
	   else {$searchcount--}
	}
}
while (<proteome_2>){
	$searchcount++;
	$line = $_;
	if ($line =~ /[Q]+[u]+[e]+[r]+[y]+[=]+[ ]+[a-z]+[|]/){
		$queryid = substr($line,10,6);
		$searchcount = -1;
	}
	if ($searchcount == 0){
	   if ($line =~ /[*]{5}/){
		$besthit_2{$queryid} = "nohit";
	   }
	   elsif ($line =~ /[ ]{2}+[a-z]{2}+[|]/){
		$besthitid = substr($line,5,6);
		$besthit_2{$queryid} = $besthitid;
	   }
	   else {$searchcount--}
	}
}
$i = 0;
foreach (sort keys %besthit_1){
	if ($_ eq $besthit_2{$besthit_1{$_}}){
		$reciprocalbesthits{$_} = $besthit_1{$_};
	}
	else{
		$nonreciprocalbesthits_1[$i] = $_;
		$i++;
	}
}
$i = 0;
foreach (sort keys %besthit_2){
	if ($_ eq $besthit_1{$besthit_2{$_}}){
	}
	else{
		$nonreciprocalbesthits_2[$i] = $_;
		$i++;
	}
}

print "\nreciprocal-best-hits of species 1 and 2\n\n";
foreach (sort keys %reciprocalbesthits){
	print "$_ $reciprocalbesthits{$_}\n";
}
print "\nnonreciprocal-best-hits of species 1\n\n";
foreach (@nonreciprocalbesthits_1){
	print "$_\n";
}
print "\nnonreciprocal-best-hits of species 2\n\n";
foreach (@nonreciprocalbesthits_2){
	print "$_\n";
}
