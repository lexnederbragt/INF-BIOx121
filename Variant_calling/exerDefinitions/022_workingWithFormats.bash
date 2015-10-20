# purpose of script is to practice manipulating formats


# SETTING UP FOR EXERCISE ######################################################

# MAKE SURE that we have locations setup
source $HOME/vc/exerDefinitions/setupEnv.bash

# MAKE sure you are in the directory with the relevant data files
mkdir -p ${exerDir}/02_basicPipeline
cd ${exerDir}/02_basicPipeline

# MAKE sure you are in the directory with the relevant data files
mkdir manip
cd manip

# Make a copy of the BAM file we produced in earlier exercise
cp ../aln.posiSrt.withRG.mrkdDups.bam .
# Make a copy of the VCF file
cp ../snps.raw.vcf .

#################################################################################


#################################################################################
# SAM files
#################################################################################


### Viewing the contents of a SAM file
samtools view -h aln.posiSrt.withRG.mrkdDups.bam | less
# Second col not making sense?
samtools view aln.posiSrt.withRG.mrkdDups.bam | head
# Second col still not making sense?
samtools flags
samtools flags 99
samtools flags 163
# All non-ambiguous mappings (mapping quality has to be at least 1)
samtools view -h -q 1 aln.posiSrt.withRG.mrkdDups.bam | less
# Count them
samtools view -h -q 1 aln.posiSrt.withRG.mrkdDups.bam | wc -l
# Count the mapped reads using the -F flag
samtools view -F 0x4 aln.posiSrt.withRG.mrkdDups.bam  | wc -l
# Count the unmapped reads using the -f flag
samtools view -f 0x4 aln.posiSrt.withRG.mrkdDups.bam  | wc -l

### Manipulating a SAM file 
# Can also do other manipulations in samtools, like fixing mates (similar operations to what you can do with Picard)
# First convert SAM to BAM and pipe it to sort by name
samtools view -bS -t ${dataDir}/gatkBundle/human_g1k_v37_chr5.fasta.fai ../aln.sam | samtools sort -n -O bam -T temp > aln.nameSrt.bam
# Second fix the mate information and sort by position
samtools fixmate -O bam aln.nameSrt.bam - | samtools sort -O bam -T temp > aln.posiSrt.bam # fixmate information and order by coords
samtools index aln.posiSrt.bam # index the BAM file


###########################################
# VCF files
###########################################

# Compress
bgzip -c snps.raw.vcf > snps.raw.vcf.bgz
# And index
bcftools index snps.raw.vcf.bgz

# Select variants from a particular regions
# Do not output the header
bcftools view -H -r 5:9190392-9379883 snps.raw.vcf.bgz
# Only homozygous within this region
bcftools view -H -r 5:9190392-9379883 --genotype hom snps.raw.vcf.bgz
# Additional requirement that quality above 500
bcftools view -H -r 5:9190392-9379883 --genotype hom --include 'QUAL > 500'  snps.raw.vcf.bgz
# Use "query" to select specific parts (ie format) the VCF records
# Note that we need to remove the "-H" option (so that header is output) as header is needed by the query command.
bcftools view -r 5:9190392-9379883 --genotype hom --include 'QUAL > 500'  snps.raw.vcf.bgz | bcftools query -f '%CHROM\t%POS\t%REF\t%ALT[\t%SAMPLE=%GT]\n' -
# You should be able to perform most of the operations you may need to do on a VCF/BCF file in bcftools
# You will find similar manipulation tools in GATK: SelectVariants, CombineVariants, etc.



