#!/bin/bash 
#### For the distributed memory versions of the code that we use at CHPC, mpiprocs should be equal to ncpus
#### Here we have selected the maximum resources available to a regular CHPC user
####  Obviously provide your own project identifier
#### For your own benefit, try to estimate a realistic walltime request.  Over-estimating the 
#### wallclock requirement interferes with efficient scheduling, will delay the launch of the job,
#### and ties up more of your CPU-time allocation untill the job has finished.
#########
#PBS -N Kenneth_Vortex
#PBS -l nodes=5:ppn=28
#PBS -q batch
#PBS -j oe
#PBS -l walltime=168:00:00
##PBS -m abe

### Same as PBS -j oe above
##PBS -o /public/home/Benkeke3/Aston/WRF4/WRF/test/em_real/stdout
##PBS -e /public/home/Benkeke3/Aston/WRF4/WRF/test/em_real/stderr

### Source the WRF4 environment
source /usr/share/Modules/init/bash
module load intel/2017
module load impi/2017
module load netcdf/4.5.0

#cd $PBS_O_WORKDIR
###nprocs=`cat $PBS_NODEFILE | wc -l`
###mpirun -np $nprocs -machinefile $PBS_NODEFILE ./wrf.exe

# Set the stack size unlimited for the intel compiler
ulimit -s unlimited

##### Running commands
# Set PBS_JOBDIR to where YOUR simulation will be run
export PBS_JOBDIR=/public/home/Benkeke3/Aston/WRF4/WRF/test/em_real

# First though, change to YOUR WPS directory
export WPS_DIR=/public/home/Benkeke3/Aston/WRF4/WPS
cd $WPS_DIR
# Clean the directory of old files
rm FILE*
rm GRIB*
rm geo_em*
rm met_em*
rm metgrid.log ungrib.log geogrid.log
rm Vtable
# Run geogrid.exe
./geogrid.exe &> geogrid.out

# Link to the grib files, obviously use the location of YOUR grib files
./link_grib.csh /public/home/Benkeke3/Aston/WRF2019/DATA_4/GFS_4_APRIL/gfsanl_4_201904*
# Link Vtable
ln -sf ungrib/Variable_Tables/Vtable.GFS Vtable
# Run ungrib.exe
./ungrib.exe &> ungrib.out
# Run metgrid.exe
./metgrid.exe &> metgrid.out

# Now change to the WRF main job directory
cd $PBS_JOBDIR
rm met_em*
# Link the met_em* data files into this directory
ln -sf $WPS_DIR/met_em* ./
###################################
# Figure out how many processes to use for wrf.exe
##nproc=`cat $PBS_NODEFILE | wc -l`

######## Now figure out how many nodes are being used
##cat $PBS_NODEFILE | sort -u > hosts
# Number of nodes to be used for real.exe
##nnodes=`cat hosts | wc -l`

# Run real.exe with one process per node
##exe=$WRFDIR/real.exe
##mpirun -np $nnodes -machinefile hosts $exe &> real.out

# Run wrf.exe with the full number of processes
##exe=$WRFDIR/wrf.exe
##mpirun -np $nproc $exe &> wrf.out

############################################
#cd $PBS_O_WORKDIR
nprocs=`cat $PBS_NODEFILE | wc -l`
mpirun -np $nprocs -machinefile $PBS_NODEFILE ./real.exe &> rea1l.out

#cd $PBS_O_WORKDIR
nprocs=`cat $PBS_NODEFILE | wc -l`
mpirun -np $nprocs -machinefile $PBS_NODEFILE ./tc.exe &> tc.out
