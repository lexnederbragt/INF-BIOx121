
## Sources of programs, scripts, datafiles etc

### Datafiles

* Miseq 2 x 150 paired end reads
  * originally found at [http://www.illumina.com/science/data_library.ilmn](http://www.illumina.com/science/data_library.ilmn), but the data are no longer there. Those interested can find a copy of the subset used in the course here: [read1](https://www.dropbox.com/s/kopguhd9z2ffbf6/MiSeq_Ecoli_MG1655_50x_R1.fastq) [read2](https://www.dropbox.com/s/i99h7dnaq61hrrc/MiSeq_Ecoli_MG1655_50x_R2.fastq)
  * random subsampling using seqtk [https://github.com/lh3/seqtk](https://github.com/lh3/seqtk)
* Nextera mate pair reads
  * from Illumina basespace [https://basespace.illumina.com/‎](https://basespace.illumina.com/‎), look for "Nextera Mate Pair (E. Coli)" [https://basespace.illumina.com/project/294296/Nextera-Mate-Pair-E-Coli](https://basespace.illumina.com/project/294296/Nextera-Mate-Pair-E-Coli)
* PacBio reads
  * from <https://github.com/PacificBiosciences/DevNet/wiki/E.-coli-Bacterial-Assembly>. Subsampling was done using `seqtk`: `seqtk sample m141013_011508_sherri_c100709962550000001823135904221533_s1_p0.filtered_subreads.fastq 0.2 >m141013_011508_filtered_subreads_30x.fastq`
* MinIOn data
  * from Nick Loman, see <http://lab.loman.net/2015/09/24/first-sqk-map-006-experiment/>. Reads from ENA entry <http://www.ebi.ac.uk/ena/data/view/ERR1147227> were downloaded through ftp: <ftp://ftp.sra.ebi.ac.uk/vol1/ERA540/ERA540530/oxfordnanopore_native/MAP006-1.tar>. 2D reads were extracted using `poretools 0.5.1` with `poretools fastq --type 2D MAP006-1/MAP006-1_downloads/pass/ >MAP006-1_2D_pass.fastq`

  
**NOTE** one could also use the MiSeq PE 2x300 dataset available here (Oct 2014): [http://systems.illumina.com/systems/miseq/scientific_data.ilmn](http://systems.illumina.com/systems/miseq/scientific_data.ilmn)

### Read QC

* `FastQC` v0.11.5 from [http://www.bioinformatics.babraham.ac.uk/projects/fastqc/](http://www.bioinformatics.babraham.ac.uk/projects/fastqc/)

### Assembly puzzle
Originally developed by Titus Brown, see [http://ivory.idyll.org/blog/the-assembly-exercise.html](http://ivory.idyll.org/blog/the-assembly-exercise.html).

### De Bruin Graph notebook
Many thanks to Ben Langmead for making this available as part of teaching material for his computational genomics class. As the code was released under a GNU GPL license, the `DeBruijnGraph.ipynb` IPyhton notebook is also released under the same license.
Modified from  [http://nbviewer.ipython.org/github/BenLangmead/comp-genomics-class/blob/master/notebooks/CG_deBruijn.ipynb](http://nbviewer.ipython.org/github/BenLangmead/comp-genomics-class/blob/master/notebooks/CG_deBruijn.ipynb)


### Assembly programs

* `Velvet` version 1.2.10 from [http://www.ebi.ac.uk/~zerbino/velvet/](http://www.ebi.ac.uk/~zerbino/velvet/)
* `SPAdes` genome assembler version 3.9.0 from [http://bioinf.spbau.ru/spades](http://bioinf.spbau.ru/spades)
* `canu` version 1.3, see <http://canu.readthedocs.io>
* `minimap` from <https://github.com/lh3/minimap>
* `miniasm` from <https://github.com/lh3/miniasm>
* `racon` from <https://github.com/isovic/racon>
* `quiver` from smrtanalysis 2.3.0 

### Other programs

* `bwa` version 0.7.13 from [http://bio-bwa.sourceforge.net/](http://bio-bwa.sourceforge.net/)
* `samtools` version: 1.3.1 from [http://www.htslib.org/](http://www.htslib.org/)
* `IGV` version 2.3.68 from [http://www.broadinstitute.org/igv/](http://www.broadinstitute.org/igv/)
* `REAPR` version: 1.0.18 from [http://www.sanger.ac.uk/resources/software/reapr/](http://www.sanger.ac.uk/resources/software/reapr/)
* `quast` 4.3 from [http://bioinf.spbau.ru/quast](http://bioinf.spbau.ru/quast)

### Scripts

* `velvet-estimate-exp_cov.pl` is included in the velvet distribution
* `assemblathon_stats.pl` See [https://github.com/lexnederbragt/sequencetools](https://github.com/lexnederbragt/sequencetools). Modified from [https://github.com/ucdavis-bioinformatics/assemblathon2-analysis](https://github.com/ucdavis-bioinformatics/assemblathon2-analysis)
* `scaffoldgap2bed.py` from [https://github.com/lexnederbragt/sequencetools](https://github.com/lexnederbragt/sequencetools)
