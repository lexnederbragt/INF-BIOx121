Mapping PacBio and MinION reads using `bwa`
=====================================

```
bwa index -a bwtsw /data/assembly/NC_000913_K12_MG1655.fasta
```
```
bwa mem -t 2 -x ont2d /data/assembly/NC_000913_K12_MG1655.fasta /data/MAP006-1_2D_pass.fastq  | samtools view -buS - | samtools sort - -o map_ONT.sorted.bam
samtools index map_ONT.sorted.bam
```

```
bwa mem -t 2 -x pacbio /data/assembly/NC_000913_K12_MG1655.fasta /data/pacbio/Analysis_Results/m141013_011508_filtered_subreads_30x.fastq  | samtools view -buS - | samtools sort - -o map_PacBio.sorted.bam
samtools index map_PacBio.sorted.bam
```

