#!/usr/bin/perl -w
use strict;

#
# Khai Nguyen <nguyenkhai101@gmail.com>
# Nov 2016
# Purpose: A macrostate is identified by four dimensions: RMSD, Rg, native
#          contacts, and non-native contacts. These boundaries for each
#          macrostate are specified in the argument input file. The data points
#          whose values in these boundaries are labeled with their respective
#          macrostate name.
#
our $usage = "$0  <inputFilename> <cutoffTimeInPs> <outputFilename>  <logFilename}";
if (scalar(@ARGV) == 0) {
    print "Usage: $usage\n";
    exit;
}

our $inputFilename = $ARGV[0];
our $cutoffTimeInPs = $ARGV[1];
our $outputFilename = $ARGV[2];
our $logFilename = $ARGV[3];

our $maxRMSD = 32.660;
our $maxRg = 34.398;
our $maxNC = 1101.77;
our $maxNNC = 1930;

#...............................................................................
open (INPUT, "<", $inputFilename) or die "Cannot open $inputFilename. $!\n";
open (OUTPUT, ">", $outputFilename) or die "Cannot open $outputFilename. $!\n";
open (LOG, ">", $logFilename) or die "Cannot open $logFilename. $!\n";

#...............................................................................
#fahdata@sorin2 ~/PKNOT/analysis/clustering/pop-v-time/scripts
#$ head ~/PKNOT/analysis/clustering/kmeans-clustering-results/final_LUTEO_kmeans_with_new_native_contacts.txt
#0     1796        0        0      100    1.312    12.191   395       242        10       166       334      1147         0
#0     1796        0        0      200    1.139    12.355   460       212        10       178       355      1215         0
#0     1796        0        0      300    1.051    12.355   396       225         8       163       283      1075         0
#0     1796        0        0      400    1.682    12.517   393       204         7       143       301      1048         0
#0     1796        0        0      500    2.023    12.678   385       180         6       150       317      1038         0
#0     1796        0        0      600    1.752    12.546   415       196         4       174       322      1111         0
#0     1796        0        0      700    2.035    12.748   373       180         2       150       278       983         0
#0     1796        0        0      800    1.677    12.481   414       178         8       172       305      1077         0
#0     1796        0        0      900    1.468    12.463   417       214         6       159       284      1080         0
#0     1796        0        0     1000    1.661    12.418   392       194         6       176       230       998         0
our $timeColumn = 4;
our $rmsdColumn = 5;
our $rgColumn = 6;
our $ncColumn = 11;
our $nncColumn = 12;

while (my $line = <INPUT>) {
    chomp($line);
    my $OriginalLine = $line;

    my @items = split(/\s+/, $line);
    my $time  = $items[$timeColumn];

    if ($time < $cutoffTimeInPs) { next; }

    my $rmsd    = $items[$rmsdColumn];
    my $rg      = $items[$rgColumn];
    my $nc      = $items[$ncColumn];
    my $nnc     = $items[$nncColumn];

    # Extract State A/F1    SAME
    if (IsBetweenMinMax($rmsd, 0.0, 3.0)) {
        print OUTPUT $OriginalLine, "\tF1\n";
    }

    # Extract State B/F2    CHANGED 7/13/16
    elsif (IsBetweenMinMax($rmsd, 3.0, 6.0) &&
           IsBetweenMinMax($nc, 0.775*$maxNC, $maxNC)) {
        print OUTPUT $OriginalLine, "\tF2\n";
    }

    # Extract State C/I1    CHANGED 7/13/16
    elsif (IsBetweenMinMax($rmsd, 3.5, 6.5) &&
           IsBetweenMinMax($nc, 0.55*$maxNC, 0.775*$maxNC)) {
        print OUTPUT $OriginalLine, "\tI1\n";
    }

    # Extract State E/I2    CHANGED 7/13/16
    elsif (IsBetweenMinMax($rmsd, 6.5, 11.0) &&
           IsBetweenMinMax($nc, 0.375*$maxNC, 0.70*$maxNC)) {
        print OUTPUT $OriginalLine, "\tI2\n";
    }

    # Extract State G/M4    CHANGED 7/13/16
    elsif (IsBetweenMinMax($rmsd, 10.0, 24.0) &&
           IsBetweenMinMax($nc, 0.25*$maxNC, 0.45*$maxNC)) {
        print OUTPUT $OriginalLine, "\tM4\n";
    }

    # Extract State H/M1    CHANGED 7/13/16
    elsif (IsBetweenMinMax($rmsd, 6.5, 10.0) &&
           IsBetweenMinMax($nc, 0.125*$maxNC, 0.30*$maxNC)) {
        print OUTPUT $OriginalLine, "\tM1\n";
    }

    # Extract State I/U1    CHANGED 7/13/16
    elsif (IsBetweenMinMax($rmsd, 10.0, 17.0) &&
           IsBetweenMinMax($nc, 0.125*$maxNC, 0.25*$maxNC)) {
        print OUTPUT $OriginalLine, "\tU1\n";
    }

    # Extract State J/U2    CHANGED 7/13/16
    elsif (IsBetweenMinMax($rmsd, 7.0, 26.5) &&
           IsBetweenMinMax($rg, 13.0, $maxRg) &&
           IsBetweenMinMax($nc, 0.03*$maxNC, 0.125*$maxNC) &&
           IsBetweenMinMax($nnc, 0.0, 0.475*$maxNNC)) {
        print OUTPUT $OriginalLine, "\tU2\n";
    }

    # Extract State K/M2    CHANGED 7/13/16
    elsif (IsBetweenMinMax($rmsd, 7.0, 26.5) &&
           IsBetweenMinMax($rg, 0.0, 13.0) &&
           IsBetweenMinMax($nc, 0.03*$maxNC, 0.125*$maxNC) &&
           IsBetweenMinMax($nnc, 0.475*$maxNNC, $maxNNC)) {
        print OUTPUT $OriginalLine, "\tM2\n";
    }

    # Extract State L/M3    CHANGED 7/13/16
    elsif (IsBetweenMinMax($rmsd, 0.0, 17.0) &&
           IsBetweenMinMax($nc, 0.0, 0.03*$maxNC)) {
        print OUTPUT $OriginalLine, "\tM3\n";
    }

    # Extract State U/U3    CHANGED 7/13/16
    elsif (IsBetweenMinMax($rmsd, 17.0, $maxRMSD) &&
           IsBetweenMinMax($nc, 0.0, 0.03*$maxNC)) {
        print OUTPUT $OriginalLine, "\tU3\n";
    }

    else {
        print OUTPUT $OriginalLine, "\tX\n";
    }
}

close INPUT;
close OUTPUT;
close LOG;

sub IsBetweenMinMax
{
    my $number = $_[0];
    my $min = $_[1];
    my $max = $_[2];
    my $numberIsBetweenMinMax = 0;
    if ($number >= $min && $number < $max) { $numberIsBetweenMinMax = 1; }
    return $numberIsBetweenMinMax;
}
