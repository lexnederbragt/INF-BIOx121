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
  * add mate pair liberary and redo the assembly (all had started this at 16:00)
  * discuss assembly and BLAST results in plenum
* starting overnight assemblies in groups
  * spades illumina paired end + mate pair
  * spades illumina paired end + MinION reads
  * spades illumina paired end + PacBio reads
  * HGAP with only PacBio reads

###Day 2

* mapping reads back to the velvet assembly with `bwa`
* visualisation of mapped reads in IGV
* lunch
* basic metrics of the assemblies performed so far
  * <https://docs.google.com/spreadsheets/d/1j_BWpW6dFkgqj3UOiMFXDsVXayec6C6CXFiFGuFisUQ/edit?usp=sharing>
* assembly improvement using REAPR on the velvet paired end plus mate pair assembly
* evaluating the other assemblies
  * bwa
  * reapr
* SKIPPED: deciding on and starting up overnight assemblies
* SKIPPED: each group comes up with a few hypothesis and starts assemblies to test these

###Day 3

* reapr on the overnight assemblies from day 1 (SPADES and HGAP)
* comparative evaluation of assemblies
  * quest on the SPADES and HGAP assemblies
  * add your group's assemblies to the assembly reporting spreadsheet
* lecture: "Assembly, before and after"
* lunch
* comparing assemblies to the reference using Quast: velvet k81 PE + MP assembly
* start quast on all other assemblies
* Mentimeter multiple choice question: Which assembly is best?
* go over quest results, also google spreadsheets
* rounding up: which assembly was best?