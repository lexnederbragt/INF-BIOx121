## An exercise involving indexing of reference sequence and mapping sequence read data to the reference sequence


############################################################
# Create a directory where you are going to do the exercise
############################################################

# Check where you are in the file structure
# If you have just logged in, this should be your home directory, something like /home/yourUsername.
pwd

# A shortcut notation for the home directory is ~
# So you can run the following command which changes directory into your home directory
cd ~
pwd

# An even shorter version the following, where the ~ is implicit:
cd

# Creating a directory where you will do the exercise
mkdir indexingExercise
cd indexingExercise

# Check where you are now
pwd



######################################################
## Download some reference genome data
######################################################

# First to keep everything nice and tidy, let us make a directory for the genome reference sequences
mkdir refSeq
# And change directory into it
cd refSeq

# Download the sequence from chromosomes 20 and 21 of the human genome the data from a server, using the following commands.
wget ftp://hgdownload.soe.ucsc.edu/goldenPath/hg19/chromosomes/chr20.fa.gz
wget ftp://hgdownload.soe.ucsc.edu/goldenPath/hg19/chromosomes/chr21.fa.gz

# Take a look in the files, first a way that does not work
# head by default prints the first 10 lines of a file to the screen
head chr20.fa.gz

# The above did not work because this is a gunzipped file (compressed file)
# We need to decompress it before we look at it
gunzip chr20.fa.gz

# Take a look at what the previous command did by running the following command and looking carefully at the output
ls -l

# Now look at the contents of the file with the command below
# Notice that the beginning of the sequence is just Ns
# Scroll down the the space key to come to complex sequence
# Why do you think the beginning of the sequence is represented as Ns?
less chr20.fa

# Also unzip the other compressed file
gunzip chr21.fa.gz
ls -l


#################################
# Indexing the data
#################################

# First make one file containing both the sequences
cat chr20.fa chr21.fa > chr20and21.fa

# If you have never seen the cat command before then try the command below.
# You can scroll down through the man page with "space" key and exit by hitting the "q" key
man cat


# We will use BWA to do the indexing
# First lets find the specific tool within the BWA suite that we need to use
bwa

# You will see that there are many tools within the BWA suite, but the one we need should be obvious
# We try:
bwa index

# The output tells us how to use this "index" tool: "Usage:   bwa index [options] <in.fasta>"
# There are four options but the default settings for each (which are in the brackets []) are fine, so we do not need to set any options here.
bwa index chr20and21.fa

# What files did the above command create?
ls -l

# What are the two biggest files?
# Take a look at the extensions of these files (the extension of a file is the portion after the last "." and consists typically of 3 letters)
# What do you think these files contain?


###################################################
# Mapping some sequencing reads using this index
###################################################

# Move up a level in the file structure, so that we are no longer in the directory containing the reference sequence and its index.
cd ..

# The data download tasks described in the following lines have already been done for you
# Locate a sample in the 1000 genomes project with fastq data to map to our reference genome
# These are files from a whole genome sequencing of a human samples (you can find more details at http://www.internationalgenome.org/data-portal/sample/HG00513)
# wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR016/ERR016118/ERR016118_1.fastq.gz
# wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR016/ERR016118/ERR016118_1.fastq.gz


# Take a look at the content of these fastq files (which should be familiar by now)
# The first sequences have very poor quality, but if you scroll down you should see some "normal" sequence a bit further down.
# If you want to know why I used "gunzip -c", try "man gunzip" and check out the "-c" option
gunzip -c /share/inf-biox121/data/vc/indexingAndMapping/ERR016118_1.fastq.gz | less

# These are large files (containing lots of sequences) which would take a long time to map
# So we make a subset of the files (the first 100,000 fastq records i.e. 400,000 lines)
gunzip -c /share/inf-biox121/data/vc/indexingAndMapping/ERR016118_1.fastq.gz | head -n 400000 > ERR016118_1_subset.fastq
gunzip -c /share/inf-biox121/data/vc/indexingAndMapping/ERR016118_2.fastq.gz | head -n 400000 > ERR016118_2_subset.fastq

# What is the name of the BWA tool that enables us to do the mapping?
# Let's get a list of the tools
bwa

# We choose to use the fast "mem" mapping algorithm, run the following to get the structure of the command
bwa mem

# We build up the mapping command using the information obtained from the previous command
# Usage: bwa mem [options] <idxbase> <in1.fq> [in2.fq]
# We do not need to set any of the many options for a basic mapping as the default settings are sufficient
# INPUT: Notice the path we need to use to point to the reference sequence: refSeq/chr20and21.fa
# OUTPUT: Notice that we have to redirect the output to a file. If we do not do this, the output is sent to the terminal (which we don't want). We give this file a .sam extension as the command outputs the SAM format (Sequence Alignment and Mapping)
bwa mem refSeq/chr20and21.fa ERR016118_1_subset.fastq ERR016118_2_subset.fastq > ERR016118.sam

# Again let's check the output
# The chromosome that the sequence maps to is recorded in the third column and will contain 0 if the sequence does not map to the reference.
# You will need to scroll through the file to find sequences that map to the reference.
# Notice that most of the sequences do not map to the reference. Do you know why that is?
less ERR016118.sam

