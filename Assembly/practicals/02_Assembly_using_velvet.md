Assembly using velvet
=====================

## *De novo* assembly of Illumina reads using velvet

### Assembling short-reads with Velvet

We will use Velvet to assemble Illumina reads on their own. Velvet uses the *de 
Bruijn graph* approach. 


We will assemble *E. coli K12* strain MG1655 which was sequenced on an Illumina 
MiSeq. The instrument read 150 bases from each direction.

We wil first use a down-sampled set of paired end reads only: 

`/share/inf-biox121/data/assembly/MiSeq_Ecoli_MG1655_50x_R1.fastq`  
`/share/inf-biox121/data/assembly/MiSeq_Ecoli_MG1655_50x_R2.fastq`

### Building the Velvet Index File

Velvet requires an index file to be built before the assembly takes place. We 
must choose a *k-* mer value for building the index. Longer *k-* mers result in 
a more stringent assembly, at the expense of coverage. There is no definitive 
value of *k* for any given project. However, there are several absolute rules:

* *k* must be less than the read length
* it should be an odd number 

First we are going to run Velvet in single-end mode, *ignoring the pairing 
information*. Later on we will incorporate this information.

First, we need to make sure we can use velvet:

First, 'go home':

```
cd ~
```

or simply type

```
cd
```

Create a folder for the velvet assemblies:

```
mkdir assembly
cd assembly
mkdir velvet
cd velvet
```

### A first assembly

Find a value of *k* (between 21 and 113) to start with, and record your 
choice [in this google spreadsheet](https://drive.google.com/open?id=11HNLfErxdkoEAcC2Q4gIfjeAV89Q51oDFa0YI8BKXJY) . Run `velveth` to build the hash index (see below).

`velveth` options:

* `ASM_NAME`: select your own name for the folder where the results should go
* `value_of_k`: use k-mers of this size
* `-short`: short reads (as opposed to long, Sanger-like reads)
* `-separate`: read1 and read2 are in separate files
* `-fastq`: read type is fastq

Build the index as follows:

```
velveth ASM_NAME VALUE_OF_K \  
-short -separate -fastq \  
/share/inf-biox121/data/assembly/MiSeq_Ecoli_MG1655_50x_R1.fastq \  
/share/inf-biox121/data/assembly/MiSeq_Ecoli_MG1655_50x_R2.fastq  
```
**NOTES** 

* Change `ASM_NAME` to a directory name of your choosing
* Change `VALUE_OF_K` to the value you have picked
* The command is split over several lines by adding a space, and a `\` 
(backslash) to each line. This trick makes long commands more readable. If you 
want, you can write the whole command on one line instead.

After `velveth` is finished, use `ls` to look in the new folder that has the 
name you chose. You should see the following files:

```
Log
Roadmaps
Sequences
```


The '`Log`' file has a useful reminder of what commands you typed to get this 
assembly result, for reproducing results later on. '`Sequences`' contains the 
sequences we put in, and '`Roadmaps`' contains the index you just created.

Now we will run the assembly with default parameters:

```
velvetg ASM_NAME
```

Velvet will end with a text like this:

`Final graph has ... nodes and n50 of ..., max ..., total ..., using .../... reads`

The number of nodes represents the number of nodes in the graph, which (more or 
less) is the number of contigs. Velvet reports its N50 (as well as everything 
else) in 'kmer' space. The conversion to 'basespace' is as simple as adding k-1 
to the reported length.

Look again at the folder `ASM_NAME`, you should see the following extra files:

`contigs.fa`  
`Graph`  
`LastGraph`  
`PreGraph`  
`stats.txt`

The important files are:

`contigs.fa` - the assembly itself  
`Graph` - a textual representation of the contig graph  
`stats.txt` - a file containing statistics on each contig

**Questions**

* What k-mer did you use?
* What is the N50 of the assembly? (in basespace, not in k-mer space)
* What is the size of the largest contig? (in basespace, not in k-mer space)
* How many contigs are there in the `contigs.fa` file? Use `grep -c NODE contigs.fa`. Is this the same number as velvet reported?


Log your results [in this google spreadsheet](https://drive.google.com/open?id=11HNLfErxdkoEAcC2Q4gIfjeAV89Q51oDFa0YI8BKXJY)


**We will discuss the results together and determine *the optimal* k-mer for 
this dataset.**

**Advanced tip:** You can also use VelvetOptimiser to automate this process of 
selecting appropriate *k*-mer values. VelvetOptimizer is included with the Velvet installation.

FROM NOW ON: keep track of the values that velvet reports on your own!

Now run `velveth` and `velvetg` for the kmer size determined by the whole class. 
Use this kmer from now on!

### Estimating and setting `exp_cov`

Much better assemblies are produced if Velvet understands the expected coverage 
for unique regions of your genome. This allows it to try and resolve repeats. 
The data to determine this is in the `stats.txt` file. The full description of 
this file is [in the Velvet Manual](http://www.ebi.ac.uk/~zerbino/velvet/Manual.pdf).

A so-called Jupyter notebook has been provided to plot the distribution of the 
coverage of the nodes. 

To run this notebook, we first have to activate the right version of python:

```
scl enable python33 bash

```

This will cause your prompt to change. This is expected and ok.

Then, copy the notebook to the velvet directory, and run it:

```
cp /share/inf-biox121/data/assembly/node_coverage.ipynb .
ipython notebook 

```

* After a little while, you will see a link in your window, copy it into your
browser
* Click on the notebook name to open it
* Follow the instructions in the notebook

**Question:**

* What do you think is the approximate expected k-mer coverage for your assembly?

When you are done with the Jupyter notebook:

* save the notebook
* close the browser windows
* in the terminal where you started Jupyter notebook, click ctrl-c and confirm.
* type in exit, to get the normal prompt back

Now run velvet again, supplying the value for `exp_cov` (k-mer coverage) 
corresponding to your answer:


```
velvetg ASM_NAME -exp_cov PEAK_K_MER_COVERAGE
```

**Question:**

* What improvements do you see in the assembly by setting a value for `exp_cov`?

### Setting `cov_cutoff`

You can also clean up the graph by removing low-frequency nodes from the 
*de Bruijn* graph using the `cov_cutoff` parameter. Low-frequency nodes 
can result from sequencing errors, or from parts of the genome with very 
little sequencing coverage. Removing them will often result in better 
assemblies, but setting the cut-off too high will also result in losing 
useful parts of the assembly. Using the histogram from previously, estimate 
a good value for `cov_cutoff`.

```
velvetg ASM_NAME -exp_cov YOUR_VALUE -cov_cutoff YOUR_VALUE  
```

Try some different values for `cov_cutoff`, keeping `exp_cov` the same and 
record your assembly results.

### Asking velvet to determine the parameters

You can also ask Velvet to predict the values for you:

```
velvetg ASM_NAME -exp_cov auto -cov_cutoff auto
```

You will see the estimated best values reported just above `Final graph` in 
the output.


**Questions:**

* What values of *exp_cov* and *cov_cutoff* did Velvet choose?
* Check the output to the screen. Is this assembly better than your best one?

### Incorporating paired-end information

Paired end information contributes additional information to the assembly, 
allowing contigs to be scaffolded. We will first re-index your reads telling 
Velvet to use paired-end information, by using `-shortPaired` instead 
of `-short` for `velveth`. Then, re-run velvetg using the best value 
of `k` from the previous step.

**!!! IMPORTANT Pick a new name for your assembly !!!**


```
velveth ASM_NAME2 VALUE_OF_K \  
-shortPaired -fastq -separate \  
/share/inf-biox121/data/assembly/MiSeq_Ecoli_MG1655_50x_R1.fastq \  
/share/inf-biox121/data/assembly/MiSeq_Ecoli_MG1655_50x_R2.fastq

velvetg ASM_NAME2 -exp_cov auto \  
-cov_cutoff auto  
```

Velvet will towards the bottom of the output report the estimated insert size 
for the paired library.

**Questions:**

* How does doing this affect the assembly?
* What does velvet say about the insert size of the paired end library?

### Scaffold and contig metrics

The sequences in the `contigs.fa` file are actually scaffolds.  
Use the `assemblathon_stats.pl` script to generate metrics for this, and all 
following assemblies.


**The assemblathon stats script**  

The assemblathon [www.assemblathon.org](www.assemblathon.org) used a perl 
script to obtain standardized metrics for the assemblies that were submitted. 
Here we use (a slightly modified version of) this script. It takes the size 
of the genome, and one sequence fasta file as input. The script breaks the 
sequences into contigs when there are 20 or more N’s, and reports all sorts 
of metrics.


`assemblathon_stats.pl` options:

* `-size`: size (in Mbp, million basepairs) of target genome (optional)
* `seq.fasta`: fasta file of contigs or scaffolds to report on

Example, for a 3.2 Mbp genome:

```
assemblathon_stats.pl -s 3.2 scaffolds.fasta
```

OR, save the output to a file with

```
assemblathon_stats.pl -s 3.2 scaffolds.fasta > metrics.txt
```

Here, `>` (redirect) symbol used to ‘redirect’ what is written to the screen 
to a file.

**For this exercise**, use the known length for this strain, 4.6 Mbp, for the 
genome size.

Some of the metrics the script reports are:

* N50 is based on the total assembly size
* NG50 is based on the estimated/known genome size
* L50 (LG50) count: number of scaffolds/contigs at least N50 (NG50) bases

**Questions**

* How much of the estimated genome size is covered in the scaffolds
* how many gap bases ('N') are left in the scaffolds


### Looking for repeats

Have a look for contigs which are long and have a much higher coverage than 
the average for your genome. One tedious way to do this is to look into 
the `contigs.fa` file (with `less`). You will see the name of the contig 
('NODE'), it's length and the kmer coverage. However, trying to find long 
contigs with high coverage this way is not very efficient.  

A faster was is to again use the `stats.txt` file.

Relevant columns are:

1) ID --> sequence ID, same as 'NODE' number in the `contigs.fa` file  
2) lgth --> sequence 'length'
6) short1_cov --> kmer coverage (column 6)  


Knowing this, we can use the `awk` command to select lines for contigs at 
least 1kb, with k-mer coverage greater than 60:

```
awk '($2>=1000 && $6>=60)' stats.txt
```

`awk` is an amazing program for tabular data. In this case, we ask it to check 
that column 2 ($2, the length) is at least 1000 and column 6 ($6, coverage) at 
least 60. If this is the case, awk will print the entire line. See 
[http://bit.ly/QjbWr7](http://bit.ly/QjbWr7) for more information on awk.

Find the contig with the highest coverage in the `contigs.fa` file. Perform a 
BLAST search using NCBI. Look at the `Graphics` results to see what is in the
region of the results that you got.

**Question:**

* What is it?
* Is this surprising? Why, or why not?

### The effect of mate pair library reads

Long-range "mate-pair" libraries can also dramatically improve an assembly by 
scaffolding contigs. Typical sizes for Illumina are 2kb and 6kb, although any 
size is theoretically possible. You can supply a second library to Velvet. 
However, it is important that files are reverse-complemented first as Velvet 
expects a specific orientation. We have supplied a 3kb mate-pair library in 
the correct orientation.

**!!! IMPORTANT Pick a new name for your assembly !!!**

We will use `-shortPaired` for the paired end library reads as before, and 
add `-shortPaired2` for the mate pairs. Also, to make sure we all end up 
having the same assembly, the kmer size is given. Make sure you are in the
`velvet` directory before running the command.

```
velveth ASM_NAME3 81 \  
-shortPaired -separate -fastq \  
/share/inf-biox121/data/assembly/MiSeq_Ecoli_MG1655_50x_R1.fastq \  
/share/inf-biox121/data/assembly/MiSeq_Ecoli_MG1655_50x_R2.fastq \  
-shortPaired2 -separate -fastq \  
/share/inf-biox121/data/assembly/Nextera_MP_R1_50x.fastq \  
/share/inf-biox121/data/assembly/Nextera_MP_R2_50x.fastq  
```

We use auto values for velvetg because the addition of new reads will change 
the genome coverage. The assembly command then becomes:

```
velvetg ASM_NAME3 -cov_cutoff auto -exp_cov auto
```

**Questions:**

* What is the N50 of this assembly?
* How many scaffolds?
* How many bases are in gaps?
* What did velvet estimate for the insert length of the paired-end reads, and 
for the standard deviation? Use the last mention of this in the velvet output.
* And for the mate-pair library?

**TIP**
Some mate pair libraries have a significant amount of paired end reads present 
as a by-effect of the library preparation. This may generate misassemblies. 
If this is the case for your data, add the `-shortMatePaired2 yes` to let 
Velvet know it.

Make a copy of the contigs file and call it `velvet_pe+mp.fa`.  
NOTE We will use this assembly for several exercises later on

.. toctree::
   :maxdepth: 1
