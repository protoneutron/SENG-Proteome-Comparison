#!/usr/bin/perl -w

#integrating used modules
#for excel
use lib 'Excel-Writer-XLSX-0.95/lib';
use Excel::Writer::XLSX;

#for venn-chart
use GD;
use lib 'Venn-Chart-1.02/lib';
use Venn::Chart;

#input of BLAST results
open proteome_1, "temp/blastp_1" or die "$!";
open proteome_2, "temp/blastp_2" or die "$!";

#initialize variables and hashes
$searchcount = 0;
#initialize nohit in the hash for later reverse searches
$besthit_1{"nohit"} = "nohit";
#evaluate proteome 1
while (<proteome_1>){
	$searchcount++;
	$line = $_;
#find Querys (=ProteinIDs) of Proteome 1
	if ($line =~ /[Q]+[u]+[e]+[r]+[y]+[=]+[ ]+[a-z]+[|]/){
#copy the ID
		$queryid = substr($line,10,6);
#after identifying a Query the loop starts to search for the best-hit (highest alignment score)
		$searchcount = -1;
	}
	if ($searchcount == 0){
#if alignment scores are insufficient there is a line "***** no hit *****"
#in this case there is no best-hit
	   if ($line =~ /[*]{5}/){
		$besthit_1{$queryid} = "nohit";
	   }
#the first line starting with a ProteinID is the best hit
	   elsif ($line =~ /[ ]{2}+[a-z]{2}+[|]/){
#its ID is copied
		$besthitid = substr($line,5,6);
#create a hash entry for the QueryID as key and the best-hit-ID as value 
		$besthit_1{$queryid} = $besthitid;
	   }
	   else {$searchcount--}
	}
}
#evaluate proteome 2
$besthit_2{"nohit"} = "nohit";
while (<proteome_2>){
	$searchcount++;
	$line = $_;
#find Querys (=ProteinIDs) of Proteome 2
	if ($line =~ /[Q]+[u]+[e]+[r]+[y]+[=]+[ ]+[a-z]+[|]/){
#copy the ID
		$queryid = substr($line,10,6);
#after identifying a Query the loop starts to search for the best-hit (highest alignment score)
		$searchcount = -1;
	}
	if ($searchcount == 0){
#if alignment scores are insufficient there is a line "***** no hit *****"
#in this case there is no best-hit
	   if ($line =~ /[*]{5}/){
		$besthit_2{$queryid} = "nohit";
	   }
#the first line starting with a ProteinID is the best hit
	   elsif ($line =~ /[ ]{2}+[a-z]{2}+[|]/){
#its ID is copied
		$besthitid = substr($line,5,6);
#create a hash entry for the QueryID as key and the best-hit-ID as value 
		$besthit_2{$queryid} = $besthitid;
	   }
	   else {$searchcount--}
	}
}

#create excel file
my $workbook  = Excel::Writer::XLSX->new('results.xlsx');
#add three worksheets
my $worksheet1 = $workbook->add_worksheet('no_rbh_proteome_1');
my $worksheet2 = $workbook->add_worksheet('no_rbh_proteome_2');
my $worksheet3 = $workbook->add_worksheet('reciprocal_best_hits');

$worksheet3->write( 0, 1, "proteome_1" );
$worksheet3->write( 0, 2, "proteome_2" );


$i = 0;
$j = 0;
#for each proteinID identify the best-hit-ID and check if its best-hit is identical to the original ID
foreach (sort keys %besthit_1){
	if ($_ eq "nohit"){}
#if it is identical write the two IDs of the reciprocal-best-hit into a worksheet
	elsif ($_ eq $besthit_2{$besthit_1{$_}}){
		$reciprocalbesthits[$j] = $_;
		$j++;
		$worksheet3->write( $j, 1, "$_" );
		$worksheet3->write( $j, 2, "$besthit_1{$_}" );
	}
	else{
#else the nonreciprocal-best-hit is written into another sheet
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
#each nonreciprocal-best-hit of the other proteome is written into a third worksheet
		$nonreciprocalbesthits_2[$i] = $_;
		$i++;
		$worksheet2->write( $i, 1, "$_" );
	}
}

$workbook->close;

#draw a venn-chart (see http://search.cpan.org/~djibel/Venn-Chart-1.02/lib/Venn/Chart.pm)
@venn1 = (@nonreciprocalbesthits_1,@reciprocalbesthits);
@venn2 = (@nonreciprocalbesthits_2,@reciprocalbesthits);

#set resolution of venn-file
my $venn_chart = Venn::Chart->new( 400, 600 ) or die("$!");

#set title and legend
$venn_chart->set_options( -title => 'Diagram' );
$venn_chart->set_legend( 'proteom 1', 'proteom 2');

my $gd_venn = $venn_chart->plot( \@venn1, \@venn2 );

#create and save file
open my $fh_venn, '>', 'VennChart.jpeg' or die("Unable to create file\n");
binmode $fh_venn;
print {$fh_venn} $gd_venn->jpeg;
close $fh_venn or die('Unable to close file');

