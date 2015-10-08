Suggestions for questions to ask
================================

Table of available data
~~~~~~~~~~~~~~~~~~~~~~~

+--------------------------------------------------+------------------+------------------+--------------------------------------------+
| Filename                                         | Technology       | Read length      | Details                                    |
+==================================================+==================+==================+============================================+
| MiSeq\_Ecoli\_MG1655\_50x\_R\*.fastq             | Illumina MiSeq   | 150 bp           | paired end, 50x coverage                   |
+--------------------------------------------------+------------------+------------------+--------------------------------------------+
| MiSeq\_Ecoli\_MG1655\_110721\_R\*.fastq          | Illumina         | 150 bp           | paired end, 400x coverage                  |
+--------------------------------------------------+------------------+------------------+--------------------------------------------+
| Nextera\_MP\_R\*\_50x.fastq                      | Illumina         | 150 bp           | Nextera mate pair reads, ???? x coverage   |
+--------------------------------------------------+------------------+------------------+--------------------------------------------+
| ERA411499\_2D\_all.fastq                         | MinION           | average 6kbp     | 2D reads only, 30x coverage                |
+--------------------------------------------------+------------------+------------------+--------------------------------------------+
| m130404\_014004\_filtered\_subreads\_30x.fastq   | PacBio           | average 5.2 bp   | P5C3 data, 30x coverage                    |
+--------------------------------------------------+------------------+------------------+--------------------------------------------+

Possible questions
~~~~~~~~~~~~~~~~~~

-  what is the effect of different coverage of the MiSeq paired end
   reads, comparing 50x with 400x for velvet, SPADES, and/or MegaHit
-  what is the effect of using corrected versus uncorrected reads with
   MegaHit (using the corrected reads produced by SPADES)
-  what is the effect of different kmer settings with SPADES
-  is version 3.6 of SPADES better than version 3.5? You can use version
   3.6 by choosing ``module load spades/3.6.0``. See the
   `changelog <http://spades.bioinf.spbau.ru/changelog.html>`__.
