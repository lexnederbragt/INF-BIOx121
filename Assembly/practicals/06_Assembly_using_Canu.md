Assembly using CANU
===================

[Canu](http://canu.readthedocs.io/en/stable/) is "a fork of the Celera Assembler designed for high-noise single-molecule sequencing (such as the PacBio RSII or Oxford Nanopore MinION)". Celera Assembler was developed during the time of Sanger sequencing by the company Celera Genomics. Celera Assembler was used to assemble the *Drosophila* genome, as well as the human genome.


Canu:

* starts with the raw reads
* maps all of them to the longest set of reads
* corrects the longest set of reads using the information of the mapped reads
* runs the corrected reads through an Overlap-Layout-Consensus (OLC) assembler

Given 60-100x coverage in raw PacBio or MinION reads, Canu very often yields complete, gapless assemblies, i.e., one contig per chromosomal element. 

From the manual:

>While Canu corrects sequences and has 99% identity or greater with PacBio or Nanopore sequences, for the best accuracy we recommend polishing with a sequence-specific tool. We recommend Quiver for PacBio and Nanopolish for Oxford Nanpore data.
>If you have Illumina sequences available, Pilon can also be used to polish either PacBio or Oxford Nanopore assemblies.



## Assembling MinION data with `canu`

Run `canu` as:

```
canu -p canu_MAP006-1_2D -d canu_MAP006-1_2D \
genomeSize=4.6m \
-maxThreads=2 \
-maxMemory=33 \
-nanopore-raw /data/MAP006-1_2D_pass.fastq \
```
* `-p` and `-d` tell `can` what to call the output folder and files
* `-nanopore-raw` speaks for itself
* the assembly file will be called `canu_MAP006-1_2D.contigs.fasta`

If you want to run `reapr` on the can output, there is one catch. We'll check whether reapr can actually work with the `canu` assembly file:

```
reapr facheck ASSEMBLY.FASTA
```

From the help text:
>Checks that the names in the fasta file are ok.  Things like
trailing whitespace or characters |':- could break the pipeline.

If this command warns about one or more names of sequences breaking the pipeline, you can have the program fix it for you:

```
reapr facheck ASSEMBLY.FASTA fixed_ASSEMBLY
```

This will create a new file `fixed_ASSEMBLY.fasta` with fixed sequence names, and a file called `fixed_ASSEMBLY.info` listing the old and new names. Now your assembly is ready for `reapr`.

**NB:** Make sure you do this before you start mapping with `bwa`!

## Assembling PacBio data with `canu`

Use *all* available reads from the P6C4 run, i.e. 155 x coverage:

```
/data/pacbio/Analysis_Results/m141013_011508_sherri_c100709962550000001823135904221533_s1_p0.filtered_subreads.fastq
```
Ran as for the MinIOn data, but use the `-pacbio-raw` for the PacBio reads.

## Correcting the `canu` PacBio assembly using `Quiver`



```
canu_P6C4_quiver && cd canu_P6C4_quiver && \
        ls /projects/cees/in_progress/lex/hts_course/H2016/assembly/data/pacbio/Analysis_Results/*.bax.h5 >input.fofn && \
        /usr/bin/time pbalign \
        --nproc 2 \
        input.fofn \
        ../canu_P6C4/assembly.fasta canu_P6C4_quiver.cmp.h5 \
        --forQuiver \
        >canu_P6C4_quiver_pbalign.out 2>&1 && \
```
```        
samtools faidx ../canu_P6C4/assembly.fasta && \
```

```
quiver \
        -j 2 \
        canu_P6C4_quiver.cmp.h5 \
        -r ../canu_P6C4/assembly.fasta \
        -o canu_P6C4_quiver.variants.gff \
        -o canu_P6C4_quiver.consensus.fasta \
        >canu_P6C4_quiver.out 2>&1 && \
        ln -s canu_P6C4_quiver.consensus.fasta assembly.fasta
```
   