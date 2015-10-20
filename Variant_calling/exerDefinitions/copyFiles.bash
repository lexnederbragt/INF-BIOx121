#/bin/bash

# ***IMPORTANT****: This script can be called, but it is probably best for students to copy and paste to the terminal

# Sets up the student's own copy of the directory structure and scripts for the exercises
# Script determines whether to copy over the inputData to the local dir based on the dataDirLocal variable

# make sure the local directory exists
mkdir -p ${localVcDir}


# Copy all that is required over to the local directory
# Things that are probably left central: exerResults because big and read only AND all software because will have been installed centrally.
# Basically only copying to local files that students may want to modify

rsync -au --progress ${centralVcDir}/exerSandbox ${centralVcDir}/exerDefinitions ${centralVcDir}/slides ${localVcDir}

# Although the student does not need to modify the inputData, having it locally may facilitate understanding and speed up access (as multiple students accessing the same file may cause load problems)
if [ $dataDirLocal == "1" ]; then
	rsync -au --progress --exclude=dbNSFP2.0b3.txt.gz ${centralVcDir}/inputData ${localVcDir}
fi
