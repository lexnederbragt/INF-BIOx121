# main purpose of this exercise script:
# - primarily to introduce functional annotation of variants
# - also to provide you with a script that will do the entire analysis from fastq to functionally annotated VCF file

# SETTING UP FOR EXERCISE ######################################################

# MAKE SURE that we have locations setup
source $HOME/vc/exerDefinitions/setupEnv.bash

# MAKE SURE you are located in a sensible place
mkdir -p ${exerDir}/04_functionalAnnot
cd ${exerDir}/04_functionalAnnot

# Creating some variables to save having to write long file paths
read1FqFile=${dataDir}/reads_agilentV1_chr5/real_patient/real_agilentV1_chr5.R1.fastq
read2FqFile=${dataDir}/reads_agilentV1_chr5/real_patient/real_agilentV1_chr5.R2.fastq
refFile=${dataDir}/human_g1k_v37_chr5/gatkBundle/human_g1k_v37_chr5.fasta
knownVariants=${dataDir}/human_g1k_v37_chr5/gatkBundle/dbsnp_132.b37_chr5.vcf
tiles=${dataDir}/human_g1k_v37_chr5/agilentV1/agilent37M.chr5.b37.interval_list


# MAP THE READS TO THE REFERENCE ##############################################

# Mapping reads without considering pair information
bwa aln -t 3 $refFile $read1FqFile > aln_sa1.sai
bwa aln -t 3 $refFile $read2FqFile > aln_sa2.sai

# Finish mapping using pair information
bwa sampe $refFile aln_sa1.sai aln_sa2.sai $read1FqFile $read2FqFile > aln.sam

# TIDY UP THE SAM FILE 	#########################################################

# Make sure the mates have updated information about each other (not relying on aligner to do this properly)
java -jar ${swDir}/picard-tools-1.67/FixMateInformation.jar SORT_ORDER=coordinate INPUT=aln.sam OUTPUT=aln.posiSrt.bam CREATE_INDEX=true

# Add metadata about sample to bam file
java -jar ${swDir}/picard-tools-1.67/AddOrReplaceReadGroups.jar \
CREATE_INDEX=true \
INPUT=aln.posiSrt.bam \
OUTPUT=aln.posiSrt.withRG.bam \
RGLB="realComposite" \
RGPL="Illumina" \
RGPU="someRun_noBarcode" \
RGSM="realComposite" \
RGCN="NSC" \
RGDS="Some_description_of_the_read_group"

# Mark duplicates to add information about duplicates to the file
java -jar ${swDir}/picard-tools-1.67/MarkDuplicates.jar \
INPUT=aln.posiSrt.withRG.bam \
OUTPUT=aln.posiSrt.withRG.mrkdDups.bam \
METRICS_FILE=aln.posiSrt.withRG.mrkdDups.bam_metrics.duplication.txt \
CREATE_INDEX=true \
REMOVE_DUPLICATES=false \
COMMENT="MarkDuplicates.jar_run_on_raw_BWA_alignments"


## Perform the realignment around indels #############################################

# Identify regions affected by indels and requiring re-alignment
# BE PATIENT: this may take a while
java -Xmx2G -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T RealignerTargetCreator \
-R $refFile \
-o realignment.intervals \
-I aln.posiSrt.withRG.mrkdDups.bam \
--known $knownVariants

# Performing the actual re-alignment
java -Xmx2G -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T IndelRealigner \
-I aln.posiSrt.withRG.mrkdDups.bam \
-R $refFile \
-targetIntervals realignment.intervals \
-o aln.posiSrt.withRG.mrkdDups.clean.bam \
-compress 0

## Base quality score recalibration ##################################################

## count covariates before recalibration
## i.e. generate the statistics on which to base the recalibration
# ReadGroupCovariate and QualityScoreCovariate are mandatory (and actually do not need to be specified)
java -Xmx2G -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T BaseRecalibrator \
-l INFO \
-R ${refFile} \
-I aln.posiSrt.withRG.mrkdDups.clean.bam \
-knownSites $knownVariants \
--out aln.posiSrt.withRG.mrkdDups.clean.bam_recal.txt \
-cov ReadGroupCovariate \
-cov QualityScoreCovariate \
-cov ContextCovariate \
-cov CycleCovariate

# Second PrintReads to apply the recalibration
java -Xmx2G -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T PrintReads \
-l INFO \
-R ${refFile} \
-I aln.posiSrt.withRG.mrkdDups.clean.bam \
-BQSR aln.posiSrt.withRG.mrkdDups.clean.bam_recal.txt \
--out aln.posiSrt.withRG.mrkdDups.clean.recal.bam 


## METRICS #######################################################################

# This is a good point at which to run all the metrics on BAM files we looked at in a different exercise
# We will not do this here, but you should have the code to do this.


## Variant calling ###############################################################


# Call variants ###########################


# Compute the variants ##############
# -L limits variant calling to the regions we captured
# -glm BOTH tell the program to call both SNPs and indels
java -Xmx2G -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T UnifiedGenotyper \
--validation_strictness STRICT \
-R $refFile \
-I aln.posiSrt.withRG.mrkdDups.clean.recal.bam \
-L ${tiles} \
-glm BOTH \
--dbsnp $knownVariants \
-o snpsAndIndelsHQ.raw.vcf



# Create files containing only the SNPs and only the indels
java -Xmx2G -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T SelectVariants \
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
# Take a look at the FILTER column in the output with : less snpsHQ.raw.filt.vcf


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



## FUNCTIONAL ANNOTATION #################################################

vcfInput="snpsHQ.raw.filt.vcf" # vcf file to be annotated by snpEff


# In particular, snpEffDb should not be changed as other versions are know to give erroneous results (see background)
snpEffDb=GRCh37.64 # define the version of the Ensembl database to be used by snpEff, location of file is specified in snpEff's config file
dbNSFP=${dataDir}/dbNSFP/dbNSFP2.0b3_chr5.txt # download from snpSift website

# Define output files
vcfAllImpacts=${vcfInput%.*}.$snpEffDb.vcf # output by snpEff
vcfTopImpact=${vcfAllImpacts%.*}.topImpact.vcf # output by gatk
vcfNSFP=${vcfTopImpact%.*}.NSFP.vcf # output by snpSift


# Annotate all effects given ensembl db using snpEff
java -jar ${swDir}/snpEff_2_0_5/snpEff.jar eff -c ${swDir}/snpEff_2_0_5/snpEff.config -o vcf -onlyCoding true -v -i vcf -o vcf $snpEffDb $vcfInput > $vcfAllImpacts
# Take a look at what this command has added to the INFO field: less $vcfAllImpacts


# Here we pick out the top impact annotation for each variant
java -Xmx2G -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T VariantAnnotator \
-R $refFile \
-A SnpEff \
--variant $vcfInput \
--snpEffFile $vcfAllImpacts \
-L $vcfInput \
-o $vcfTopImpact
# to see the name of the output file, type:
echo $vcfTopImpact

# Add detailed information for non-synomymous snps from the dbNSFP db using snpSift
# We use only some of the fields available from dbNSFP
java -jar ${swDir}/SnpSift.jar dbnsfp -f 1000Gp1_AF,SIFT_score,Polyphen2_HVAR_pred,29way_logOdds $dbNSFP $vcfTopImpact > $vcfNSFP
# To see the name of the output file, type:
echo $vcfNSFP

## Add allele frequency data from Exac (Exac is db of variant frequences that is even more complete than 1000 genomes)
java -Xmx2G -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T VariantAnnotator \
-R $refFile \
--variant $vcfNSFP \
--resource:exac ${dataDir}/exac/ExAC.r0.3.sites.vep.chr5.vcf.gz \
--expression exac.AF \
-o ${vcfNSFP%.*}.exac.vcf


# Transform into a table for easier filtering
# We specify with the -F option all the fields present in the input file which we want to be transferred to the output file.
java -Xmx2G -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T VariantsToTable \
-R $refFile \
-V ${vcfNSFP%.*}.exac.vcf \
-o ${vcfNSFP%.*}.exac.vcf_asTable \
--allowMissingData \
--showFiltered \
-F CHROM \
-F POS \
-F ID \
-F REF \
-F ALT \
-F QUAL \
-F FILTER \
-GF GT \
-GF GQ \
-F HET \
-F HOM-REF \
-F HOM-VAR \
-F TYPE \
-F VAR \
-F SNPEFF_EFFECT \
-F SNPEFF_IMPACT \
-F SNPEFF_FUNCTIONAL_CLASS \
-F SNPEFF_CODON_CHANGE \
-F SNPEFF_AMINO_ACID_CHANGE \
-F SNPEFF_GENE_NAME \
-F SNPEFF_GENE_BIOTYPE \
-F SNPEFF_TRANSCRIPT_ID \
-F SNPEFF_EXON_ID \
-F dbnsfpSIFT_score \
-F dbnsfpPolyphen2_HVAR_pred \
-F dbnsfp29way_logOdds \
-F dbnsfp1000Gp1_AF \
-F exac.AF



# Table is a good format to work with in Excel when there are a limited number of variants as there is here where we are limited to chromosome 5
# BUT with real data (50,000 variants), Excel would either crash or be very sloooow, so below we will continue to use the VCF file.



## PAUSE POINT

# !!! IMPORTANT !!!! This a highly realistic dataset for which you now have a functionally annotated VCF file
# In the following you will get some more information about the sample and a task:

# This is data from a young patient with a severe but poorly defined pathology (which is suspected of having a genetic cause). The patient's DNA has been sequenced using exome capture. There is no such disease in the patients immediate family so we suspect the variant to be recessive (ie homozygous in the patient). We have mapped the reads and called variants on the sample data. This has generated thousands of variant calls, we wish to attempt to identify the variant causing the pathology. To do so we need to exploit the functional annotation.

# THE ACTUAL TASK: Please find your top candidate variant and then search the web to find out a bit about this gene.

# If you continue beyond this point you will be gradually guided towards the answer
# It is probably wise to let yourself be guided, but you do not have to (or at least not all the way to the end).


# Transform from VCF to BCF (bcftools works best on bcf files)
bcftools view -O b ${vcfNSFP%.*}.exac.vcf > ${vcfNSFP%.*}.exac.bcf
# If you are wondering what ${vcfNSFP%.*} is type, the following and you will see
${vcfNSFP}
echo ${vcfNSFP%.*}
# So you see, it just removes the part of the value after the last "." i.e. a way of removing the file extension

# We need to index the bcf file for fast retrieval of variant records
bcftools index ${vcfNSFP%.*}.exac.bcf

# We limite ourselves to sites with 2 alleles
# And we know that we are looking for a variant that probably has a high or medium impact
# grep -v "#" is used below to remove the header from the vcf file before we count the lines
# You can try replacing grep -v "#" | wc -l WITH less if you want to scroll through output.
bcftools view --max-alleles 2  ${vcfNSFP%.*}.exac.bcf | \
bcftools view --include 'SNPEFF_IMPACT=="HIGH" || SNPEFF_IMPACT=="MODERATE"' | grep -v "#" | wc -l
# Hmmmm... that was a bit too long a list

# We only want high quality variants so we add a condition on the FILTER column by adding "-f .,PASS"
bcftools view --max-alleles 2 -f .,PASS  ${vcfNSFP%.*}.exac.bcf | \
bcftools view --include 'SNPEFF_IMPACT=="HIGH" || SNPEFF_IMPACT=="MODERATE"' | grep -v "#" | wc -l
# Well that did not make much of a difference

# It should be a rare variant (i.e. it cannot be known to have a high frequency), so let us add that to the filtering
# Notice that not all variants have frequency data, so rather than include all variants with a low frequency (which would mean that we would not keep variants without frequency data), we exclude any variant with a frequency higher than 1%
bcftools view --max-alleles 2 -f .,PASS  ${vcfNSFP%.*}.exac.bcf | \
bcftools view --include 'SNPEFF_IMPACT=="HIGH" || SNPEFF_IMPACT=="MODERATE"' | \
bcftools view --exclude 'dbNSFP_1000Gp1_AF > 0.01' | grep -v "#" | wc -l
# Now that is a more sensible number
# Re-run the above without grep and wc to see the variants
# Ouch!!!! that was a bit messy


# Let us setup a function (which uses the query command of bcftools) so that we can format the output
# We choose the fields of the VCF file that we want displayed (separated by tabs)
function formatOutput(){
bcftools query -f '%CHROM\t%POS\t%ID\t%REF\t%ALT\t%QUAL\t%FILTER\t%INFO/QD\t%INFO/SNPEFF_GENE_NAME\t%SNPEFF_IMPACT\t%SNPEFF_EFFECT\t%dbNSFP_SIFT_score\t%dbNSFP_Polyphen2_HVAR_pred\t%dbNSFP_1000Gp1_AF\t[\t%GT]\n' | column -t
}

# Now we apply this function at the end of our pipeline
# This should give us much more readable output
bcftools view --max-alleles 2 -f .,PASS  ${vcfNSFP%.*}.exac.bcf | \
bcftools view --include 'SNPEFF_IMPACT=="HIGH" || SNPEFF_IMPACT=="MODERATE"' | \
bcftools view --exclude 'dbNSFP_1000Gp1_AF > 0.01' | formatOutput
# Much tidier!!!!
# Looking at the genotypes can you see the causal variant?
# Can you see that we could have gotten to the answer quicker?


# If you were a bit perplexed by the filtering operations we performed here, you can download the file snpsHQ.raw.filt.GRCh37.64.topImpact.NSFP.exac.vcf_asTable and import it into a spreadsheet program as described in 041_findCausalVariantExercise.txt and perform the filtering using the filtering functionality of the spreadsheet.



















