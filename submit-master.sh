#!/bin/bash

######## slurm stuff ###########

#! Name of the job:
#SBATCH -J charmprop_Dcorr_3ptcorr

#! Output:
#SBATCH --output=/lustre2/dc-mcle2/BtoD/out_master/submit-%A.out
#SBATCH --error=/lustre2/dc-mcle2/BtoD/out_master/submit-%A.err

#! Which project should be charged:
#!SBATCH -A HPQCD
#SBATCH -A DIRAC-DP019
#! How many whole nodes should be allocated?
#SBATCH --nodes=2
#! How many (MPI) tasks will there be in total? (<= nodes*16)
#SBATCH --ntasks=32
#! Memory
#SBATCH --mem=MaxMemPerNode
#! How much wallclock time will be required?
#SBATCH --time=12:00:00
#! What types of email messages do you wish to receive?
#!SBATCH --mail-type=ALL
#! mail-type=ALL, FAIL
#! Uncomment this to prevent the job from being requeued (e.g. if
#! interrupted by node failure or system downtime):
#!SBATCH --no-requeue

#! Do not change:
#SBATCH -p sandybridge

#! sbatch directives end here (put any additional directives above this line)

cfg=$1

nsrc=16
Lt=96

root="/lustre2/dc-mcle2/BtoD/"
output="/lustre2/dc-mcle2/BtoD/out_master/out-${cfg}.out"

charmsmears="l e"

################ milc stuff #################

rootmilc="/lustre2/dc-mcle2/BtoD/milc-exec/"

run_milc()
{
    local application="${rootmilc}/ks_spectrum_hisq_7.7.11"
    $rootmilc/gen-milc-infiles.sh $cfg
    echo "running ${application} ${cfg}\n" > $output
    mpirun -ppn $mpi_tasks_per_node -np $np $application $rootmilc/infiles/infile-$cfg > $rootmilc/bumph/bumph-$cfg.txt
}

################# 3pt stuff #################

root3pt="/lustre2/dc-mcle2/BtoD/3pt-exec/"
temp3pt="/lustre2/dc-mcle2/BtoD/3pt-exec/temp/"

gen_src()
{
  local cfg=$1
  dsrc=$((Lt/nsrc))
  local src_start=$(((19*(cfg/5)) % dsrc))  # Magic formula.
  for i in $(seq 0 $((nsrc-1))); do
    echo $((src_start + i*dsrc));
  done
}
##

run_milc_convert()
{
  local convert="${root3pt}/convert-scidac-to-binary.sh"
  for src in $(gen_src $cfg); do
	for smear in $charmsmears; do
	    echo "converting charm cfg=${cfg} source=t${src} smear=${smear}" >> $output
	    $convert "/lustre2/dc-mcle2/BtoD/milc-exec/propagators/" "l3296f211b630m0074m037m440-coul.${cfg}_Rwallfull_m0.450_t${src}_${smear}"                                       
	done
        #binary file is saved in 3pt-exec/temp

	echo "copying over light ${cfg} t${src} to ${temp3pt}" >> $output
	cp "/lustre2/dc-sant2/fine_lattice/etas_fine_propagators/l3296f211b630m0074m037m440-coul.${cfg}_wallprop_m0.0376_th0.0_t${src}" $temp3pt
	echo "converting light $cfg $tsrc" >> $output
	$convert $temp3pt "l3296f211b630m0074m037m440-coul.${cfg}_wallprop_m0.0376_th0.0_t${src}"
	#binary file saved in 3pt-exec/temp
  done
}
##

run_nrqcd_parallel()
{
  local application="${root3pt}/NRQCD_HISQ_3pt.exe"
  for src in $(gen_src $cfg); do
        $root3pt/in/gen-nrqcd-input.sh $cfg $src > $root3pt/in/nrqcd_in_${cfg}_t${src}.xml
        infile="${root3pt}/in/nrqcd_in_${cfg}_t${src}.xml"
        outfile="${root3pt}/out/bumph-${cfg}.${src}"
        echo "running ${application} ${cfg} t${src}" >> $output
	echo "infile = ${infile}" >> $output
	echo "outfile = ${outfile}" >> $output
        srun --exclusive -N1 -n1 $application $infile ulimit -s 200000 > $outfile &
  done
}
##

cleanup()
{
    charm_dir=/lustre2/dc-mcle2/BtoD/milc-exec/propagators/
    charm_source_dir=/lustre2/dc-mcle2/BtoD/milc-exec/sources/
    for src in $(gen_src $cfg); do
	echo 'cleaning up' >> $output	

	#charm
	for smear in $charmsmears; do
	    echo "removing ${charm_dir}/l3296f211b630m0074m037m440-coul.${cfg}_Rwallfull_m0.450_t${src}_${smear}" >> $output
	    rm "${charm_dir}/l3296f211b630m0074m037m440-coul.${cfg}_Rwallfull_m0.450_t${src}_${smear}"
	    echo "removing ${charm_source_dir}/l3296f211b630m0074m037m440-coul.${cfg}_t${src}_${smear}" >> $output
	    rm "${charm_source_dir}/l3296f211b630m0074m037m440-coul.${cfg}_t${src}_${smear}"
	    rm "${temp3pt}/l3296f211b630m0074m037m440-coul.${cfg}_Rwallfull_m0.450_t${src}_${smear}.binary"
	    rm "${temp3pt}/l3296f211b630m0074m037m440-coul.${cfg}_Rwallfull_m0.450_t${src}_${smear}.source.binary"
	done

	#light
	rm "${temp3pt}/l3296f211b630m0074m037m440-coul.${cfg}_wallprop_m0.0376_th0.0_t${src}"
	rm "${temp3pt}/l3296f211b630m0074m037m440-coul.${cfg}_wallprop_m0.0376_th0.0_t${src}.binary"
	rm "${temp3pt}/l3296f211b630m0074m037m440-coul.${cfg}_wallprop_m0.0376_th0.0_t${src}.source.binary"
    done
}
##

##########################################

#! Notes:
#! Charging is determined by node number*walltime. Allocation is in entire nodes.
#! The --ntasks value refers to the number of tasks to be launched by SLURM only. This
#! usually equates to the number of MPI tasks launched. Reduce this from nodes*16 if
#! demanded by memory requirements, or if OMP_NUM_THREADS>1.

#! Number of nodes and tasks per node allocated by SLURM (do not change):
numnodes=$SLURM_JOB_NUM_NODES
numtasks=$SLURM_NTASKS
mpi_tasks_per_node=$(echo "$SLURM_TASKS_PER_NODE" | sed -e  's/^\([0-9][0-9]*\).*$/\1/')
#! ############################################################
#! Modify the settings below to specify the application's environment, location 
#! and launch method:

#! Optionally modify the environment seen by the application
#! (note that SLURM reproduces the environment at submission irrespective of ~/.bashrc):
. /etc/profile.d/modules.sh                # Leave this line (enables the module command)
module load default-impi                   # REQUIRED - loads the basic environment
#! 

#! Insert additional module load commands after this line if needed:
module load intel/impi/4.0.3.008

#! Full path to application executable: 
#application=$1

#! Run options for the application:
options=

#! Work directory (i.e. where the job will run):
workdir="./"

#! Are you using OpenMP (NB this is unrelated to OpenMPI)? If so increase this
#! safe value to no more than 16:
export OMP_NUM_THREADS=1

#! Number of MPI tasks to be started by the application per node and in total (do not change):
np=$[${numnodes}*${mpi_tasks_per_node}]

#! The following variables define a sensible pinning strategy for Intel MPI tasks -
#! this should be suitable for both pure MPI and hybrid MPI/OpenMP jobs:
export I_MPI_PIN_DOMAIN=omp:compact # Domains are $OMP_NUM_THREADS cores in size
export I_MPI_PIN_ORDER=scatter # Adjacent domains have minimal sharing of caches/sockets
#! Notes:
#! 1. These variables influence Intel MPI only.
#! 2. Domains are non-overlapping sets of cores which map 1-1 to MPI tasks.
#! 3. I_MPI_PIN_PROCESSOR_LIST is ignored if I_MPI_PIN_DOMAIN is set.
#! 4. If MPI tasks perform better when sharing caches/sockets, try I_MPI_PIN_ORDER=compact.


#! Uncomment one choice for CMD below (add mpirun/mpiexec options if necessary):

#! Choose this for a MPI code (possibly using OpenMP) using Intel MPI.
CMD="mpirun -ppn $mpi_tasks_per_node -np $np $application $options infiles/infile-${cfg} > bumph/bumph-${cfg}.txt"

#! Choose this for a pure shared-memory OpenMP parallel program on a single node:
#! (OMP_NUM_THREADS threads will be created):
#CMD="$application $options"

#! Choose this for a MPI code (possibly using OpenMP) using OpenMPI:
#CMD="mpirun -npernode $mpi_tasks_per_node -np $np $application $options"

###############################################################
### You should not have to change anything below this line ####
###############################################################

cd $workdir
echo -e "Changed directory to `pwd`.\n"

JOBID=$SLURM_JOB_ID

echo -e "JobID: $JOBID\n======"
echo "Time: `date`"
echo "Running on master node: `hostname`"
echo "Current directory: `pwd`"

if [ "$SLURM_JOB_NODELIST" ]; then
        #! Create a machine file:
        export NODEFILE=`generate_pbs_nodefile`
        cat $NODEFILE | uniq > ./slurmfiles/machine.file.$JOBID
        echo -e "\nNodes allocated:\n================"
        echo `cat machine.file.$JOBID | sed -e 's/\..*$//g'`
fi

echo -e "\nnumtasks=$numtasks, numnodes=$numnodes, mpi_tasks_per_node=$mpi_tasks_per_node (OMP_NUM_THREADS=$OMP_NUM_THREADS)"

echo -e "\nExecuting command:\n==================\n$CMD\n"

run_milc
run_milc_convert

ulimit -s unlimited
run_nrqcd_parallel
wait

cleanup