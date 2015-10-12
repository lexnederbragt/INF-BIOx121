Assembly using velvet
=====================

*De novo* assembly of Illumina reads using velvet
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Assembling short-reads with Velvet
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

We will use Velvet to assemble Illumina reads on their own. Velvet uses
the *de Bruijn graph* approach.

We will assemble *E. coli K12* strain MG1655 which was sequenced on an
Illumina MiSeq. The instrument read 150 bases from each direction.

We wil first use paired end reads only:

| ``/data/assembly/MiSeq_Ecoli_MG1655_50x_R1.fastq``
| ``/data/assembly/MiSeq_Ecoli_MG1655_50x_R2.fastq``

Building the Velvet Index File
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Velvet requires an index file to be built before the assembly takes
place. We must choose a *k-* mer value for building the index. Longer
*k-* mers result in a more stringent assembly, at the expense of
coverage. There is no definitive value of *k* for any given project.
However, there are several absolute rules:

-  *k* must be less than the read length
-  it should be an odd number

Firstly we are going to run Velvet in single-end mode, *ignoring the
pairing information*. Later on we will incorporate this information.

First, we need to make sure we can use velvet:

Set up the environment
^^^^^^^^^^^^^^^^^^^^^^

For this part of the course, *every time you log into the server* you
need to execute the command below. IMPORTANT do not use spaces between
``PATH=`` and ``$PATH``!

::

    export PATH=/data/bin/:$PATH

To be able to use velvet, load the following module:

::

    module load velvet

Now, 'go home':

::

    cd ~

or simply type

::

    cd

Create the assembly folder:

::

    mkdir assembly
    cd assembly
    mkdir velvet
    cd velvet

A first assembly
^^^^^^^^^^^^^^^^

Find a value of *k* (between 21 and 113) to start with, and record your
choice in this google spreadsheet:
`bit.ly/INFBIO1 <http://bit.ly/INFBIO1>`__. Run ``velveth`` to build the
hash index (see below).

+-----------+----------------+-------------------------------------------------------+
| Program   | Options        | Explanation                                           |
+===========+================+=======================================================+
| velveth   |                | Build the Velvet index file                           |
+-----------+----------------+-------------------------------------------------------+
|           | foldername     | use this name for the results folder                  |
+-----------+----------------+-------------------------------------------------------+
|           | value\_of\_k   | use k-mers of this size                               |
+-----------+----------------+-------------------------------------------------------+
|           | -short         | short reads (as opposed to long, Sanger-like reads)   |
+-----------+----------------+-------------------------------------------------------+
|           | -separate      | read1 and read2 are in separate files                 |
+-----------+----------------+-------------------------------------------------------+
|           | -fastq         | read type is fastq                                    |
+-----------+----------------+-------------------------------------------------------+

Build the index as follows:

::

    velveth ASM_NAME VALUE_OF_K \  
    -short -separate -fastq \  
    /data/assembly/MiSeq_Ecoli_MG1655_50x_R1.fastq \  
    /data/assembly/MiSeq_Ecoli_MG1655_50x_R2.fastq  

**NOTES**

-  Change ``ASM_NAME`` to something else of your choosing
-  Change ``VALUE_OF_K`` to the value you have picked
-  The command is split over several lines by adding a space, and a
   ``\`` (backslash) to each line. This trick makes long commands more
   readable. If you want, you can write the whole command on one line
   instead.

After ``velveth`` is finished, look in the new folder that has the name
you chose. You should see the following files:

::

    Log
    Roadmaps
    Sequences

The '``Log``\ ' file has a useful reminder of what commands you typed to
get this assembly result, for reproducing results later on.
'``Sequences``\ ' contains the sequences we put in, and '``Roadmaps``\ '
contains the index you just created.

Now we will run the assembly with default parameters:

::

    velvetg ASM_NAME

Velvet will end with a text like this:

``Final graph has ... nodes and n50 of ..., max ..., total ..., using .../... reads``

The number of nodes represents the number of nodes in the graph, which
(more or less) is the number of contigs. Velvet reports its N50 (as well
as everything else) in 'kmer' space. The conversion to 'basespace' is as
simple as adding k-1 to the reported length.

Look again at the folder ``ASM_NAME``, you should see the following
extra files:

| ``contigs.fa``
| ``Graph``
| ``LastGraph``
| ``PreGraph``
| ``stats.txt``

The important files are:

| ``contigs.fa`` - the assembly itself
| ``Graph`` - a textual representation of the contig graph
| ``stats.txt`` - a file containing statistics on each contig

**Questions**

-  What k-mer did you use?
-  What is the N50 of the assembly?
-  What is the size of the largest contig?
-  How many contigs are there in the ``contigs.fa`` file? Use
   ``grep -c NODE contigs.fa``. Is this the same number as velvet
   reported?

Log your results in this google spreadsheet: ``bit.ly/INFBIO1``

**We will discuss the results together and determine *the optimal* k-mer
for this dataset.**

**Advanced tip:** You can also use VelvetOptimiser to automate this
process of selecting appropriate *k*-mer values. VelvetOptimizer is
included with the Velvet installation.

Now run ``velveth`` and ``velvetg`` for the kmer size determined by the
whole class. Use this kmer from now on!

Estimating and setting ``exp_cov``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Much better assemblies are produced if Velvet understands the expected
coverage for unique regions of your genome. This allows it to try and
resolve repeats. The data to determine this is in the ``stats.txt``
file. The full description of this file is in the Velvet Manual, at
http://www.ebi.ac.uk/~zerbino/velvet/Manual.pdf.

A so-called Jupyter notebook has been provided to plot the distribution
of the coverage of the nodes. In order to use it, you need to do the
following on the local linux machine *Not on the server*:

NOTE: if you are on ``vetur`` OR ``vor``, type:

::

    ssh nordur

OR

::

    ssh austur

and enter your password.

-  install the Jupyter notebook and some python packages (this may take
   a few minutes):

::

    pip install --user jupyter pandas numpy pysam

-  prepare a folder on your linux machine

::

    cd ~
    mkdir assembly
    cd assembly
    mkdir velvet
    cd velvet
    mkdir ASM_NAME
    cd ASM_NAME

-  copy the ``stats.txt`` file from the server to this folder using the
   ``rsync`` command
-  copy the notebook file ``/data/assembly/node_coverage.ipynb`` from
   the server to this folder using ``rsync``
-  start the notebook:

::

    jupyter notebook node_coverage.ipynb

OR

::

    ipython notebook node_coverage.ipynb

-  After a little while, your web browser will start with a new tab with
   the notebook in it
-  follow the instructions in the notebook

**Question:**

-  What do you think is the approximate expected k-mer coverage for your
   assembly?

When you are done with the Jupyter notebook:

-  save the notebook
-  close the browser windows
-  in the terminal where you started Jupyter notebook, click ctrl-c and
   confirm.

Now run velvet again, supplying the value for ``exp_cov`` (k-mer
coverage) corresponding to your answer:

::

    velvetg ASM_NAME -exp_cov PEAK_K_MER_COVERAGE

**Question:**

-  What improvements do you see in the assembly by setting a value for
   ``exp_cov``?

Setting ``cov_cutoff``
^^^^^^^^^^^^^^^^^^^^^^

You can also clean up the graph by removing low-frequency nodes from the
*de Bruijn* graph using the ``cov_cutoff`` parameter. Low-frequency
nodes can result from sequencing errors, or from parts of the genome
with very little sequencing coverage. Removing them will often result in
better assemblies, but setting the cut-off too high will also result in
losing useful parts of the assembly. Using the histogram from
previously, estimate a good value for ``cov_cutoff``.

::

    velvetg ASM_NAME -exp_cov YOUR_VALUE -cov_cutoff YOUR_VALUE  

Try some different values for ``cov_cutoff``, keeping ``exp_cov`` the
same and record your assembly results.

Asking velvet to determine the parameters
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can also ask Velvet to predict the values for you:

::

    velvetg ASM_NAME -exp_cov auto -cov_cutoff auto

**Questions:**

-  What values of *exp\_cov* and *cov\_cutoff* did Velvet choose?
-  Check the output to the screen. Is this assembly better than your
   best one?

Incorporating paired-end information
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Paired end information contributes additional information to the
assembly, allowing contigs to be scaffolded. We will first re-index your
reads telling Velvet to use paired-end information, by using
``-shortPaired`` instead of ``-short`` for ``velveth``. Then, re-run
velvetg using the best value of ``k``, ``exp_cov`` and ``cov_cutoff``
from the previous step.

**!!! IMPORTANT Pick a new name for your assembly !!!**

::

    velveth ASM_NAME2 VALUE_OF_K \  
    -shortPaired -fastq -separate \  
    /data/assembly/MiSeq_Ecoli_MG1655_50x_R1.fastq \  
    /data/assembly/MiSeq_Ecoli_MG1655_50x_R2.fastq

    velvetg ASM_NAME2 -exp_cov auto \  
    -cov_cutoff auto  

**Questions:**

-  How does doing this affect the assembly?
-  what does velvet say about the insert size of the paired end library?

Scaffold and contig metrics
^^^^^^^^^^^^^^^^^^^^^^^^^^^

| The sequences in the ``contigs.fa`` file are actually scaffolds.
| Use the ``assemblathon_stats.pl`` script to generate metrics for this,
  and all following assemblies.

**The assemblathon stats script**

The assemblathon `www.assemblathon.org <www.assemblathon.org>`__ used a
perl script to obtain standardized metrics for the assemblies that were
submitted. Here we use (a slightly modified version of) this script. It
takes the size of the genome, and one sequence fasta file as input. The
script breaks the sequences into contigs when there are 20 or more N’s,
and reports all sorts of metrics.

+--------------------------+-------------+----------------------------------------------------------------+
| Program                  | Options     | Explanation                                                    |
+==========================+=============+================================================================+
| assemblathon\_stats.pl   |             | Provide basic assembly metrics                                 |
+--------------------------+-------------+----------------------------------------------------------------+
|                          | -size       | size (in Mbp, million basepairs) of target genome (optional)   |
+--------------------------+-------------+----------------------------------------------------------------+
|                          | seq.fasta   | fasta file of contigs or scaffolds to report on                |
+--------------------------+-------------+----------------------------------------------------------------+

Example, for a 3.2 Mbp genome:

::

    assemblathon_stats.pl -s 3.2 scaffolds.fasta

OR, save the output to a file with

::

    assemblathon_stats.pl -s 3.2 scaffolds.fasta > metrics.txt

Here, ``>`` (redirect) symbol used to ‘redirect’ what is written to the
screen to a file.

**For this exercise**, use the known length for this strain, 4.6 Mbp,
for the genome size

Some of the metrics the script reports are:

-  N50 is based on the total assembly size
-  NG50 is based on the estimated/known genome size
-  L50 (LG50) count: number of scaffolds/contigs at least N50 (NG50)
   bases

**Questions**

-  How much of the estimated genome size is covered in the scaffolds
-  how many gap bases ('N') are left in the scaffolds

Looking for repeats
^^^^^^^^^^^^^^^^^^^

Have a look for contigs which are long and have a much higher coverage
than the average for your genome. One tedious way to do this is to look
into the ``contigs.fa`` file (with ``less``). You will see the name of
the contig ('NODE'), it's length and the kmer coverage. However, trying
to find long contigs with high coverage this way is not very efficient.

A faster was is to again use the ``stats.txt`` file.

Relevant columns are:

1) ID --> sequence ID, same as 'NODE' number in the ``contigs.fa`` file
2) lgth --> sequence 'length'
3) short1\_cov --> kmer coverage (column 6)

Knowing this, we can use the ``awk`` command to select lines for contigs
at least 1kb, with k-mer coverage greater than 60:

::

    awk '($2>=1000 && $6>=60)' stats.txt

``awk`` is an amazing program for tabular data. In this case, we ask it
to check that column 2 ($2, the length) is at least 1000 and column 6
($6, coverage) at least 60. If this is the case, awk will print the
entire line. See http://bit.ly/QjbWr7 for more information on awk.

Find the contig with the highest coverage in the ``contigs.fa`` file.
Perform a BLAST search using NCBI.

**Question:**

-  What is it?
-  Is this surprising? Why, or why not?

The effect of mate pair library reads
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Long-range "mate-pair" libraries can also dramatically improve an
assembly by scaffolding contigs. Typical sizes for Illumina are 2kb and
6kb, although any size is theoretically possible. You can supply a
second library to Velvet. However, it is important that files are
reverse-complemented first as Velvet expects a specific orientation. We
have supplied a 3kb mate-pair library in the correct orientation.

**!!! IMPORTANT Pick a new name for your assembly !!!**

We will use ``-shortPaired`` for the paired end library reads as before,
and add ``-shortPaired2`` for the mate pairs. Also, to make sure we all
end up having the same assembly, the kmer size is given:

::

    velveth ASM_NAME3 81 \  
    -shortPaired -separate -fastq \  
    /data/assembly/MiSeq_Ecoli_MG1655_50x_R1.fastq \  
    /data/assembly/MiSeq_Ecoli_MG1655_50x_R2.fastq \  
    -shortPaired2 -separate -fastq \  
    /data/assembly/Nextera_MP_R1_50x.fastq \  
    /data/assembly/Nextera_MP_R2_50x.fastq  

We use auto values for velvetg because the addition of new reads will
change the genome coverage. The assembly command then becomes:

::

    velvetg ASM_NAME3 -cov_cutoff auto -exp_cov auto

**Questions:**

-  What is the N50 of this assembly?
-  How many scaffolds?
-  How many bases are in gaps?
-  What did velvet estimate for the insert length of the paired-end
   reads, and for the standard deviation? Use the last mention of this
   in the velvet output.
-  And for the mate-pair library?

**TIP** Some mate pair libraries have a significant amount of paired end
reads present as a by-effect of the library preparation. This may
generate misassemblies. If this is the case for your data, add the
``-shortMatePaired2 yes`` to let Velvet know it.

Make a copy of the contigs file and call it ``velvet_pe+mp.fa``

Optional: Skipping the paired end reads
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

As both the mate pairs and the paired end *reads* are of the same
length, and provide the same coverage, it could be interesting to try an
assembly of the mate pair reads only. The read sequences would still be
used to build the contigs, and the mate pair information to build
scaffolds.

**!!! IMPORTANT Pick a new name for your assembly !!!**

The assembly for this part then becomes:

::

    velveth ASM_NAME4 81 \  
    -shortPaired -separate -fastq \  
    /data/assembly/Nextera_MP_R1_50x.fastq \  
    /data/assembly/Nextera_MP_R2_50x.fastq  

    velvetg ASM_NAME4 -cov_cutoff auto -exp_cov auto

**Questions:**

-  What is the N50 of this assembly?
-  How many scaffolds?
-  How many bases are in gaps?
-  How does this assembly compare to the previous ones?

Make a copy of the contigs file and call it ``velvet_mp_only``

Next steps
~~~~~~~~~~

Next, map the reads used for the assemblies back to the scaffolds. See
the tutorial 'Mapping reads to an assembly'

.. toctree:: :maxdepth: 1
