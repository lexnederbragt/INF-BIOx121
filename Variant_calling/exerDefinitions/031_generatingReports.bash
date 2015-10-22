# main purpose of script is to gain an insight into how much we have improved VCF files with refinement

# SETTING UP FOR EXERCISE ######################################################

# MAKE SURE that we have locations setup
source $HOME/vc/exerDefinitions/setupEnv.bash


# MAKE sure you are in the directory with the relevant data files
mkdir -p ${exerDir}/03_advancedPipeline
cd ${exerDir}/03_advancedPipeline

##################################################################################


## First we break the indels file into insertions and deletions and do some house keeping

# We operate on the filtered files as these contain the FILTER field set

# Deletions
java -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T  SelectVariants \
-R $refFile \
--variant indelsHQ.raw.filt.vcf \
--out deletionsHQ.raw.filt.vcf \
--select_expressions 'vc.isSimpleDeletion()'

# Insertions
java -jar ${swDir}/GenomeAnalysisTK-3.2-2/GenomeAnalysisTK.jar -T  SelectVariants \
-R $refFile \
--variant indelsHQ.raw.filt.vcf \
--out insertionsHQ.raw.filt.vcf \
--select_expressions 'vc.isSimpleInsertion()'


# Let us count the number of each type of mutation
# grep -v "^#" is used to remove the header: -v means return all lines that do not match the expression
cat deletionsHQ.raw.filt.vcf  | grep -v "^#" | wc -l
cat insertionsHQ.raw.filt.vcf  | grep -v "^#" | wc -l
cat snpsHQ.raw.filt.vcf  | grep -v "^#" | wc -l

#########################################################################################
## Compare how well we have done relative to the first round
#########################################################################################

# Copy in a configuration file for the next tool (we need to copy it to pwd bcse contains relative file paths)
# This file defines which files to compare and how the comparison should be performed
cp ${localVcDir}/exerDefinitions/compTruth_snpsHQ.yaml .
cat compTruth_snpsHQ.yaml

# bcbio.variation performs the normalisation for the user AND performs the comparison and summary statistics
java -Xmx2G -jar ${swDir}/bcbio.variation/bcbio.variation-0.1.7-standalone.jar variant-compare compTruth_snpsHQ.yaml


#######
# SNPs
#######

cat compTruth_snpsHQ/compTruth_snpsHQ-summary.txt
# >>> concordant SNPs 590 >>> unchanged from before
# >>> snpcalls-discordant: 125 >> down from 205, so substantially less False Positive calls. Attributable about half to re-alignment and half to filtering.
# >>> truth-discordant: 10 >>> Still 10 False Negatives - unchanged from before

##########
# Indels
##########

cp ${localVcDir}/exerDefinitions/compTruth_indelsHQ.yaml .
java -Xmx2G -jar ${swDir}/bcbio.variation/bcbio.variation-0.1.7-standalone.jar variant-compare compTruth_indelsHQ.yaml

# Get a summary of number of concordant and discordant indel calls
cat compTruth_indelsHQ/compTruth_indelsHQ-summary.txt
# Remember that there are 1800 insertions and 1800 deletions
# Concordant: 925 - compared to 731 in simple pipeline, so almost 200 more indels detected
# indelcalls-discordant: 9 of which 9 are "Shared discordant" which means variant in both sets but positions are not exactly matching
# truth-discordant: 2675  - compared to 2869 in simple pipeline
# NOTE: the high number of missed indels is due to the very large size of the indels that we created in the simulation. As explained in the lectures indels are much much rarer than SNPs and large indels are extremely rare. So the above results illustrate the problems that large indels cause for variant calling and are not representative of the general accuracy of variant calling. 


########################################################################################################
# Let us locate some of the variants which were NOT detected with our basic pipeline ###################
########################################################################################################

# Getting a list of indels that were found not found with the simple pipeline but were found in with the advanced pipeline
# Try to see if you can figure out what this "fancy" unix command line is doing....
cat <(grep -v "#" ../02_basicPipeline/compTruth_indels/mutatedRef-truth-indelcalls-discordance.vcf) <(grep -v "#" compTruth_indelsHQ/mutatedRef-truth-indelsHQcalls-concordance.vcf)  | sort | uniq -d


# Open IGV
# Start a new session
# Remember the colour coding of genotypes in IGV: Dark blue = heterozygous, Cyan = homozygous variant, Grey = reference
# Go to View >> Preferences >> Alignments tab >> Deselect "Show soft clipped bases"

############
# Deletions
############

# Loading required files into IGV
# For the basic pipeline (earlier exercise) load the final BAM file 02_basicPipeline/aln.posiSrt.withRG.mrkdDups.bam and the 02_basicPipeline/compTruth_indels/mutatedRef-truth-indelscalls-concordance.vcf file
# For this advanced pipeline, load the BAM file 03_advancedPipeline/aln.posiSrt.clean.dedup.recal.bam and the 03_advancedPipeline/compTruth_indelsHQ/mutatedRef-truth-indelHQcalls-concordance.vcf file


# Some examples
# 5:26,906,762-26,906,802: small deletion that is fixed by re-alignment
# 5:52,365,712-52,366,137: example of a very big deletion that is successfully detected
# 5:34,023,643-34,024,836: deletion detected bcse advanced BAM has 7 reads correctly opening gap as opposed to only 4 in the basicPipeline
# 5:34,923,077-34,923,130: deletion cleaned up well (not perfectly and detected)
# 5:33,423,253-33,692,302: this is a broad regions containing many variants where you can see how the homozygous variants (light blue) are easier to detect than the heterozygous variants (dark blue): you see this bcse the mutatedRef-truth-indelHQcalls-concordance.vcf contains many more variants than the mutatedRef-truth-indelscalls-concordance.vcf


#############
# Insertions
#############

# Some examples
# 5:75,918,952-75,918,992
# 5:80,604,737-80,604,777: detection of 18 bp insertion




