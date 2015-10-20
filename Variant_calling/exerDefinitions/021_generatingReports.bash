#!/bin/bash

# main purpose of script is to gain an insight into what is happening in the pipeline through the generation of reports on:
# - fastq files
# - BAM files
# - VCF files

# SETTING UP FOR EXERCISE ######################################################

# MAKE SURE that we have locations setup
source $HOME/vc/exerDefinitions/setupEnv.bash

# MAKE sure you are in the directory with the relevant data files
mkdir -p ${exerDir}/02_basicPipeline
cd ${exerDir}/02_basicPipeline


# Set up variables to make our life easier
# dataDir variable is set in the setup.bash script (it may be local or central) 
read1FqFile=${dataDir}/reads_agilentV1_chr5/simul_indels/simul_agilentV1_chr5.R1.fastq.gz
read2FqFile=${dataDir}/reads_agilentV1_chr5/simul_indels/simul_agilentV1_chr5.R2.fastq.gz
refFile=${dataDir}/human_g1k_v37_chr5/gatkBundle/human_g1k_v37_chr5.fasta
bamFile=aln.posiSrt.withRG.mrkdDups.bam

# If you did not complete 020_basicPipeline.bash, you will need to execute:
# cp ${centralVcDir}/exerResults/02_basicPipeline/${bamFile} .

## FASTQ FILES ##############################################################

# The main reports we can generate here are the fastqc
# Start fastqc using following line and load the BAM file: aln.posiSrt.withRG.mrkdDups.bam
# fastqc
 
# Notice the number of reads, we could have done this ourselves on the command line
gunzip -c $read1FqFile | wc -l
# notice the unusual pattern in the qualities. Why do you think this is? Could it be due to the simulation? For example that we have a rather crude model of base quality.


## BAM FILE REPORTS #########################################################

## Alignment ################################

java -jar ${swDir}/picard-tools-1.67/CollectAlignmentSummaryMetrics.jar \
INPUT=${bamFile} \
OUTPUT=${bamFile}_metrics.alignment.txt \
REFERENCE_SEQUENCE=$refFile

# Take a look at the alignment metrics output >> you will see that this is not easy to read:
# less ${bamFile}_metrics.alignment.txt

# Lets beautify the output a bit
# We use little helper script which adds in definitions of the different fields and the "column" command which generates readable columns of data.
${centralVcDir}/exerDefinitions/helperScripts/beautifyAlignmentMetricsReport.bash ${bamFile}_metrics.alignment.txt | column -t -s $'\t'

# Still difficult to read >> write result to file and import this file into a spreadsheet
# You should take a look at the file once it is in a spreadsheet and check some of the key metrics:
# PCT_PF_READS_ALIGNED  PCT_READS_ALIGNED_IN_PAIRS  PCT_ADAPTER
# Note that many of the other metrics are not that important
${centralVcDir}/exerDefinitions/helperScripts/beautifyAlignmentMetricsReport.bash ${bamFile}_metrics.alignment.txt | column -t -s $'\t' > ${bamFile}_metrics.alignment.beautified.txt 

##############################################
## Duplications ##############################
##############################################

# Lets beautify the dup metrics report we generated in the basic pipeline
# Again key values here are PERCENT_DUPLICATION READ_PAIR_DUPLICATES
${centralVcDir}/exerDefinitions/helperScripts/beautifyDuplicationMetricsReport.bash ${bamFile}_metrics.duplication.txt | column -t -s $'\t' > ${bamFile}_metrics.duplication.beautified.txt
# Take a look at the output:
# less ${bamFile}_metrics.duplication.beautified.txt

# Take a look at a dup from the SAM file in IGV
# Below the -f option allows us to select all reads that have been marked as duplicates (for more on flags see http://broadinstitute.github.io/picard/explain-flags.html)
# We use this to select using awk the reads that duplicates
# And finally head just gives us the first 10 lines of output
samtools view -f 1024 ${bamFile} | head

# You should get something like this:
# 5_156289_156197_1_0_0_0_1:0:0_0:0:0_4f4e0	1187	5	156197	60	100M	=	156289	192	GTTAATTGACCAGCATGAGACGATGATGAAGCTTGTCCTGGAAGACCCACTGCTTGTGTCTCTCAGGCTGGAGGGGGGCACCGTCCTGGCGCGGCTGAGG	??>>>====<<<<<;;;;;;;::::::::99999999998888888888888777777777777777766666666666666666666555555555555	X0:i:1	X1:i:0	MD:Z:100	RG:Z:1	XG:i:0	AM:i:37	NM:i:0	SM:i:37	XM:i:0	XO:i:0	MQ:i:60	XT:A:U
# 5_156289_156197_1_0_0_0_1:0:0_0:0:0_4f4e0	1107	5	156289	60	100M	=	156197	-192	GGCTGAGGAGAGAAGAGCTTGGCACAGAAGACAGCCGGTGAGCGCTCACAGGGGTCATGCTGGGCCCTGGCCCATCGAGGGAGCTGATCGGGGGAGTTTG	55555555555566666666666666666666777777777777777788888888888889999999999::::::::;;;;;;;<<<<<====>>>??	X0:i:1	X1:i:0	MD:Z:86C13	RG:Z:1	XG:i:0	AM:i:37	NM:i:1	SM:i:37	XM:i:1	XO:i:0	MQ:i:60	XT:A:U

# Start up IGV as you have done on other parts of the course

# Go to View >> Preferences >> Alignment tab >> make sure that "Filter duplicates" is NOT ticked
# From the top left pop down select ""Human, 1kg b37+decoy
# Go to File >> load from file and select aln.posiSrt.withRG.mrkdDups.bam
# Right click on the track name and select "View as pairs"
# Let's also load the agilent tiles used in the capture experiment: Go to File >> Load from file >> select from inputData/human_g1k_v37_chr5/agilentV1/agilent37M.chr5.b37.bed
# Copy and paste the location of a duplicate e.g. "5	156197" into the location box (this is the first one above)
# Zoom out a bit and you should see a duplicate pair starting at the center mark (the vertical dotted black lines)

#############################################
## Insert size ##############################
#############################################

java -jar ${swDir}/picard-tools-1.67/CollectInsertSizeMetrics.jar \
HISTOGRAM_FILE=${bamFile}_metrics.insert.pdf \
INPUT=${bamFile} \
OUTPUT=${bamFile}_metrics.insert.txt

# open the PDF file: aln.posiSrt.withRG.mrkdDups.bam_metrics.insert.pdf

# Lets beautify the output text a bit
# Again as before you want to focus in on the most important fields: MEDIAN_INSERT_SIZE MEDIAN_ABSOLUTE_DEVIATION
${centralVcDir}/exerDefinitions/helperScripts/beautifyInsertMetricsReport.bash ${bamFile}_metrics.insert.txt | column -t -s $'\t' > ${bamFile}_metrics.insert.beautified.txt 
# Take a look at the output with:
# less ${bamFile}_metrics.insert.beautified.txt 


## Hybridisation metrics ####################
# Here we compute both overall statistics and statistics for each individual bait (PER_TARGET_COVERAGE)
# Usually one would provide a bait (the enrichment probes) and a target (the exons)
# BUT here to keep it simple we use the same file for both
java -jar ${swDir}/picard-tools-1.67/CalculateHsMetrics.jar \
BAIT_INTERVALS=${dataDir}/human_g1k_v37_chr5/agilentV1/agilent37M.chr5.b37.txt \
TARGET_INTERVALS=${dataDir}/human_g1k_v37_chr5/agilentV1/agilent37M.chr5.b37.txt \
INPUT=${bamFile} \
OUTPUT=${bamFile}_metrics.coverage.txt \
REFERENCE_SEQUENCE=${refFile} \
PER_TARGET_COVERAGE=${bamFile}_metrics.coveragePerTarget.txt

# Focus on the fields of most importance:
# MEAN_BAIT_COVERAGE, ZERO_CVG_TARGETS_PCT, PCT_TARGET_BASES_10X, PCT_TARGET_BASES_20X, PCT_TARGET_BASES_30X, ....
# Based on the lectures and the description fields that have been added to these files you should be able to figure out for yourself what is most important
${centralVcDir}/exerDefinitions/helperScripts/beautifyCoverageMetricsReport.bash ${bamFile}_metrics.coverage.txt  | column -t -s $'\t' > ${bamFile}_metrics.coverage.beautified.txt
# Take a look at the output with:
# less ${bamFile}_metrics.coverage.beautified.txt

# You can also look at coverage on a tile by tile basis:
# less ${bamFile}_metrics.coveragePerTarget.txt
# Let us look at tiles with a mean coverage below 2 (mean coverage is stored in column 7 of this file)
# We use awk to do the filtering $7 means column 7
cat ${bamFile}_metrics.coveragePerTarget.txt | awk 'BEGIN{OFS="\t"; FS="\t";};($7<2){print};END{}' | column -t -s $'\t'
# We can look at these tiles in IGV and see that we are dealing with reads with low mapping scores.


# To get right down to coverage at single base level in the agilent bait set, you need to use a another tool (in the bedtools suite)
bedtools coverage -d -abam ${bamFile} \
-b ${dataDir}/human_g1k_v37_chr5/agilentV1/agilent37M.chr5.b37.bed \
> ${bamFile}_metrics.coveragePerBase.tab
# In this output file, the 8th col of the output is the coverage of the base
head ${bamFile}_metrics.coveragePerBase.tab
# We extract all the bases with zero coverage and look at the first ones
# Again we use awk and the notation $8 to indicate the 8th column
cat ${bamFile}_metrics.coveragePerBase.tab | \
awk 'BEGIN{OFS="\t"; FS="\t";};($8==0){print};END{}' | head
# Take a look at some of these in IGV by pasting the coordinates
# Let us navigate to some of these regions e.g. 5:70,297,003-70,298,706, and see how coverage can be insufficient






## VCF FILE REPORTS #########################################################

## First we break the indels file into insertions and deletions and do some house keeping

# Deletions
java -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T SelectVariants \
-R $refFile \
--variant indels.raw.vcf \
--out deletions.raw.vcf \
--select_expressions 'vc.isSimpleDeletion()'

# Insertions
java -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T SelectVariants \
-R $refFile \
--variant indels.raw.vcf \
--out insertions.raw.vcf \
--select_expressions 'vc.isSimpleInsertion()'


# Let us count the number of each type of mutation we have called
# grep -v "^#" is used to remove the header (-v means not matching)
cat deletions.raw.vcf  | grep -v "^#" | wc -l
cat insertions.raw.vcf  | grep -v "^#" | wc -l
cat snps.raw.vcf  | grep -v "^#" | wc -l

## The simulated mutations #################
# grep -v "^#" is used to remove the header
cat ${dataDir}/reads_agilentV1_chr5/simul_indels/deletions.vcf  | grep -v "^#" | wc -l
cat ${dataDir}/reads_agilentV1_chr5/simul_indels/insertions.vcf  | grep -v "^#" | wc -l
cat ${dataDir}/reads_agilentV1_chr5/simul_indels/snps.vcf  | grep -v "^#" | wc -l


#################################################################################
# Comparing the variant calls to what was defined as the truth in the simulation
#################################################################################

# Use bcbio.variation to:
# 1. get statistics on both snps and indels
# 2. generate the concordant and discordant VCF files

# Copy in a configuration file for the next tool (we need to copy it to pwd bcse contains relative file paths)
# This file defines which files to compare and how the comparison should be performed
cp ${localVcDir}/exerDefinitions/compTruth_snps.yaml .
cat compTruth_snps.yaml

# bcbio.variation performs the normalisation for the user AND performs the comparison and summary statistics
java -Xmx2G -jar ${swDir}/bcbio.variation/bcbio.variation-0.1.7-standalone.jar variant-compare compTruth_snps.yaml

# Get a summary of number of concordant and discordant SNP calls
cat compTruth_snps/compTruth_snps-summary.txt
# >>> concordant: SNPs          | 590 are the sites that are variant in both the calls and the truth 
# The individual variant records can be found in snpCompTruth/mutatedRef-truth-snpcalls-concordance.vcf

# >>> calls-discordant: SNPs    | 205 are sites that are variant in the calls but not in the truth (false positives)
# The individual variant records can be found in snpCompTruth/mutatedRef-snpcalls-truth-discordance.vcf

# >>> truth-discordant: SNPs    | 10  are sites that are variant in the truth but not in the calls (false negatives)
# The individual variant records can be found in snpCompTruth/mutatedRef-truth-snpcalls-discordance.vcf



# We do the same for indels
cp ${localVcDir}/exerDefinitions/compTruth_indels.yaml .
cat compTruth_indels.yaml
java -Xmx2G -jar ${swDir}/bcbio.variation/bcbio.variation-0.1.7-standalone.jar variant-compare compTruth_indels.yaml

# Get a summary of number of concordant and discordant calls
cat compTruth_indels/compTruth_indels-summary.txt
# Remember that there are 1800 insertions and 1800 deletions
# Only 731 concordant indels
# One FP: calls discordant: 1
# 2869 FN: present in truth but not in calls.


## We wish take a look at the effect of length on the detection of insertions and deletions:
# Compress the file using bgzip (similar to gzip)
bgzip -c indels.raw.vcf > indels.raw.vcf.bgz
# Index the compressed file (required by bcftools)
bcftools index indels.raw.vcf.bgz
# Compute the stats with bcftools
bcftools stats indels.raw.vcf.bgz > indels.raw.vcf_stats.txt
# Look at the part that summarises numbers of indels by length
# Recall that we simulated insertions and deletions of size 1 to 60 (both 20 heterozygotes and 10 homozygotes for each size)
grep "IDD" indels.raw.vcf_stats.txt


#######################
# Visualisation in IGV
#######################

# Let us take a look at this in IGV so that we can visualise this.
# IMPORTANT: If the files are on a remote machine, you will need to copy them to your local machine to be able to load them in IGV
# Load the False Negatives into IGV from the Menu bar >> Open File compTruth_indels/mutatedRef-truth-indelcalls-discordance.vcf
# We take a look at some specific locations in IGV

### DELETIONS
# 5:32092955 >> Small heterozygous deletions at edge of tile: heterozygosity and low coverage make detection difficult. Notice mismatched bases.
# 5:49736899 >> large heterozygous deletion where reads containing deletion have it placed near the end of the reads, thus making correct gap opening difficult

### INSERTIONS
# 5:77,458,574-77,458,614 >> large HOM insertion (difficult to predict), but we get it any way, despite misalignment of reads where the inserted sequence is near the end of the read.  The failure to correctly align the inserted sequence results in mismatches to the reference.

### SNPs
# Load into IGV mutatedRef-truth-snpcalls-discordance.vcf

## 5       271832  >> correctly detected
## 5       272803  >> not detected, presumably due to low coverage and low representation of the alternative allele
## 5       304260  >> here a combination of low coverage and low mapping quality drive the inability to detect the variant.

# Check out some interesting locations for yourself and try to see if you can see why the mutations were missed
# For indels that are present in the sample but were not detected you need to use: less compTruth_indels/mutatedRef-truth-indelcalls-discordance.vcf
# For SNPs that are present in the sample but were not detected you need to use: less compTruth_snps/mutatedRef-snpcalls-truth-discordance.vcf




