#!/bin/bash

# main purpose of script is to:
# - work with the simulated dataset
# - run through a variant calling pipeline with more understanding of what is happening

# SETTING UP FOR EXERCISE ######################################################

# MAKE SURE that we have locations setup
source $HOME/vc/exerDefinitions/setupEnv.bash

# MAKE SURE you are located in a sensible location to start the exercise
mkdir -p ${exerDir}/02_basicPipeline
cd ${exerDir}/02_basicPipeline

# Defining variables to avoid having to use very long paths
# dataDir variable is set in the setupEnv.bash script (it may be local or central) 
read1FqFile=${dataDir}/reads_agilentV1_chr5/simul_indels/simul_agilentV1_chr5.R1.fastq.gz
read2FqFile=${dataDir}/reads_agilentV1_chr5/simul_indels/simul_agilentV1_chr5.R2.fastq.gz
refFile=${dataDir}/human_g1k_v37_chr5/gatkBundle/human_g1k_v37_chr5.fasta


# MAP THE READS TO THE REFERENCE ##############################################

# Take a look at the fastq files >> briefly see if they make any sense to you
# Check out the qualities >> why do you think they look like this?
# The fastq files are gzipped up, so you need to use gunzip to look at them
gunzip -c $read1FqFile | head
gunzip -c $read2FqFile | head

# Mapping reads without considering pair information
bwa aln -t 3 $refFile $read1FqFile > aln_sa1.sai
bwa aln -t 3 $refFile $read2FqFile > aln_sa2.sai

# Finish mapping using pair information
bwa sampe $refFile aln_sa1.sai aln_sa2.sai $read1FqFile $read2FqFile > aln.sam

## Nota bena: there is a faster mapping algorithm called "mem" which is faster and has been implemented in one step: bwa mem -t 3 $refFile $read1FqFile $read2FqFile > aln_mem.sam

# Take a look at the alignment file (SAM)
# You should be able to understand the contents of this file if you have been through the SAM slides
# You should for example know where a read maps and in which column to find a measure of the mapping reliability
head aln.sam

# TIDY UP THE SAM FILE 	#########################################################

# Make sure the mates have updated information about each other (not relying on aligner to do this properly)
java -jar ${swDir}/picard-tools-1.67/FixMateInformation.jar SORT_ORDER=coordinate INPUT=aln.sam OUTPUT=aln.posiSrt.bam CREATE_INDEX=true

# Add metadata about sample to bam file
java -jar ${swDir}/picard-tools-1.67/AddOrReplaceReadGroups.jar \
CREATE_INDEX=true \
INPUT=aln.posiSrt.bam \
OUTPUT=aln.posiSrt.withRG.bam \
RGLB="simulation" \
RGPL="Illumina" \
RGPU="simulRun_noBarcode" \
RGSM="mutatedRef" \
RGCN="NSC" \
RGDS="Some_description_of_the_read_group"

# Take a look at the header to see where this information has been placed
# "-h" to ensure the hader is output
samtools view -h aln.posiSrt.withRG.bam | less

# Mark duplicates to add information about duplicates to the file
java -jar ${swDir}/picard-tools-1.67/MarkDuplicates.jar \
INPUT=aln.posiSrt.withRG.bam \
OUTPUT=aln.posiSrt.withRG.mrkdDups.bam \
METRICS_FILE=aln.posiSrt.withRG.mrkdDups.bam_metrics.duplication.txt \
CREATE_INDEX=true \
REMOVE_DUPLICATES=false \
COMMENT="MarkDuplicates.jar_run_on_raw_BWA_alignments"

# CHECK THE BAM FILE ############################################################

# Note that there are different levels of VALIDATION_STRINGENCY: STRICT, LENIENT, SILENT
java -jar ${swDir}/picard-tools-1.67/ValidateSamFile.jar \
VALIDATION_STRINGENCY=STRICT \
MODE=VERBOSE \
IGNORE_WARNINGS=false \
REFERENCE_SEQUENCE=${refFile} \
VALIDATE_INDEX=true \
INPUT=aln.posiSrt.withRG.mrkdDups.bam


# CALL VARIANTS #################################################################

# Compute the variants ##############
# -L limits variant calling to the regions we captured
# -glm BOTH tell the program to call both SNPs and indels
java -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T UnifiedGenotyper \
--validation_strictness STRICT \
-R $refFile \
-I aln.posiSrt.withRG.mrkdDups.bam \
-L ${dataDir}/human_g1k_v37_chr5/agilentV1/agilent37M.chr5.b37.interval_list \
-glm BOTH \
-o snpsAndIndels.raw.vcf

# Take a look at the output
# See if you can distinguish between a SNP and an indel
less snpsAndIndels.raw.vcf


# Create files containing only the SNPs and only the indels
java -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T SelectVariants \
-R $refFile \
--variant snpsAndIndels.raw.vcf \
--out snps.raw.vcf \
--select_expressions '!vc.isIndel()'

java -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T SelectVariants \
-R $refFile \
--variant snpsAndIndels.raw.vcf \
--out indels.raw.vcf \
--select_expressions 'vc.isIndel()'

# Count snps and indels
# grep helps us remove the header (only select lines that do not start with #)
grep -v "^#" snps.raw.vcf | wc -l
grep -v "^#" indels.raw.vcf | wc -l


# Et voilˆ, finished!!!