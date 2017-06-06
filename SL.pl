#!/usr/bin/perl -w

use lib 'Excel-Writer-XLSX-0.95/lib';
use Excel::Writer::XLSX;

open proteome_1, "temp/blastp_1" or die "$!";
open proteome_2, "temp/blastp_2" or die "$!";

$searchcount = 0;

$besthit_1{"nohit"} = "nohit";
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
$besthit_2{"nohit"} = "nohit";
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

my $workbook  = Excel::Writer::XLSX->new('results.xlsx');
my $worksheet1 = $workbook->add_worksheet('no_rbh_proteome_1');
my $worksheet2 = $workbook->add_worksheet('no_rbh_proteome_2');
my $worksheet3 = $workbook->add_worksheet('reciprocal_best_hits');

$worksheet3->write( 0, 1, "proteome_1" );
$worksheet3->write( 0, 2, "proteome_2" );

$i = 0;
$j = 0;
foreach (sort keys %besthit_1){
	if ($_ eq "nohit"){}
	elsif ($_ eq $besthit_2{$besthit_1{$_}}){
		$reciprocalbesthits{$_} = $besthit_1{$_};
		$j++;
		$worksheet3->write( $j, 1, "$_" );
		$worksheet3->write( $j, 2, "$besthit_1{$_}" );
	}
	else{
		$nonreciprocalbesthits_1[$i] = $_;
		$i++;
		$worksheet1->write( $i, 1, "$_" );
	}
}
$i = 0;
foreach (sort keys %besthit_2){
	if ($_ eq "nohit"){}
	elsif ($_ eq $besthit_1{$besthit_2{$_}}){
	}
	else{
		$nonreciprocalbesthits_2[$i] = $_;
		$i++;
		$worksheet2->write( $i, 1, "$_" );
	}
}

$workbook->close;
