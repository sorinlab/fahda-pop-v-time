#!/bin/sh

CUTOFF_TIME="6000"
INPUT="../luteo_boundary_defined_macrostates_labeled_${CUTOFF_TIME}ps.txt"
OUTPUT="../luteo_boundary_defined_macrostates_pop_v_time_${CUTOFF_TIME}ps.txt"

printf "Running: ./pop-v-time.pl $INPUT $OUTPUT . . . "
./pop-v-time.pl $INPUT $OUTPUT
printf "Done!"
