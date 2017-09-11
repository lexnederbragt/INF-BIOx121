Assembly using SPADES
=====================

Spades was written as an assembly program for bacterial genomes, both for 
data from single cells, as well as from whole-genome amplified samples. It 
performed very well in the GAGE-B competition, see 
[http://ccb.jhu.edu/gage_b/](http://ccb.jhu.edu/gage_b/). 
SPAdes also works well, sometimes even best, when given high-coverage datasets.

Before assembly, SPADES will error-correct the reads.

## Using SPADES

Spades can be used with paired end and mate pair data:

* The `--careful` flag is used to reduce the number of mismatches and short indels. 
* For each read file, a flag is used to indicate whether it is from a paired 
end (`--pe`) or mate (`--mp`) pair dataset, followed by a number for the dataset, 
and a number for read1 or read2. For example: `--pe1-1` and `--pe1-2` indicate 
paired end data set 1, read1 and read2, respectively.
* Similarly, use `--mp1-1` and `--mp1-2` for the mate pair files. 
* Spades assumes mate pairs are in the orientation as they are in the original 
files coming from the Illumina instrument: <-- and --> ('outie' orientation, or 
'rf' for reverse-forward). Our reads are in the --> and <-- ('innie', 'fr' for 
forward-reverse) orientation, so we add the `--mp1-fr` flag to let SPADES know 
about this.
  
Other parameters:

* `-t` number of threads (CPUs) to use for calculations
* `--memory` maximum memory usage in Gb
* `-k` k-mers to use (this gives room for experimenting!)
* `-o` name of the output folder


### Setting up the assembly

**NOTE** Running these assemblies will take quite a bit of time. Open a 
new terminal window and run this in that window. You can minimize the
window to ensure that you don't interrupt the proceedings.

First, create a new folder called `spades` and `cd` into it.  
We will save the output from the command using `>spades.out` in a file to be 
able to follow progress. `2>&1` makes sure any error-messages are written to 
the same file.

Run the assembly as follows:

<!---
**NOTE** the assembly will take several hours, so use the `screen` command! See [https://wiki.uio.no/projects/clsi/index.php/Tip:using_screen](https://wiki.uio.no/projects/clsi/index.php/Tip:using_screen)
-->

**NOTE** Here, we use a different paired end dataset, to give SPADES more data 
to work with.

Choose **ONE** of the three below to run:

**Option 1: paired end Illumina with Illumina mate Pairs:**

For this assembly, we'll tell SPADES what range of k-mers to use.

```
spades.py -t 3 -k 21,33,55,77 --careful --memory 30 \
--pe1-1 /share/inf-biox121/data/assembly/MiSeq_Ecoli_MG1655_110721_R1.fastq \
--pe1-2 /share/inf-biox121/data/assembly/MiSeq_Ecoli_MG1655_110721_R2.fastq \
--mp1-1 /share/inf-biox121/data/assembly/Nextera_MP_R1_50x.fastq \
--mp1-2 /share/inf-biox121/data/assembly/Nextera_MP_R2_50x.fastq \
--mp1-fr -o spades_pe_mp >spades_pe_mp.out 2>&1
```

**Option 2: paired end Illumina with MinION data:**

The Nanopore data consists of so-called '2D' reads sequenced with the R7 kits 
and chemistry, with average length 9 Kbp, giving around 54x coverage of 
the *E. coli* genome. We'll let SPADES found out itself what range of kmers 
to use.

```
spades.py -t 3 --careful --memory 30 \
--pe1-1 /share/inf-biox121/data/assembly/MiSeq_Ecoli_MG1655_110721_R1.fastq \
--pe1-2 /share/inf-biox121/data/assembly/MiSeq_Ecoli_MG1655_110721_R2.fastq \
--nanopore /share/inf-biox121/data/assembly/MAP006-1_2D_pass.fastq \
-o spades_mi >spades_mi.out 2>&1
```

**Option 3: paired end Illumina with PacBio data:**

The PacBio data consists of raw, uncorrected filtered subreads sequenced with the P6C4 chemistry on the RS II, with average length 9 Kbp, giving around 30x coverage of the *E. coli* genome. We'll let SPADES found out itself what range of kmers to use.

```
spades.py -t 3 --careful --memory 30 \
--pe1-1 /share/inf-biox121/data/assembly/MiSeq_Ecoli_MG1655_110721_R1.fastq \
--pe1-2 /share/inf-biox121/data/assembly/MiSeq_Ecoli_MG1655_110721_R2.fastq \
--pacbio /share/inf-biox121/data/assembly/m141013_011508_filtered_subreads_30x.fastq \
-o spades_pb >spades_pb.out 2>&1
```

**TIP**: use this command to track the output as it is added to the file. 
Use `ctrl-c` to cancel.

```
tail -f spades.out
```

### SPADES output
* error-corrected reads
* contigs for each individual k-mer assembly
* final `contigs.fasta` and `scaffolds.fasta`, use the scaffolds file (!)

You can have a look at the lengths of the largest sequence(s) with

```
fasta_length scaffolds.fasta |sort -nr |less
```

### Re-using error-corrected reads

Once you have run SPADES, you will have files with the error-corrected reads 
in `spades_folder/corrected/`. There will be one file for each input file, 
and one additional one for unpaired reads (where during correction, one of 
the pairs was removed from the dataset). Instead of running the full SPADES 
pipeline for your next assembly, you could add the error-corrected reads from 
the previous assembly. This will save time by skipping the error-correction 
step. I suggest to not include the files with unpaired reads.

Error-corrected read files are compressed, but SPADES will accept them as 
such (no need to uncompress).

Changes to the command line when using error-corrected reads:

* point to the error-corrected read files instead of the raw read files
* add the `--only-assembler` flag to skip correction

<!---

### Next steps
As for the previous assemblies, you could map reads back to the assembly, 
run reapr and visualise in the browser.

-->