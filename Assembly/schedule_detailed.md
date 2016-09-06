Schedule for the Assembly module
================================

###Day 1

* brief overview of the module
* assembly exercise
  * reconstruct the original text
  * discuss results
  * show graph of what can be reconstructed from the reads, have group discuss amongst themselves
* lecture: "Principles and problems of *de novo* genome assembly"
* pen-and-paper: draw some De Bruijn graphs
* tutorial: exploring De Bruijn graphs in interactive Jupyter Notebook
* Lunch break
* short lecture: *de novo* assembly using velvet
* tutorial: assembly with velvet
  * test singleton reads with k between 21 and 113, log N50 in google spreadsheet
  * Mentimeter multiple choice question: why did the contig N50 distribution show a peak?
  * explain nodes in the de Bruin graph and in velvet's LastGraph
  * plot node coverage distribution in Jupyter Notebook
  * choose expected k-mer coverage and redo assembly
  * choose coverage cutoff and redo assembly
  * have velvet determine these values
  * incorporate paired end information
  * assemblathon_stats.pl script
  * finding repeats by exploring the `stats.txt` file
  * add mate pair library and redo the assembly (all had started this at 16:00)
  * discuss assembly and BLAST results in plenum
* starting overnight assemblies in groups
  * spades illumina paired end + mate pair
  * spades illumina paired end + MinION reads
  * spades illumina paired end + PacBio reads
  * Canu with only PacBio reads
  * Canu with only MinION reads
  * miniasm with only PacBio reads
  * miniasm with only MinION reads

###Day 2

* principles behind SPADES, Canu and miniasm+racon
	* demo: IGV and mapped PacBio and MinION reads
* continue overnight assemblies
  * racon round 1 on miniasm assemblies
  * quiver on canu assemblies
* mapping reads back to the velvet assembly with `bwa`
* visualisation of mapped reads in IGV
* lunch
* continue overnight assemblies
  * racon round 2 on miniasm assemblies
* basic metrics of the assemblies performed so far
  * <https://docs.google.com/spreadsheets/d/1RCujjvlnJqFk-W1oO2ujMLvy8WjaZw8nowAIZPZXkj0/edit?usp=sharing>
* assembly evaluation and improvement using REAPR on the velvet paired end plus mate pair assembly
* evaluating the other assemblies
  * bwa
  * reapr

###Day 3

* reapr on the overnight assemblies from day 1 (SPADES and HGAP)
* comparative evaluation of assemblies
  * quast on the SPADES and HGAP assemblies
  * add your group's assemblies to the assembly reporting spreadsheet
* lecture: "Assembly, before and after"
* lunch
* comparing assemblies to the reference using Quast: velvet k81 PE + MP assembly
* start quast on all other assemblies
* Mentimeter multiple choice question: Which assembly is best?
* demo:

```
quast.py -t 2 -o quast_show -L \
        -R /projects/cees/in_progress/ecoli/data/references/NC_000913_K12_MG1655.fasta \
        -G /projects/cees/in_progress/ecoli/data/references/e.coli_genes.gff \
        velvet_k81_PE+MP/assembly.fasta velvet_k81_PE+MP/reapr_results/04.break.broken_assembly.fa spades_PE+MP/assembly.fasta spades_PE+ONT/assembly.fasta spades_PE+PacBio/assembly.fasta canu_P6C4/assembly.fasta canu_P6C4_quiver/assembly.fasta
```

* go over quast results, also google spreadsheets
* rounding up: which assembly was best?