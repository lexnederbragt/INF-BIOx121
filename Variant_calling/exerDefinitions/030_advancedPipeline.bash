# main purpose of this exercise script:
# - demonstrate the commands that refine a BAM file
# - show how this affects our ability to correctly predict variants

# SETTING UP FOR EXERCISE ######################################################

# MAKE SURE that we have locations setup
source $HOME/vc/exerDefinitions/setupEnv.bash

# MAKE SURE you are located in a sensible place
mkdir -p ${exerDir}/03_advancedPipeline
cd ${exerDir}/03_advancedPipeline

# We do not redo the mapping of the reads
# >> instead we pickup the result from the basic pipeline
inputBamFile=../02_basicPipeline/aln.posiSrt.withRG.mrkdDups.bam

# dataDir variable is set in the setupEnv.bash script (it may be local or central) 
refFile=${dataDir}/human_g1k_v37_chr5/gatkBundle/human_g1k_v37_chr5.fasta
knownVariants=${dataDir}/human_g1k_v37_chr5/gatkBundle/dbsnp_132.b37_chr5.vcf
tiles=${dataDir}/human_g1k_v37_chr5/agilentV1/agilent37M.chr5.b37.bed

## PERFORM THE REALIGNMENT AROUND INDELS #############################################

# Identify regions affected by indels and requiring re-alignment
# BE PATIENT: this may take a while
java -Xmx2G -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T RealignerTargetCreator \
-R $refFile \
-o realignment.intervals \
-I $inputBamFile \
--known $knownVariants

# Performing the actual re-alignment
java -Xmx2G -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T IndelRealigner \
-I $inputBamFile \
-R $refFile \
-targetIntervals realignment.intervals \
-o aln.posiSrt.clean.bam \
-compress 0 \
--disable_bam_indexing

## MARK DUPLICATES ###################################################################

# Redoing the marking of duplicates as alignment positions may have changed
java -Xmx2G -jar ${swDir}/picard-tools-1.67/MarkDuplicates.jar \
INPUT=aln.posiSrt.clean.bam \
OUTPUT=aln.posiSrt.clean.dedup.bam \
METRICS_FILE=aln.posiSrt.clean.dedup.bam_metrics.duplication.txt \
CREATE_INDEX=true \
REMOVE_DUPLICATES=false \
COMMENT="MarkDuplicates.jar_run_on_cleaned_alignments"

## BASE QUALITY SCORE RECALIBRATION ##################################################

## count covariates before recalibration
## i.e. generate the statistics on which to base the recalibration
# ReadGroup and QualityScore covariates are required
java -Xmx2G -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T BaseRecalibrator \
-l INFO \
-R ${refFile} \
-I aln.posiSrt.clean.dedup.bam \
-knownSites $knownVariants \
--out aln.posiSrt.clean.dedup.bam_recal.txt \
-cov ReadGroupCovariate \
-cov QualityScoreCovariate \
-cov ContextCovariate \
-cov CycleCovariate


# Second PrintReads to apply the recalibration
java -Xmx2G -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T PrintReads \
-l INFO \
-R ${refFile} \
-I aln.posiSrt.clean.dedup.bam \
-BQSR aln.posiSrt.clean.dedup.bam_recal.txt \
--out aln.posiSrt.clean.dedup.recal.bam 


## VARIANT CALLING ###############################################################


# Call variants ###########################


# Compute the variants ##############
# -L limits variant calling to the regions we captured
# -glm BOTH tell the program to call both SNPs and indels
java -Xmx2G -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T UnifiedGenotyper \
--validation_strictness STRICT \
-R $refFile \
-I aln.posiSrt.clean.dedup.recal.bam \
-L ${dataDir}/human_g1k_v37_chr5/agilentV1/agilent37M.chr5.b37.interval_list \
-glm BOTH \
--dbsnp $knownVariants \
-o snpsAndIndelsHQ.raw.vcf

# Create files containing only the SNPs and only the indels
java -Xmx2G -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T  SelectVariants \
-R $refFile \
--variant snpsAndIndelsHQ.raw.vcf \
--out snpsHQ.raw.vcf \
--select_expressions '!vc.isIndel()'

java -Xmx2G -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T SelectVariants \
-R $refFile \
--variant snpsAndIndelsHQ.raw.vcf \
--out indelsHQ.raw.vcf \
--select_expressions 'vc.isIndel()'


# Hard filtration of SNPs variants to remove false positives
# NOTE: this operation does not remove any records from the file but it sets the FILTER field
java -Xmx2G -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T VariantFiltration \
-R $refFile \
--variant snpsHQ.raw.vcf \
-o snpsHQ.raw.filt.vcf \
--filterExpression "QD<2.0" \
--filterExpression "MQ<40.0" \
--filterExpression "FS>60.0" \
--filterName "QDFilter" \
--filterName "MQFilter" \
--filterName "FSFilter"

# You can get a quick overview of the numbers that failed the filtering and what type of filter was failed
# In the code below we: eliminate the vcf header, print out column 7, sort this column, and count up each type of filter value
grep -v "^#" snpsHQ.raw.filt.vcf | awk 'BEGIN{OFS="\t"; FS="\t";};{print $7};END{}' | sort | uniq -c

# Hard filtration of indels in attempt to remove false positives
# NOTE: this operation does not remove any records from the file but it sets the FILTER field
# NOTE: the types of filter and the cutoffs are different for snps and indels
java -Xmx2G -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T VariantFiltration \
-R $refFile \
--variant indelsHQ.raw.vcf \
-o indelsHQ.raw.filt.vcf \
--filterExpression "QD<2.0" \
--filterExpression "FS>200.0" \
--filterName "QDFilter" \
--filterName "FSFilter"

# Again we take a look at the flags
grep -v "^#" indelsHQ.raw.filt.vcf | awk 'BEGIN{OFS="\t"; FS="\t";};{print $7};END{}' | sort | uniq -c

# Finished: in a later exercise we will assess whether this made a big difference.



