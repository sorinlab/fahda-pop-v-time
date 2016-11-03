INPUT="$HOME/PKNOT/analysis/clustering/kmeans-clustering-results/final_LUTEO_kmeans_with_new_native_contacts.txt"
CUTOFF_TIME="0.0"
OUTPUT="../luteo_boundary_defined_macrostates_labeled_${CUTOFF_TIME}ps.txt"
LOG1="../macrostates-assigner-${CUTOFF_TIME}.log"

POP_V_TIME="../luteo_boundary_defined_macrostates_pop_v_time_${CUTOFF_TIME}ps.txt"
LOG2="../pop_v_time_${CUTOFF_TIME}ps.log"

#echo "Running: ./macrostates-assigner.pl $INPUT $CUTOFF_TIME $OUTPUT $LOG1 . . . "
#./macrostates-assigner.pl $INPUT $CUTOFF_TIME $OUTPUT $LOG1
#echo "Done!\n"

echo "Running: ./pop_v_time.pl $OUTPUT $POP_V_TIME $LOG2 . . . "
./pop_v_time.pl $OUTPUT $POP_V_TIME $LOG2
echo "Done!\n"
