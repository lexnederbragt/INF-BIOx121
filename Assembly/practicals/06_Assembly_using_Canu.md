Assembly using CANU
===================

[Canu](http://canu.readthedocs.io/en/stable/) is "a fork of the Celera 
Assembler designed for high-noise single-molecule sequencing (such as the 
PacBio RSII or Oxford Nanopore MinION)". Celera Assembler was developed 
during the time of Sanger sequencing by the company Celera Genomics. Celera 
Assembler was used to assemble the *Drosophila* genome, as well as the human 
genome.


Canu:

* starts with the raw reads
* maps all of them to the longest set of reads
* corrects the longest set of reads using the information of the mapped reads
* runs the corrected reads through an Overlap-Layout-Consensus (OLC) assembler

Given 60-100x coverage in raw PacBio or MinION reads, Canu very often yields 
complete, gapless assemblies, i.e., one contig per chromosomal element. 

From the manual:

>While Canu corrects sequences and has 99% identity or greater with PacBio or 
>Nanopore sequences, for the best accuracy we recommend polishing with a 
>sequence-specific tool. We recommend Quiver for PacBio and Nanopolish for 
>Oxford Nanpore data.
>If you have Illumina sequences available, Pilon can also be used to polish 
>either PacBio or Oxford Nanopore assemblies.



## Assembling MinION data with `canu`

Run `canu` as:

```
canu -p canu_MAP006-1_2D -d canu_MAP006-1_2D \
genomeSize=4.6m \
-maxThreads=3 \
-maxMemory=30 \
-nanopore-raw /share/inf-biox121/data/assembly/MAP006-1_2D_pass.fastq
```
* `-p` and `-d` tell `can` what to call the output folder and files
* `-nanopore-raw` speaks for itself
* the assembly file will be called `canu_MAP006-1_2D.contigs.fasta`

TODO
### REAPR on the results

If you want to run `reapr` on the canu output, there is one catch. We'll check 
whether reapr can actually work with the `canu` assembly file:

```
reapr facheck ASSEMBLY.FASTA
```

From the help text:
>Checks that the names in the fasta file are ok.  Things like
trailing whitespace or characters |':- could break the pipeline.

If this command warns about one or more names of sequences breaking the 
pipeline, you can have the program fix it for you:

```
reapr facheck ASSEMBLY.FASTA fixed_ASSEMBLY
```

This will create a new file `fixed_ASSEMBLY.fasta` with fixed sequence names, 
and a file called `fixed_ASSEMBLY.info` listing the old and new names. Now 
your assembly is ready for `reapr`.

**NB:** Make sure you do this before you start mapping with `bwa`!

## Assembling PacBio data with `canu`

Use *all* available reads from the P6C4 run, i.e. 155 x coverage:

```
/share/inf-biox121/data/assembly/m141013_011508_sherri_c100709962550000001823135904221533_s1_p0.filtered_subreads.fastq
```
Ran as for the MinIOn data, but use the `-pacbio-raw` for the PacBio reads.

### Correcting the `canu` PacBio assembly using `Quiver`

Quiver is a program that takes a set of aligned PacBio reads and recalls the 
bases based on the consensus of the alignment.

First, we need to map the raw (!) PacBio reds to the assembly. For this, we 
use the raw output from the instrument, which is in so-called `bax.h5` files 
(these are in the HDF5 binary format). We make a `fofn` (a 'file-of-filenames') 
which lists all input files:


```
find /share/inf-biox121/data/assembly/ -name "*.h5" >input.fofn
```

We also need to set up the environment to be able to run the correct programs 
(`pbalign` and `quiver`), simply type:

```
smrtshell
```

There will some warnings but please ignore these.

Please note, in the command below, use the assembly file you got from the `canu`
run as the ASSEMBLY.FASTA file.

Now we do the mapping using `pbalign`:
```
pbalign \
--tmpDir ./ \
--nproc 3 \
input.fofn \
ASSEMBLY.FASTA canu_quiver.cmp.h5 \
--forQuiver
```
This last command is likely to run a couple of hours.

For the next step, we need to index the assembly with `samtools faidx`:

```        
samtools faidx ASSEMBLY.FASTA
```

Now we can run `quiver`:

```
quiver -j 2 canu_quiver.cmp.h5 \
-r assembly.fasta \
-o canu_quiver.variants.gff \
-o canu_quiver.consensus.fasta
```

Our 'new' assembly is in the `consensus.fasta` file, while the `variants.gff` 
file is a list of changes quiver made to the original assembly (in `gff` format).