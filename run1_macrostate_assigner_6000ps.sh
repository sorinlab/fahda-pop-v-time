INPUT="$HOME/PKNOT/analysis/clustering/kmeans-clustering-results/final_LUTEO_kmeans_with_new_native_contacts.txt"
CUTOFF_TIME="6000"
OUTPUT="../luteo_boundary_defined_macrostates_labeled_${CUTOFF_TIME}ps.txt"
LOG1="../macrostates-assigner-${CUTOFF_TIME}.log"

echo "Running: ./macrostates-assigner.pl $INPUT $CUTOFF_TIME $OUTPUT $LOG1 . . . "
./macrostates-assigner.pl $INPUT $CUTOFF_TIME $OUTPUT $LOG1
echo "Done!"
