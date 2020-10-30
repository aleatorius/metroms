#!/bin/bash
#SBATCH --nodes=7 --ntasks-per-node=32 ##--qos=devel
##SBATCH --partition=normal
#SBATCH --time=03-12:29:59
#SBATCH --job-name=SA4
##SBATCH --mem-per-cpu=1000M
#SBATCH --account=nn9300k
##SBATCH --switches=1@24:00:00
#SBATCH -o slurm.%j.out # STDOUT
#SBATCH -e slurm.%j.err # STDERR
##SBATCH --exclude=c55-4

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    num='spam_006'
else
    num="spam_$1"
fi

WORK_PATH=/cluster/work/users/${USER}/SA4_${num}                              
echo $WORK_PATH
if [ ! -d "$WORK_PATH" ]; then
    mkdir $WORK_PATH
fi                                                                                       

datstamp=`date +%Y_%m_%d_%H_%M`
exec 1>${WORK_PATH}/intel_${num}.log_slurm_${datstamp} 2>&1


source $PWD/myenv_fram.bash
source $PWD/modules_fram_intel_2019.sh

module list



HOME_PATH=${PWD}
host_file=${HOME_PATH}/intel_slurm_${num}.hosts


scontrol show hostname $SLURM_JOB_NODELIST >  ${host_file}
##srun hostname -s | sort -u > $host_file
#
if [ ! -f ${host_file}_"slots" ]; then
        :
else
    mv ${host_file}_"slots" ${host_file}_"slots_old"
fi
# 29, nodes, 18 taskspernode, 8 slots first, 20 slots rest WORKS
counter=0
while read p; do
    if [ $counter -eq 0 ]; then
        echo ${p}":32" >> ${host_file}_"slots"
    else
        echo ${p}":32" >> ${host_file}_"slots"
    fi
        counter=$((counter+1))
done <$host_file


fromdir=/cluster/work/users/mitya/SA4_spam_005



for n in $fromdir/ocean_his*nc; do var="$n"; done                                                                               
#for n in $fromdir/ocean_avg*nc; do var_a="$n"; done           
echo $var "mitya 0"                                                              
cp $var $WORK_PATH/${var##*/}
file=${var##*/}
bas=${file%.nc}
base=${bas##*_}
if [[ "${base#*00}" != "$base" ]]; then
    num=${base#*00}
else
    num=${base#*0}
fi

sfile=${bas%$num}
newfile=$sfile$(($num+1))".nc"
echo $newfile
cp $var $WORK_PATH/$newfile
newfile=$sfile$(($num-1))".nc"
echo $newfile
cp $var $WORK_PATH/$newfile


cp -f  $fromdir/ocean_rst.nc $WORK_PATH/ocean_rst.nc 
cp -f $HOME_PATH/ice_in_fromini_2014_even_96_restart $WORK_PATH/ice_in
#cp -f $HOME_PATH/ice_in_fromrestart_2014_revised $WORK_PATH/ice_in
cp -f $HOME_PATH/roms.in_even_fromini_2014_128_restart $WORK_PATH/roms.in
cp -f $HOME_PATH/oceanM_even_7 $WORK_PATH/oceanM_intel
#cp -f $HOME_PATH/ice.restart_file $WORK_PATH/.



cp -f $fromdir/varinfo.dat $WORK_PATH/.
cp -f /cluster/shared/arcticfjord/input_data/s800_cice_processed_a4_mod/cice.kmt_svalbard.nc $WORK_PATH/cice.kmt.nc
cp -f /cluster/shared/arcticfjord/input_data/s800_cice_processed_a4_mod/cice.grid_svalbard.nc $WORK_PATH/cice.grid.nc
cp -f $fromdir/coupling.dat $WORK_PATH/.
cp $fromdir/ice.restart_file $WORK_PATH/.

cd $WORK_PATH

sed -i -e "s+WORKDIR+$WORK_PATH+g" $WORK_PATH/ice_in
sed -i -e "s+WORKDIR+$WORK_PATH+g" $WORK_PATH/roms.in
#sed -i -e "s+WORKDIR+$WORK_PATH+g" $WORK_PATH/ice.restart_file

if [ ! -f "oceanM_intel" ]; then
    echo "no execs"
fi

#export I_MPI_OFA_NUM_ADAPTERS=2
#export I_MPI_OFA_NUM_PORTS=1

#I_MPI_DEBUG=5 mpirun  -genv I_MPI_WAIT_MODE 1 -machinefile ${host_file}_slots  $WORK_PATH/oceanM_intel  $WORK_PATH/roms.in 
I_MPI_DEBUG=5 mpirun -genv I_MPI_FABRICS ofa:ofa -machinefile ${host_file}_slots  $WORK_PATH/oceanM_intel  $WORK_PATH/roms.in 
#I_MPI_DEBUG=5 mpirun -genv I_MPI_FABRICS ofa:ofa -machinefile  ${host_file}_slots  $WORK_PATH/oceanM_intel  $WORK_PATH/roms.in 
#mpirun -machinefile $HOME_PATH/slurm.hosts_slots -env I_MPI_FABRICS shm:tcp oceanM_intel  roms.in 
#mpirun -machinefile ${host_file}_slots -mca btl_openib_use_eager_rdma 0 -mca btl_openib_max_eager_rdma 0 -mca
#btl_openib_flags 1 $WORK_PATH/oceanM_intel  $WORK_PATH/roms.in 
#mpirun -machinefile ${host_file}_slots -env I_MPI_FABRICS shm:tcp $WORK_PATH/oceanM_intel  $WORK_PATH/roms.in 
#mpirun -machinefile ${host_file}_slots  $WORK_PATH/oceanM_intel  $WORK_PATH/roms.in 
#mpirun -machinefile ~/models/metroms/apps/S800/slurm.hosts_slots /cluster/work/users/$USER/tmproms/run/S800/oceanM_300_228_old  /cluster/work/users/$USER/tmproms/run/S800/roms.in 
#mpirun -machinefile ~/models/metroms/apps/S800/slurm.hosts_slots /cluster/work/users/$USER/tmproms/run/S800/oceanM_300_324  /cluster/work/users/$USER/tmproms/run/S800/roms.in_300_324 

