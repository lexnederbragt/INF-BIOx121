#!/bin/bash

# supply the metrics report as input
# assumes the definitions are in same dir as this script

grep -A 3 "## METRICS CLASS" $1 \
| sed 1d \
| awk 'BEGIN{OFS="\t"; FS="\t";};{for( i=1 ; i<=NF ; i++ ){lines[i]= lines[i] "\t" $i;}};END{for( i=1 ; i<=length(lines) ; i++ ){print lines[i]}}' \
| paste - `dirname $0`/metricsDefs_duplication.txt | \
awk 'BEGIN{OFS="\t"; FS="\t";}; \
{if($2 == $4){print $2, $3, $5}else{print "Mismatch of definition at line "NR; print $2 "not matching " $4; print "Aborting"; exit}};\
END{}'