#!/usr/bin/env perl

# ==============================================================================
# AUTHOR: KHAI NGUYEN
# DATE  : FALL 2014
# INPUT :
# OUTPUT:
# ==============================================================================

$usage = '$ perl  script.pl   -i input.txt   -c 0   -o pop_v_time.txt
    -i       input.txt      K-means clustering trial file (input, required)
    -c             int      The time column (zero-based, input, required)
    -t             int      Cutoff time (ps) to begin counting population
    -o    pop_v_time.txt    Populations at each time frame for each cluster
                            (output, required)
';

#================== GET INPUT FROM COMMAND LINE ================================
	for (my $i = 0; $i < $#ARGV; $i++)
	{
		if    ($ARGV[$i] eq "-i") { $i++;  $input   = $ARGV[$i]; } # input
		elsif ($ARGV[$i] eq "-c") { $i++;  $timeCol = $ARGV[$i]; } # input
		elsif ($ARGV[$i] eq "-t") { $i++;  $cutTime = int($ARGV[$i]); } # cutoff time
		elsif ($ARGV[$i] eq "-o") { $i++;  $output  = $ARGV[$i]; } # output
	}

	if ($ARGV[0] eq "-h") { print "\n\t$usage\n"; exit; }
	if (scalar @ARGV < 8) { print "ERROR: Incorrect parameters.\n\n\t$usage\n"; exit; }

	print "\tInput file       : $input\n";
	print "\tTime column      : $timeCol\n";
	print "\tCutoff time (ps) : $cutTime\n";
	print "\tOutput file      : $output\n";


#===============================================================================
# Read Clusters to have clusters' frame. 
# Open data file, do (1) read "cluster" column, (2) save unique time frames,
# and (3) count populations for each time frame per cluster.
#-------------------------------------------------------------------------------
	open INPUT, '<', $input or die "ERROR: Cannot open input file $input. $!.\n";

	# Flag to indicate whether the centers info is being read.
	# "true" if the center lines are being read, "false" otherwise.
	$reachCentersInfo = 'false';

	# Flag to indicate whether the populations data are being read.
	# "true" if the population lines are being read, "false" otherwise.
	$reachPopulations = 'false';

	%populations = (); # Stores cluster numbers, "cluster #" ==> "population"
	#@timeframes = (); # Stores unique time frames

	while (my $line = <INPUT>)
	{
		chomp($line); # removes new-line character at end of line
		my $original_line = $line;

		foreach ($line)
		{
			s/^\s+//;  # Removes leading white spaces
			s/\s+$//;  # Removes trailing white spaces
			s/\s+/ /g; # Replaces spaces btw 2 words by a single space
		}
		my @words = split(' ', $line);

		if ($original_line eq "#  group  pop	centers")
		{ $reachCentersInfo = 'true'; next; }

		if ($original_line eq "# Class	dist(1)	dist(2)	<Delta(dist)>")
		{ $reachCentersInfo = 'false'; $reachPopulations = 'true'; next; }

		#-----------------------------------------------------------------------
		# If the centers are being read, store cluster numbers in memory
		if (($reachCentersInfo eq 'true') &&
			(scalar @words != 0))
		# The first word is cluster number/ID
		{ $populations{$words[0]} = 0; }

		if (($reachPopulations eq 'true') &&
			(scalar @words != 0))
		{
			# increase pouplation only when 
			# time is greater than or equal to
			if ($words[$timeCol] >= $cutTime)
			{ $populations{$words[0]} += 1; }	
		}

	} # end of reading input file
	close INPUT;

	
#=================== WRITE RESULTS TO OUTPUT FILE ==============================
	open OUTPUT, ">", $output 
	or die "Cannot write to output file $output. $!.\n";
	print OUTPUT "#\tInput file       : $input\n";
	print OUTPUT "#\tTime column      : $timeCol\n";
	print OUTPUT "#\tCutoff time (ps) : $cutTime\n";
	print OUTPUT "#\tOutput file      : $output\n";

	foreach my $cluster (sort {$a <=> $b} keys %populations)
	{	
		printf OUTPUT "% 2d\t% 7d\n", $cluster, $populations{$cluster};
	}

	close OUTPUT;	