Mapping PacBio and MinION reads using `bwa`
=====================================

To run `reapr` on assemblies, we need a `bam` file. We need to specify some
extra options when running `bwa` on pacbio og minion data. 


## Index reference genome

We are mapping the reads to their assemblies. To do that, we need an index:


```
bwa index -a bwtsw ASSEMBLY.FASTA
```


## Mapping MinION data

Run this command after indexing.

```
bwa mem -t 3 -x ont2d /path/to/ASSEMBLY.FASTA \ 
/share/inf-biox121/data/assembly/MAP006-1_2D_pass.fastq  | \ 
samtools view -buS - | \ 
samtools sort - -o map_ONT.sorted.bam

samtools index map_ONT.sorted.bam
```

## Mapping PacBio data

Run this command after indexing.

```
bwa mem -t 3 -x pacbio /path/to/ASSEMBLY.FASTA \ 
/share/inf-biox121/data/assembly/m141013_011508_filtered_subreads_30x.fastq  | \ 
samtools view -buS - | samtools sort - -o map_PacBio.sorted.bam

samtools index map_PacBio.sorted.bam
```

