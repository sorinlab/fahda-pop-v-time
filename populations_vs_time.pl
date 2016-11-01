#!/usr/bin/env perl

# ==============================================================================
# AUTHOR: KHAI NGUYEN
# DATE  : FALL 2014
# INPUT :
# OUTPUT:
# ==============================================================================

$usage = '$ perl  script.pl   -i input.txt   -c 0   -o pop_v_time.txt
    -i       input.txt      K-means clustering trial file (input, required)
    -c               0      The time column (zero-based, input, required)
    -o    pop_v_time.txt    Populations at each time frame for each cluster
                            (output, required)
';

#================== GET INPUT FROM COMMAND LINE ================================
	for (my $i = 0; $i < $#ARGV; $i++)
	{
		if    ($ARGV[$i] eq "-i") { $i++;  $input   = $ARGV[$i]; } # input
		elsif ($ARGV[$i] eq "-c") { $i++;  $timeCol = $ARGV[$i]; } # input
		elsif ($ARGV[$i] eq "-o") { $i++;  $output  = $ARGV[$i]; } # output
	}

	if ($ARGV[0] eq "-h") { print "\n\t$usage\n"; exit; }
	if ($#ARGV < 5) { print "ERROR: Incorrect parameters.\n\n\t$usage\n"; exit; }

	print "\tInput file:  $input\n";
	print "\tTime column: $timeCol\n";
	print "\tOutput file: $output\n";


#===============================================================================
# Read Clusters to have clusters' frame. 
# Open data file, do (1) read "cluster" column, (2) save unique time frames,
# and (3) count populations for each time frame per cluster.
#-------------------------------------------------------------------------------
	open(INPUT, '<', $input) or die "ERROR: Cannot open input file $input. $!.\n";

	# Flag to indicate whether the centers info is being read.
	# "true" if the center lines are being read, "false" otherwise.
	$reachCentersInfo = 'false';

	# Flag to indicate whether the populations data are being read.
	# "true" if the population lines are being read, "false" otherwise.
	$reachPopulations = 'false';

	@clusterIDs = (); # Stores cluster numbers
	@timeframes = (); # Stores unique time frames

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
		{ push @clusterIDs, $words[0]; }

		if (($reachPopulations eq 'true') &&
			(scalar @words != 0))
		{ 
			#$cluster_time{"$words[0]-$words[$timeCol]"} += 1;
			push @timeframes, $words[$timeCol];
		}

	} # end of reading input file
	close INPUT;

	
#===============================================================================
# Sort the cluster numbers ascendingly.
# Extract unique time frames and sort ascendingly.
#-------------------------------------------------------------------------------
	@clusterIDs = sort {$a <=> $b} @clusterIDs;
	print "IMPORTED CLUSTER NUMBERS:\n";
	for (my $i = 0; $i <= $#clusterIDs; $i++)
	{ print $clusterIDs[$i], "\n"; }
	print "\n";

	open (TIMEFRAMES, ">", "timeframes.txt");
	foreach my $timeframe (@timeframes)
	{ print TIMEFRAMES $timeframe, "\n"; }
	close TIMEFRAMES;

	@timeframes = `cat timeframes.txt | sort -n | uniq`;
	# The first element will be empty, so we need to remove it.
	shift(@timeframes);

	%popPerTime = (); # Contains population for a timeframe of all clusters
	open (TIMEFRAMES, ">", "timeframes.txt");
	for (my $i = 0; $i <= $#timeframes; $i++)
	{
		chomp $timeframes[$i];
		print TIMEFRAMES $timeframes[$i], "\t";
		$popPerTime{$timeframes[$i]} = 0;
	}
	close TIMEFRAMES;

	# Count populations for each timeframe of each cluster
	# $key => $value is "clusterID-time" => count
	%cluster_time = (); 
	

	# Initialize hash table for storing populations
	for (my $i = 0; $i <= $#clusterIDs; $i++)
	{
		
		for (my $j = 0; $j <= $#timeframes; $j++)
		{
			my $cluster = $clusterIDs[$i];
			my $time    = $timeframes[$j];
			$cluster_time{"$cluster-$time"} = 0;
		}
	}

	# foreach $key (sort {$a <=> $b} keys %popPerTime)
	# { print "$key\n"; }


#=================== COUNT ==============================
	# Flag to indicate whether the populations data are being read.
	# "true" if the population lines are being read, "false" otherwise.
	$reachPopulations = 'false';
	
	open(INPUT, '<', $input) or die "ERROR: Cannot open input file $input. $!.\n";
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

		
		if ($original_line eq "# Class	dist(1)	dist(2)	<Delta(dist)>")
		{ $reachPopulations = 'true'; next; }
		if ($line eq "") { $reachPopulations = 'false'; }
		
		if (($reachPopulations eq 'true') &&
			(scalar @words >= $timeCol))
		{
			$popPerTime{$words[$timeCol]} += 1; # Count pop per time frame of all clusters
			#print "$.\t$words[0]\t$words[$timeCol]\t";
			$cluster_time{"$words[0]-$words[$timeCol]"} += 1;
			#print $cluster_time{"$words[0]-$words[$timeCol]"}, "\n";
		}

	} # end of reading input file

	$totalPop = 0;
	foreach $key (sort {$a <=> $b} keys %popPerTime)
	{ $totalPop += $popPerTime{$key}; }
	print "Total population is: $totalPop.\n";
	print "Expected total population: 1166656\n\n";


#=================== WRITE RESULTS TO OUTPUT FILE ==============================
	open OUTPUT, ">", $output 
	or die "Cannot write to output file $output. $!.\n";
	
	
	for (my $i = 0; $i <= $#clusterIDs; $i++)
	{
		my $cluster = $clusterIDs[$i];
		
		for (my $j = 0; $j <= $#timeframes; $j++)
		{
			my $time = $timeframes[$j];
			#if ($popPerTime{$cluster} == 0) { print "ERROR: $cluster\n"; }
			my $count = $cluster_time{"$cluster-$time"} / $popPerTime{$time} * 100;
			#if ($cluster_time{"$cluster-$time"} =~ m/\d/)
			printf OUTPUT "% 5.2f\t", $count;
			#else { print OUTPUT "0\t"; }
			
		}
		print OUTPUT "\n";
	}

	close OUTPUT;	