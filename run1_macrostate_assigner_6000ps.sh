#!/bin/sh

CUTOFF_TIME="6000"
INPUT="$HOME/PKNOT/analysis/clustering/kmeans-clustering-results/final_LUTEO_kmeans_with_new_native_contacts.txt"
OUTPUT="../luteo_boundary_defined_macrostates_labeled_${CUTOFF_TIME}ps.txt"

print "Running: ./macrostates-assigner.pl $INPUT $CUTOFF_TIME $OUTPUT . . . "
./macrostates-assigner.pl $INPUT $CUTOFF_TIME $OUTPUT
print "Done!\n"
