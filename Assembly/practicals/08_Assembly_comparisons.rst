Suggestions for questions to ask
================================

Table of available data
~~~~~~~~~~~~~~~~~~~~~~~

+--------------------------------------------------+------------------+------------------+------------------------------------------+
| Filename                                         | Technology       | Read length      | Details                                  |
+==================================================+==================+==================+==========================================+
| MiSeq\_Ecoli\_MG1655\_50x\_R\*.fastq             | Illumina MiSeq   | 150 bp           | paired end, 50x coverage                 |
+--------------------------------------------------+------------------+------------------+------------------------------------------+
| MiSeq\_Ecoli\_MG1655\_110721\_R\*.fastq          | Illumina         | 150 bp           | paired end, 400x coverage                |
+--------------------------------------------------+------------------+------------------+------------------------------------------+
| Nextera\_MP\_R\*\_50x.fastq                      | Illumina         | 150 bp           | Nextera mate pair reads, 50 x coverage   |
+--------------------------------------------------+------------------+------------------+------------------------------------------+
| ERA411499\_2D\_all.fastq                         | MinION           | average 6kbp     | 2D reads only, 30x coverage              |
+--------------------------------------------------+------------------+------------------+------------------------------------------+
| m130404\_014004\_filtered\_subreads\_30x.fastq   | PacBio           | average 5.2 bp   | P5C3 data, 30x coverage                  |
+--------------------------------------------------+------------------+------------------+------------------------------------------+

Table of available assembly programs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

+-----------+------------+----------+----------+
| Program   | Illumina   | PacBio   | MinION   |
+===========+============+==========+==========+
| Velvet    | X          |          |          |
+-----------+------------+----------+----------+
| SPADES    | X          | X        | X        |
+-----------+------------+----------+----------+
| HGAP      |            | X        |          |
+-----------+------------+----------+----------+
| Megahit   | X          |          |          |
+-----------+------------+----------+----------+

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

Megahit assembly
~~~~~~~~~~~~~~~~

Megahit is a fast assembly but can only take in paired Illumina reads,
not mate pairs or reads from the MinION or PacBio. A basic assembly on
the 50x paired end data would be:

::

    megahit -o megahit_PE -t 2 \
        -1 /data/assembly/MiSeq_Ecoli_MG1655_50x_R1.fastq \
        -2 /data/assembly/MiSeq_Ecoli_MG1655_50x_R2.fastq \
        > megahit.out 2>&1

The assembly will be in the ``final.contigs.fa`` file.

Note that for ``reapr`` to work, you'll need to adjust the naming of the
fasta files:

::

    sed 's/ /_/g' final.contigs.fa >final.contigs_fixed.fa

Use the ``final.contigs_fixed.fa`` file for all further steps.

Feel free to explore the megahit parameters to help you decide a
suitable question:

::

    megahit -h
