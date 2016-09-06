Assembly using miniasm+racon
================================

A recent [preprint](http://biorxiv.org/content/early/2016/08/05/068122) described a fast approach for assembling and correcting PacBio and MinION data. The principle is:

* using `minimap` for fast all-against-all overlap of raw reads
* using `miniasm`, this "simply concatenates pieces of read sequences to generate the final sequences. Thus the per-base error rate is similar to the raw input reads."
* mapping the raw reads back to the assembly using `minimap` again
* using `racon` ('rapid consensus') for consensus calling
* perform the `racon` step at least twice

## Running `miniasm` and `racon` on MinION data

### All-against-all overlap with `minimap`

Note how the reads are used twice here, as we map the reads against themselves:

```
minimap -Sw5 -L100 -m0 \
-t 2 \
/data/MAP006-1_2D_pass.fastq \
/data/MAP006-1_2D_pass.fastq \
| gzip -1 >racon_MAP006-1_2D_1.paf.gz
```

The output is in the so-called [PAF (Pairwise mApping) Format](https://github.com/lh3/miniasm/blob/master/PAF.md), and is compressed 'on the fly'.

### Assembly with `miniasm`

Minims takes the `paf` file and produces an assembly in [GFA (Graphical Fragment Assembly)](https://github.com/pmelsted/GFA-spec/blob/master/GFA-spec.md) format.

```
miniasm -f data/MAP006-1_2D_pass.fastq \
racon_MAP006-1_2D_1.paf.gz \
>racon_MAP006-1_2D_1.gfa
```

Since we have only one sequence in the `GFA` file (at least for this assembly), we can use a simple set of unix commands to turn it into a `fasta` file:

```
head -n 1 racon_MAP006-1_2D_1.gfa | awk '{print ">"$2; print $3}' > racon_MAP006-1_2D_1.raw_assembly.fasta
```

### Correction with `racon`, round 1

We first use `minimal` again, this time with the original reads mapped against the 'raw' assembly:

```
minimap racon_MAP006-1_2D_1.raw_assembly.fasta \
/data/MAP006-1_2D_pass.fastq \
>racon_MAP006-1_2D_1.raw_assembly.reads_mapped.paf && \
```

`racon` is basically run as `racon -t num_threads mapped_reads.paf assembly.fasta consensus.fasta`:

```
racon -t 2 \
/data/MAP006-1_2D_pass.fastq \
racon_MAP006-1_2D_1.raw_assembly.reads_mapped.paf \
racon_MAP006-1_2D_1.raw_assembly.fasta \
racon_MAP006-1_2D_1.racon1.fasta
```

This will take some time.

### Correction with `racon`, round 2

Run the mapping with `minimal` and the correction with `racon` again, but now with the results of the first round of correction as input. Please be careful when naming files!
        
## Running `miniasm` and `racon` on PacBio data

Use *all* available reads from the P6C4 run, i.e. :

```
/data/pacbio/Analysis_Results/m141013_011508_sherri_c100709962550000001823135904221533_s1_p0.filtered_subreads.fastq
```

The commands are the same as for the MinION data. Again, please be careful when naming files!