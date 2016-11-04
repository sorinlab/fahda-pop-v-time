CUTOFF_TIME="6000"
INPUT="../luteo_boundary_defined_macrostates_labeled_${CUTOFF_TIME}ps.txt"
POP_V_TIME="../luteo_boundary_defined_macrostates_pop_v_time_${CUTOFF_TIME}ps.txt"
LOG2="../pop_v_time_${CUTOFF_TIME}ps.log"

echo "Running: ./pop_v_time.pl $INPUT $POP_V_TIME $LOG2 . . . "
./pop_v_time.pl $INPUT $POP_V_TIME $LOG2
echo "Done!"
