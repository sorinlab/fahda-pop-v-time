#!/usr/bin/perl
use strict;
use List::MoreUtils qw(uniq);

#
# Khai Nguyen <nguyenkhai101@gmail.com>
# Nov 2016
#

our $usage = "$0  <inputFilename>  <outputFilename>}";
if (scalar(@ARGV) == 0) {
    print "Usage: $usage\n";
    exit;
}

our $inputFilename = $ARGV[0];
our $outputFilename = $ARGV[1];

print STDOUT "\tInput:  $inputFilename\n";
print STDOUT "\tOutput: $outputFilename\n";

#...............................................................................
our @macrostates = ();
our %macrostatePopulationPerTimeFrame = ();
# Total population for a time frame of all macrostates
# Will be used for normalization
our %totalPopulationPerTimeFrame = ();

#...............................................................................
open(INPUT, '<', $inputFilename)
or die "ERROR: Cannot open input file $inputFilename. $!.\n";
our $timeColumn = 4;

while (my $line = <INPUT>) {
    chomp($line);
	my @values = split(/\s+/, $line);

    my $timeFrame = $values[$timeColumn];
    if (!exists $totalPopulationPerTimeFrame{$timeFrame} ||
        !defined $totalPopulationPerTimeFrame{$timeFrame}) {
        $totalPopulationPerTimeFrame{$timeFrame} = 0;
    }
    $totalPopulationPerTimeFrame{$timeFrame} += 1;

    my $macrostate = $values[$#values];
    if ($macrostate eq "X") { next; } #ignore non-macrostate datapoints
    push(@macrostates, $macrostate);

    if (!exists $macrostatePopulationPerTimeFrame{"$macrostate-$timeFrame"} ||
        !defined $macrostatePopulationPerTimeFrame{"$macrostate-$timeFrame"}) {
        $macrostatePopulationPerTimeFrame{"$macrostate-$timeFrame"} = 0
    }
	$macrostatePopulationPerTimeFrame{"$macrostate-$timeFrame"} += 1;
}

our @timeFrames = sort {$a <=> $b} +(uniq keys %totalPopulationPerTimeFrame);
@macrostates = sort +(uniq @macrostates);

#...............................................................................
open (OUTPUT, ">", $outputFilename)
or die "Cannot write to output file $outputFilename. $!.\n";

for (my $i = 0; $i <= $#macrostates; $i++) {
	my $macrostate = $macrostates[$i];
	for (my $j = 0; $j <= $#timeFrames; $j++) {
		my $timeFrame = $timeFrames[$j];
		my $population = $macrostatePopulationPerTimeFrame{"$macrostate-$timeFrame"} / $totalPopulationPerTimeFrame{$timeFrame};
		printf OUTPUT "% 10.5f\t", $population;
	}
	print OUTPUT "\n";
}

close OUTPUT;
