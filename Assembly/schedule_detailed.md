Schedule for the Assembly module
================================

## Day 1

* brief overview of the module
* assembly exercise
  * reconstruct the original text
  * discuss results
  * show graph of what can be reconstructed from the reads, have group discuss amongst themselves
* lecture: "Principles and problems of *de novo* genome assembly"
* pen-and-paper: draw some De Bruijn graphs
* tutorial: exploring De Bruijn graphs in interactive Jupyter Notebook

## Day 2

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
* starting over lunch assemblies in groups
  * spades illumina paired end + mate pair
  * spades illumina paired end + MinION reads
  * spades illumina paired end + PacBio reads
  * Canu with only PacBio reads
  * Canu with only MinION reads
* Lunch
* velvet cont
* principles behind SPADES, Canu and miniasm+racon
* basic metrics of the assemblies performed so far
  * log metrics to google spreadsheet, one per group
* overnight assemblies
  * miniasm with only PacBio reads
    * racon on PacBio assembly
  * miniasm with only MinION reads
    * racon on MinIon assembly
  * quiver part 1 on canu assemblies
  
## Day 3
 
* check on overnight assemblies
* quiver part 2 on pacbio asm
! collect info on asms
* comparing assemblies to the reference using Quast: velvet k81 PE + MP assembly  
* mapping reads back to the velvet assembly with `bwa`
* lunch
* visualisation of mapped reads in IGV
* assembly evaluation and improvement using REAPR on the velvet paired end plus mate pair assembly
* IF time, map other assemblies, and do reapr with those.
* compare assemblies
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