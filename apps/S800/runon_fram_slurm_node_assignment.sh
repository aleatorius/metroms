#!/bin/bash
#SBATCH --nodes=40
#SBATCH --ntasks-per-node=15
#SBATCH --priority=100000
##SBATCH --nodes=25
#SBATCH --partition=multinode
##SBATCH --partition=exclusive
##SBATCH --ntasks=400
##SBATCH --qos=devel
#SBATCH --time=03-00:00:00
#SBATCH --job-name=S800_slurm
##SBATCH --mem=32000
##SBATCH --mem-per-cpu=1800MB
#SBATCH --exclude c55-6,c9-4,c44-3,c11-2
##SBATCH --exclusive
#SBATCH --mem-per-cpu=2012

datstamp=`date +%Y_%m_%d_%H_%M`
exec 1>/global/work/$USER/tmproms/run/S800/run.log_slurm_${datstamp} 2>&1

export PYTHONPATH=/global/home/$USER/models/metroms/apps/common/python/
export METROMS_BASEDIR=$HOME
export METROMS_MYHOST=vilje
export METROMS_TMPDIR=/global/work/$USER
export LD_LIBRARY_PATH=/global/home/pduarte/symbioses-npi/modules/ecodynamo/ecolib:$LD_LIBRARY_PATH
source ~/models/metroms/apps/myenv.bash
#source ~/models/metroms/apps/modules.sh
echo 'Before module load'
module load gold/2.1.5.0 StdEnv intel/13.0 netCDF/4.2.1.1-intel-13.0 OpenMPI/1.6.2-intel-13.0 Python/2.7.3
echo 'After module load'
# Load modules needed
#module purge
#module load gold
#module load StdEnv
#module load intel/13.0
#module load Miniconda2 netCDF/4.2.1.1-intel-13.0 OpenMPI/1.6.2-intel-13.0
#source activate /home/hdj002/.conda/envs/python_conda
#module list
#echo test test EKKO


cd /home/$USER/models/metroms/apps/S800
cp include/s800.h $METROMS_TMPDIR/tmproms/run/S800/s800.h_${datstamp}

HOME_PATH=/home/$USER/models/metroms/apps/S800
host_file=${HOME_PATH}/slurm.hosts

srun hostname -s | sort -u > $host_file
#
if [ ! -f ${host_file}_"slots" ]; then
        :
        else
        mv ${host_file}_"slots" ${host_file}_"slots_old"
        fi
# 29, nodes, 18 taskspernode, 8 slots first, 20 slots rest WORKS
counter=0
while read p; do
        if [ "$counter" == "0" ]; then
            echo ${p}" slots=15" >> ${host_file}_"slots"
                else
            echo ${p}" slots=15" >> ${host_file}_"slots"
                fi
            counter=$((counter+1))
            done <$host_file
echo 'Before phyton call'
python S800_cpkg.py
