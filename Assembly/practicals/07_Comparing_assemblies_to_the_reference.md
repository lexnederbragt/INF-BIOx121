Comparing assemblies to the reference
=====================================

The Quast program can be used to generate similar metrics as the assemblathon_stat.pl script, pluss some more and some visualisations.

Program|Options|Explanation
-------|-------|-------------
Quast||Evaluating genome assemblies
|-o|name of output folder
|-R|Reference genome
|-G|File with positions of genes in the reference (see manual)
|-T|number of threads (cpu's) to use
|sequences.fasta|one or more files with assembled sequences
|-l| comma-separates list of names for the assemblies, e.g. "assembly 1", "assembly 2" (in the same order as the sequence files)
|--scaffolds|input sequences are scaffolds, not contigs. They will be split at 10 N's or more to analyse contigs ('broken' assembly)
|--est-ref-size| estimated reference genome size (when not provided)
|--gene-finding| apply GenemarkS for gene finding

See the manual for information on the output of Quast:
[http://quast.bioinf.spbau.ru/manual.html#sec3](http://quast.bioinf.spbau.ru/manual.html#sec3)

####Running Quast
On the server, make a folder called `quast` and move into it. Then run:

```
quast.py -T 2 \
-o out_folder_name \
-R /data/assembly/NC_000913_K12_MG1655.fasta \
-G /data/assembly/e.coli_genes.gff \
../path/to/assembly1.fasta \
../path/to/assembly2.fasta \
-l "Assembly 1, Assembly 2"
```

Note that the `--scaffold` option is not used here for simplification. Also, make sure you name the assemblies (`-l`) in the same order as you give them to quast!

####Quast output
Quast will produce a html report file `report.html` that you can download to your PC and open in your browser. Hover over the row names to get a description. Also have a look at the 'Extended report'.

Alternatively, have a look at the report.pdf file (it has a few more plots).
