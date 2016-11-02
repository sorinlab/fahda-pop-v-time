#!/usr/bin/perl -w

# Author: Khai Nguyen
# Date:   July 2016
# Purpose: A macrostate is identified by four dimensions: RMSD, Rg, native 
#          contacts, and non-native contacts. These boundaries for each 
#          macrostate are specified in the argument input file. The data points 
#          whose values in these boundaries are extracted and placed in a file.

$maxRMSD       = 32.660;
$maxRg         = 34.398;
$maxNC         = 1101.77;
$maxNNC        = 1930;
$CutOffTime    = 6000;

$input         = $ARGV[0]; # big log file with all data points
$output_prefix = $ARGV[1];

# -------------------------------- INITIALIZATION ------------------------------
$LogFile  = "macrostates-extractor.log";
my $NonAssignedDataLog = "";

open (INPUT, "<", $input) or die "Cannot open $input. $!\n";
open (LOG, ">", $LogFile) or die "Cannot open $LogFile. $!\n";

open (OUT_A, ">", "${output_prefix}F1.txt") or die "Cannot open ${output_prefix}A.txt. $!\n";
open (OUT_B, ">", "${output_prefix}F2.txt") or die "Cannot open ${output_prefix}B.txt. $!\n";
open (OUT_C, ">", "${output_prefix}I1.txt") or die "Cannot open ${output_prefix}C.txt. $!\n";
open (OUT_E, ">", "${output_prefix}I2.txt") or die "Cannot open ${output_prefix}E.txt. $!\n";
open (OUT_G, ">", "${output_prefix}M4.txt") or die "Cannot open ${output_prefix}G.txt. $!\n";
open (OUT_H, ">", "${output_prefix}M1.txt") or die "Cannot open ${output_prefix}H.txt. $!\n";
open (OUT_I, ">", "${output_prefix}U1.txt") or die "Cannot open ${output_prefix}I.txt. $!\n";
open (OUT_J, ">", "${output_prefix}U2.txt") or die "Cannot open ${output_prefix}J.txt. $!\n";
open (OUT_K, ">", "${output_prefix}M2.txt") or die "Cannot open ${output_prefix}K.txt. $!\n";
open (OUT_L, ">", "${output_prefix}M3.txt") or die "Cannot open ${output_prefix}L.txt. $!\n";
open (OUT_U, ">", "${output_prefix}U3.txt") or die "Cannot open ${output_prefix}U.txt. $!\n";

my %MacrostatePopulations = ();
$MacrostatePopulations{"F1"} = 0;
$MacrostatePopulations{"F2"} = 0;
$MacrostatePopulations{"I1"} = 0;
$MacrostatePopulations{"I2"} = 0;
$MacrostatePopulations{"M4"} = 0;
$MacrostatePopulations{"M1"} = 0;
$MacrostatePopulations{"U2"} = 0;
$MacrostatePopulations{"M2"} = 0;
$MacrostatePopulations{"M3"} = 0;
$MacrostatePopulations{"U3"} = 0;
$MacrostatePopulations{"X"} = 0; # Counts the number of datum not assigned to a macrostate

# -------- EXTRACTING DATA POINTS FOR EACH MACROSTATE --------------------------
while (my $line = <INPUT>) 
{
    my $OriginalLine = $line;

    foreach ($line) { s/^\s+//; s/\s+$//; s/\s+/ /g; }
    my @items = split(' ', $line);
    my $time  = $items[4];

    if ($time < $CutOffTime) { next; }
    
    my $rmsd    = $items[5];  # RMSD
    my $rg      = $items[6];  # Rg
    my $nc      = $items[12]; # Native contacts
    my $nnc     = $items[13]; # Non-native contacts
    
    # Extract State A/F1    SAME
    if (IsBetweenMinMax($rmsd, 0.0, 3.0))
    {   
        print OUT_A $OriginalLine;
        $MacrostatePopulations{"F1"} += 1;
    }

    # Extract State B/F2    CHANGED 7/13/16
    elsif (IsBetweenMinMax($rmsd, 3.0, 6.0) &&
           IsBetweenMinMax($nc, 0.775*$maxNC, $maxNC))
    {
        print OUT_B "$OriginalLine";
        $MacrostatePopulations{"F2"} += 1;
    }

    # Extract State C/I1    CHANGED 7/13/16
    elsif (IsBetweenMinMax($rmsd, 3.5, 6.5) &&
           IsBetweenMinMax($nc, 0.55*$maxNC, 0.775*$maxNC))
    {
        print OUT_C "$OriginalLine";
        $MacrostatePopulations{"I1"} += 1;
    }

    # Extract State E/I2    CHANGED 7/13/16
    elsif (IsBetweenMinMax($rmsd, 6.5, 11.0) &&
           IsBetweenMinMax($nc, 0.375*$maxNC, 0.70*$maxNC))
    {
        print OUT_E "$OriginalLine";
        $MacrostatePopulations{"I2"} += 1;
    }

    # Extract State G/M4    CHANGED 7/13/16
    elsif (IsBetweenMinMax($rmsd, 10.0, 24.0) &&
           IsBetweenMinMax($nc, 0.25*$maxNC, 0.45*$maxNC))
    {
        print OUT_G "$OriginalLine";  
        $MacrostatePopulations{"M4"} += 1;
    }

    # Extract State H/M1    CHANGED 7/13/16 
    elsif (IsBetweenMinMax($rmsd, 6.5, 10.0) &&
           IsBetweenMinMax($nc, 0.125*$maxNC, 0.30*$maxNC))
    {   
        print OUT_H "$OriginalLine";  
        $MacrostatePopulations{"M1"} += 1;
    }

    # Extract State I/U1    CHANGED 7/13/16
    elsif (IsBetweenMinMax($rmsd, 10.0, 17.0) &&
           IsBetweenMinMax($nc, 0.125*$maxNC, 0.25*$maxNC))
    {
        print OUT_I "$OriginalLine";  
        $MacrostatePopulations{"U1"} += 1;
    }

    # Extract State J/U2    CHANGED 7/13/16
    elsif (IsBetweenMinMax($rmsd, 7.0, 26.5) &&
           IsBetweenMinMax($rg, 13.0, $maxRg) &&
           IsBetweenMinMax($nc, 0.03*$maxNC, 0.125*$maxNC) &&
           IsBetweenMinMax($nnc, 0.0, 0.475*$maxNNC))
    {
        print OUT_J "$OriginalLine";  
        $MacrostatePopulations{"U2"} += 1;
    }

    # Extract State K/M2    CHANGED 7/13/16
    elsif (IsBetweenMinMax($rmsd, 7.0, 26.5) &&
           IsBetweenMinMax($rg, 0.0, 13.0) &&
           IsBetweenMinMax($nc, 0.03*$maxNC, 0.125*$maxNC) &&
           IsBetweenMinMax($nnc, 0.475*$maxNNC, $maxNNC))
    {
        print OUT_K "$OriginalLine";
        $MacrostatePopulations{"M2"} += 1;
    }

    # Extract State L/M3    CHANGED 7/13/16
    elsif (IsBetweenMinMax($rmsd, 0.0, 17.0) &&
           IsBetweenMinMax($nc, 0.0, 0.03*$maxNC))
    {
        print OUT_L "$OriginalLine";  
        $MacrostatePopulations{"M3"} += 1;
    }

    # Extract State U/U3    CHANGED 7/13/16
    elsif (IsBetweenMinMax($rmsd, 17.0, $maxRMSD) &&
           IsBetweenMinMax($nc, 0.0, 0.03*$maxNC))
    {
        print OUT_U "$OriginalLine";  
        $MacrostatePopulations{"U3"} += 1;
    }

    # Keep track of which datum not assigned to a macrostate
    else
    {
        $NonAssignedDataLog .= "$OriginalLine";
        $MacrostatePopulations{"X"} += 1;
    }    
}

my $MacrostatePopulationsLog = "# Macrostate populations:\n";
my $TotalMacrostatePopulation = 0;
foreach my $macrostateKey (sort keys %MacrostatePopulations)
{
    if ($macrostateKey eq "X") { next; }
    $MacrostatePopulationsLog .= "# Macrostate $macrostateKey: \t$MacrostatePopulations{$macrostateKey}\n";
    $TotalMacrostatePopulation += $MacrostatePopulations{$macrostateKey}
}

print LOG $MacrostatePopulationsLog;
print LOG "# TOTAL: $TotalMacrostatePopulation\n";
print LOG "\n# Number of unassigned data points: " . $MacrostatePopulations{"X"} . "\n";
print LOG $NonAssignedDataLog;

close INPUT;
close OUT_A;
close OUT_B;
close OUT_C;
close OUT_E;
close OUT_G;
close OUT_H;
close OUT_I;
close OUT_J;
close OUT_K;
close OUT_L;
close OUT_U;
close LOG;

sub IsBetweenMinMax
{
    local($number, $min, $max) = @_;
    my $numberIsBetweenMinMax = 0;
    if ($number >= $min && $number < $max) { $numberIsBetweenMinMax = 1; }
    return $numberIsBetweenMinMax;
}
