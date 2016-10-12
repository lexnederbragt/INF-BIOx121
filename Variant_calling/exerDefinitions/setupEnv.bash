# This script is to be called at the beginning of every exercise
# 1. It sets up variables containing the key directories which are needed to perform the exercises
# 2. It creates some key aliases for useful commands


## DIrectories #########################################################################

# The central location where the original files are located
# On bioinfcourse.hpc.uio.no /work/projects/htscourse/vc
# On my computer /Users/timothyh/home/courses/course_vc_2014_autumn
export centralVcDir=/data/vc

# The local location where the student wants their place your vc folder
export localVcDir=${HOME}/vc

# dataDir can be local or central
# advantage of it being local is: 1. faster access and 2. easier for students to understand
# advantage of central: there is no need for students to change anything so central saves storage

export dataDirLocal=1 # 0=false, 1=true <<<<<<<<<<<<< THIS IS WHERE WE SET WHETHER DATA DIR IS LOCAL OR CENTRAL

if [ $dataDirLocal == "1" ]; then	
	# Data dir is local
	export dataDir=${localVcDir}/inputData
else
	# Data dir is central
	export dataDir=${centralVcDir}/inputData
fi

# exerDir where the exercises should be performed: this can be in the exerDefinitions or exerSandbox (depends on how much structure is wanted)
# exerSandbox keeps more separation
export exerDir=${localVcDir}/exerSandbox

# Where I have installed own version of software
export swDir=${centralVcDir}/sw


## Settings #############################################################################

# Set up the path for the exercises
PATH=${centralVcDir}/sw:${PATH};

# If you want a nice command line where you can see where you are at the prompt
declare -x PS1="\n\[\033[04m\]\u@\h:\w\[\033[00m\]\n% ";

# If you want to be able to quickly list chronologically (very useful when running a pipeline)
alias lrt='ls -lrth'

