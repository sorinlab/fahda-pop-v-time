#!/usr/bin/perl

for ($i = 1; $i <= 110; $i++)
{
    # $ perl  script.pl   -i input.txt   -c 0   -o pop_v_time.txt
    $input = "../2.2-TRIALS-RENUMBERRED/pknot.Trial_$i.kmeans.100.by_rmsd.txt";
	$timeColumn = 13;
    $output = "pknot.Trial_$i.pop_v_time.txt";
    print "Working on: $input... ";
    `./populations_vs_time.pl -i $input -c $timeColumn -o $output`;
    print "DONE!\n";
}
#./populations_vs_time.pl
#../2.2-TRIALS-RENUMBERRED/pknot.Trial_1.kmeans.100.by_rmsd.txt
