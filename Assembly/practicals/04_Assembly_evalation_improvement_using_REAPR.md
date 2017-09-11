Assembly improvement using REAPR
================================
From the REAPR website:
> REAPR is a tool that evaluates the accuracy of a genome assembly using mapped 
paired end (and mate pair) reads, without the use of a reference genome for 
comparison. It can be used in any stage of an assembly pipeline to automatically 
break incorrect scaffolds and flag other errors in an assembly for manual 
inspection. It reports mis-assemblies and other warnings, and produces a new 
broken assembly based on the error calls.

REAPR can take both paired end reads mapped to the assembly, and mate pairs. 
Here we will restrict the analysis to the mate pairs.

### Using REAPR

* `cd` to folder with assembly fasta file
* Run REAPR as follows:

```
reapr pipeline ASSEMBLY.FASTA bwa/map_mp.sorted.bam reapr_results >reapr.out 2>&1
```

* REAPR wil start producing some files in the `reapr_results` folder, and then 
take a long time in the `[REAPR pipeline] Running stats` stage, while adding 
data to the file `01.stats.per_base.gz`. 
* After that, it is finished quite quickly. 

To view PDF files, you can use the command `evince`.


### REAPR output
* The `reapr_results` folder and the folder `reapr_results/00.Sample` has a few 
PDFs that may be of interest
* The file `05.summary.report.txt` has a lot of information on what REAPR did 
with the assembly. Error-free bases have at least 5X perfect and unique 
coverage of paired end reads. For more information, check the REAPR manual.
* The file `04.break.broken_assembly_bin.fa` is a revised version of 
*only those* scaffolds from the assembly that were broken at places REAPR 
determined an error
* The file `04.break.broken_assembly.fa` is a revised version of the assembly, 
with all scaffolds, whether they were broken or not. Broken contigs have their 
name changed: `REAPR_bin` is added to the beginning, and the *last two numbers 
in the name* are the coordinates where reapr broke the assembly
* Finally, there is a `gff` file with the detected errors called 
`03.score.errors.gff.gz`. You can add this file to the IGV browser, but it needs 
a small modification: all spaces in the file need to be replaced by underscores 
(otherwise only the first 'word' of each line will be shown in the browser). 
For this, we use the tool `zcat` to extract the information of the compressed 
file, and pipe the text into the `sed` program to replace all spaces with the 
`_` sign:

```
zcat 03.score.errors.gff.gz |sed 's/ /_/g' >03.score.errors_nospaces.gff
```
In this file, regions where reapr broke the assembly are marked with 
`FCD_failure`. You can now add the `03.score.errors_nospaces.gff` file to 
IGV. Find the regions where reapr broke the assembly.

<!--
(using the `04.break.broken_assembly.fa` file) and see whether you agree 
with reapr's conclusion. 
-->