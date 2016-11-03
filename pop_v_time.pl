#!/usr/bin/perl
use strict;
use List::MoreUtils qw(any uniq);

#
# Khai Nguyen <nguyenkhai101@gmail.com>
# Nov 2016
#

our $usage = "$0  <inputFilename>  <outputFilename>  <logFilename}";
if (scalar(@ARGV) == 0) {
    print "Usage: $usage\n";
    exit;
}

our $inputFilename = $ARGV[0];
our $outputFilename = $ARGV[1];
our $logFilename = $ARGV[2];

print "\tInput:  $inputFilename\n";
print "\tOutput: $outputFilename\n";
print "\tLog: $logFilename\n";

#...............................................................................
our @timeFrames = ();
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
    push(@timeFrames, $timeFrame);

    my $macrostate = $values[$#values];
    if (!exists $totalPopulationPerTimeFrame{$macrostate} ||
        !defined $totalPopulationPerTimeFrame{$macrostate}) {
        $totalPopulationPerTimeFrame{$macrostate} = 0;
    }
    $totalPopulationPerTimeFrame{$macrostate} += 1;

    if (!exists $macrostatePopulationPerTimeFrame{"$macrostate-$timeFrame"} ||
        !defined $macrostatePopulationPerTimeFrame{"$macrostate-$timeFrame"}) {
        $macrostatePopulationPerTimeFrame{"$macrostate-$timeFrame"} = 0
    }
	$macrostatePopulationPerTimeFrame{"$macrostate-$timeFrame"} += 1;
}

@timeFrames = sort {$a <=> $b} +(uniq @timeFrames);
our @macrostates = sort +(uniq keys %totalPopulationPerTimeFrame);
print "\nTotal population per time frame:\n";
foreach my $macrostate (sort keys %totalPopulationPerTimeFrame) {
    print $macrostate, ": ", $totalPopulationPerTimeFrame{$macrostate}, "\n";
}

#...............................................................................
open (OUTPUT, ">", $outputFilename)
or die "Cannot write to output file $outputFilename. $!.\n";

for (my $i = 0; $i <= $#macrostates; $i++) {
	my $macrostate = $macrostates[$i];
	for (my $j = 0; $j <= $#timeFrames; $j++) {
		my $timeFrame = $timeFrames[$j];
		my $population = $macrostatePopulationPerTimeFrame{"$macrostate-$timeFrame"} / $totalPopulationPerTimeFrame{$macrostate};
		printf OUTPUT "% 10.5f\t", $population;
	}
	print OUTPUT "\n";
}

close OUTPUT;
