Mapping reads to an assembly and visualising the results
======================================
Mapping is the process of aligning short reads to a reference genome, with the
goal of figuring where they could come from. We will use `bwa` for mapping. 

### Indexing the assembly

Our goal here is to compare the reads we have to the assembly we got.  We can 
use this to see how good our assembly is. Your new assembly becomes the 
'reference' for `bwa`. `bwa` needs an index of the sequences to make mapping 
go faster. For large genomes such as the human genome, this takes a long 
time. For the small bacterial genome we work with here this is very fast.

Move (using `cd`) to the folder with your final assembled sequences, i.e. 
the `velvet_pe+mp.fa` file when you first do this.  

Index the fasta file with:

```
bwa index -a bwtsw ASSEMBLY.FASTA
```

Replace `ASSEMBLY.FASTA` with the name of your fasta file. Run `ls` to check 
the results, you should see a couple of new files.


### Mapping paired end reads

Mapping the reads using `bwa mem` yields SAM output. Instead of saving this 
output to disk, we will immediately convert it to a sorted (binary) BAM 
file by piping into the `samtools`program. 'Sorted' here means that the 
alignments of the mapped reads are in the order of the reference sequences, 
rather than random. Finally, we will generate an index of the sorted BAM 
file for faster searching later on.

First, create a new folder *in the same folder as the `ASSEMBLY.FASTA` file*  
and `cd` into it:

```
mkdir bwa
cd bwa
```
Then do the mapping:

```
bwa mem -t 3 ../ASSEMBLY.FASTA \
/share/inf-biox121/data/assembly/MiSeq_Ecoli_MG1655_50x_R1.fastq \
/share/inf-biox121/data/assembly/MiSeq_Ecoli_MG1655_50x_R2.fastq \
| samtools view -buS - | samtools sort - -o map_pe.sorted.bam
```

Note, we are doing the 50x data set so that it will be easier to look at the
results.

Explanation of some of the parameters:

* `../` means 'look in the folder one level up', i.e. where the fasta file and 
its index files are
* `-t 3`tells `bwa mem` to use 3 threads (cpus)
* `-buS`tells `samtools view` that the input is in SAM format (`S`) and to 
output uncompressed (`u`) BAM format (`b`).
* the `-` for both `samtools` commands indicate that instead of using a file 
as input, the input comes from a pipe (technically, from 'standard in', or 
'STDIN').
* ` -o map_pe.sorted.bam` tells `samtools view` the name of the outputfile

Generate an index of the BAM file:

```
samtools index map_pe.sorted.bam
```

If you would like to have a look at the alignments in the BAM file (which is in 
binary format), use `samtools view`again:

```
samtools view map_pe.sorted.bam |less
```

### Mapping mate pairs
Repeat the `bwa mem` and `samtools` commands above, but:

* use the mate pair reads `Nextera_MP_R1_50x.fastq` and `Nextera_MP_R2_50x.fastq`
* change the output name to `map_mp.sorted.bam`

### Plotting the insert size distribution
Since we know know where the pairs of reads map, we can obtain the distance 
between them. That information is stored in the SAM/BAM output in the 9th 
column, 'TLEN' (observed Template LENgth).

We will use python, and the python module `pysam` to plot the distribution of 
insert sizes for a subset of the alignments. This we will do in another Jupyter 
notebook.

* copy the notebook file `/share/inf-biox121/data/assembly/Plot_insertsizes.ipynb` 
to the `bwa` folder
* in the terminal, make sure you are in that folder
* start python3
* open the Jupyter notebook 
* execute the cells as listed
* for `infile`, use the name of the sorted BAM file for the mapping of the 
paired end or mate pair reads
* generate plots for both the paired end mapping *and* the mate pair mapping

**Questions**

* Which insert size distribution is the tightest around the mean?
* Why isn't the mean of the distribution a useful metric for the mate pair 
library?

Advanced: read in the mate pair assembly instead. Try changing values so that 
you allow inserts to be up to 6000 bp long. What is the insert size for the 
mate pair data set?

### Visualising the assembly in a genome browser
For this part, we will use Integrative Genomics Viewer (IGV), a genome browser 
developed by the Broad Institute.  Instead of using one of the built-in genomes, 
we will add the assembly as a new reference genome.

<!---
TODO: understand IGV colors
-->

* start the IGV program by typing `igv.sh`
* Choose `Genomes --> Load Genome from File…` (**NB** not File --> Load from 
File...)
* Select the `fasta` file with your assembly (**NB** the same file as you used 
for mapping the reads against!)

**Adding the mapped reads**  
Adding tracks to the browser is as simple as uploading a new file:

* Choose `File --> Load from File…`
* Choose the sorted `bam` file of the paired end mapping 
* Repeat this for the `bam` file of the mate pair mapping 
* You can choose different sequences (contigs/scaffolds) from the drop-down 
menu at the top. Start by selecting (one of) the longest scaffold(s)
* Start browsing!
* Zoom in to see the alignments

You can find more information about interpreting what you see 
[on this website](http://software.broadinstitute.org/software/igv/PopupMenus#AlignmentTrack).


**Question:**

* Do you see differences between some of the reads relative to the reference? 
What are these?
* Is coverage even? Are there gaps in the coverage, or peaks? Where?


### Adding the locations of gaps as another track
It would be convenient to be able to see the location of gaps in the browser. 
For this purpose use a script made by your teacher that creates a `bed` file 
with gap locations. We will use 10 bases as minimum gap length: `-m 10`. You 
need to have python3 enabled.

You need to be in the directory where your assembly is.


```
scaffoldgap2bed.py -i ASSEMBLY.FASTA >gaps.bed
```

* Inspect the BED file
* Add the BED file to the browser
* Drag the track to the top
* Zoom in one gaps and look at the alignments

**Question:**

* Check for some gaps whether they are spanned by mate pairs? Tip: choose 
'view as pairs' for the tracks (right click on panel on the left)

### Saving the IGV session
We will get back to this assembly browser, so save your session: `File --> Save Session…`

  