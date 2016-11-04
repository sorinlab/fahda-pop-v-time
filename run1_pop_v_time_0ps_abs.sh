#!/bin/sh

CUTOFF_TIME="0.0"
INPUT="../luteo_boundary_defined_macrostates_labeled_${CUTOFF_TIME}ps.txt"
OUTPUT="../luteo_boundary_defined_macrostates_pop_v_time_${CUTOFF_TIME}ps_abs.txt"

printf "Running: ./pop-v-time-abs.pl $INPUT $OUTPUT. . . "
./pop-v-time-abs.pl $INPUT $OUTPUT
printf "Done!"
