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

our $maxRMSD = 32.660;
our $maxRg = 34.398;
our $maxNC = 1101.77;
our $maxNNC = 1930;
our $cutOffTimeInPicoSeconds = 6000;

our $inputFilename = $ARGV[0];
our $outputFilename = $ARGV[1];
our $logFilename = $ARGV[2];

#...............................................................................
open (INPUT, "<", $inputFilename) or die "Cannot open $inputFilename. $!\n";
open (LOG, ">", $logFilename) or die "Cannot open $logFilename. $!\n";
open (OUTPUT, ">", $outputFilename) or die "Cannot open $outputFilename. $!\n";

#...............................................................................
our $timeColumn = 000; #TODO
our $rmsdColumn = 111; #TODO
our $rgColumn = 222; #TODO
our $ncColumn = 333; #TODO
our $nncColumn = 444; #TODO

while (my $line = <INPUT>) {
    my $OriginalLine = chomp($line);

    my @items = split(/\s+/, $line);
    my $time  = $items[$timeColumn];

    if ($time < $cutOffTimeInPicoSeconds) { next; }

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
