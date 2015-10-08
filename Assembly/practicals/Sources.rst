Sources of programs, scripts, datafiles etc
-------------------------------------------

Datafiles
~~~~~~~~~

-  Miseq 2 x 150 paired end reads
-  from http://www.illumina.com/science/data_library.ilmn
-  random subsampling using seqtk https://github.com/lh3/seqtk
-  Nextera mate pair reads
-  from Illumina basespace
   `https://basespace.illumina.com/‎ <https://basespace.illumina.com/‎>`__,
   look for "Nextera Mate Pair (E. Coli)"
   https://basespace.illumina.com/project/294296/Nextera-Mate-Pair-E-Coli
-  PacBio reads
-  from
   https://github.com/PacificBiosciences/DevNet/wiki/E.-coli-20kb-Size-Selected-Library-with-P4-C2
-  MinIOn data
-  from Loman, Quick and Simpson, (2015): `A complete bacterial genome
   assembled de novo using only nanopore sequencing
   data <http://www.nature.com/nmeth/journal/v12/n8/full/nmeth.3444.html>`__,
   also available through http://www.ebi.ac.uk/ena/data/view/ERA411499

**NOTE** one could also use the MiSeq PE 2x300 dataset available here
(Oct 2014):
http://systems.illumina.com/systems/miseq/scientific_data.ilmn

Read QC
~~~~~~~

-  ``FastQC`` v0.11.2 from
   http://www.bioinformatics.babraham.ac.uk/projects/fastqc/

Assembly puzzle
~~~~~~~~~~~~~~~

Originally developed by Titus Brown, see
http://ivory.idyll.org/blog/the-assembly-exercise.html.

De Bruin Graph notebook
~~~~~~~~~~~~~~~~~~~~~~~

Many thanks to Ben Langmead for making this available as part of
teaching material for his computational genomics class. As the code was
released under a GNU GPL license, the ``DeBruijnGraph.ipynb`` IPyhton
notebook is also released under the same license. Modified from
http://nbviewer.ipython.org/github/BenLangmead/comp-genomics-class/blob/master/notebooks/CG_deBruijn.ipynb

Assembly programs
~~~~~~~~~~~~~~~~~

-  ``Velvet`` version 1.2.10 from http://www.ebi.ac.uk/~zerbino/velvet/
-  ``SPAdes`` genome assembler version 3.6.0 from
   http://bioinf.spbau.ru/spades
-  HGAP: part of smrtanalysis 2.3.0 from PacBio, see
   http://pacbiodevnet.com/
-  ``megahit`` version 1.0.2 from
   https://github.com/voutcn/megahit/releases

Other programs
~~~~~~~~~~~~~~

-  ``bwa`` version 0.7.12 from http://bio-bwa.sourceforge.net/
-  ``samtools`` version: 1.1 from http://www.htslib.org/
-  ``IPython`` and the IPython notebook, version 2.3.0, from
   http://ipython.org/
-  ``IGV`` version 2.3 from http://www.broadinstitute.org/igv/
-  ``REAPR`` version: 1.0.18 from
   http://www.sanger.ac.uk/resources/software/reapr/
-  ``quast`` 3.0 from http://bioinf.spbau.ru/quast

Scripts
~~~~~~~

-  ``velvet-estimate-exp_cov.pl`` is included in the velvet distribution
-  ``assemblathon_stats.pl`` See
   https://github.com/lexnederbragt/sequencetools. Modified from
   https://github.com/ucdavis-bioinformatics/assemblathon2-analysis
-  ``scaffoldgap2bed.py`` from
   https://github.com/lexnederbragt/sequencetools
