#!/bin/bash 
#### For the distributed memory versions of the code that we use at CHPC, mpiprocs should be equal to ncpus
#### Here we have selected the maximum resources available to a regular CHPC user
####  Obviously provide your own project identifier
#### For your own benefit, try to estimate a realistic walltime request.  Over-estimating the 
#### wallclock requirement interferes with efficient scheduling, will delay the launch of the job,
#### and ties up more of your CPU-time allocation untill the job has finished.
#PBS -l select=10:ncpus=24:mpiprocs=24 -q normal -P TEST1234
#PBS -l walltime=3:00:00
#PBS -o /public/home/aston20/WRF/test/em_real/stdout
#PBS -e /public/home/aston20/WRF/test/em_real/stderr
#PBS -m abe
#PBS -M Aston_WRF  
### Source the WRF-4.1.1 environment:
export WRFDIR=/public/home/aston20/WRF/test/ ######/public/software/mpi/intelmpi/5.0.2.044
###. $WRFDIR/setWRF
# Set the stack size unlimited for the intel compiler
ulimit -s unlimited
##### Running commands
# Set PBS_JOBDIR to where YOUR simulation will be run
export PBS_JOBDIR=/public/home/aston20/WRF/test/em_real
# First though, change to YOUR WPS directory
export WPS_DIR=/public/home/aston20/WPS/
cd $WPS_DIR
# Clean the directory of old files
rm FILE*
rm GRIB*
rm geo_em*
rm met_em*
rm metgrid.log ungrib.log geogrid.log
rm Vtable
# Run geogrid.exe
geogrid.exe &> geogrid.out
# Link to the grib files, obviously use the location of YOUR grib files
./link_grib.csh ~/GFSANL_March/gfsanl_3_2019030*
# Link Vtable
ln -sf ungrib/Variable_Tables/Vtable.GFS Vtable
# Run ungrib.exe
ungrib.exe &> ungrib.out
# Run metgrid.exe
metgrid.exe &> metgrid.out
# Now change to the WRF main job directory
cd $PBS_JOBDIR
# Link the met_em* data files into this directory
ln -sf $WPS_DIR/met_em* ./
# Figure out how many processes to use for wrf.exe
nproc=`cat $PBS_NODEFILE | wc -l`
# Now figure out how many nodes are being used
cat $PBS_NODEFILE | sort -u > hosts
# Number of nodes to be used for real.exe
nnodes=`cat hosts | wc -l`
# Run real.exe with one process per node
exe=$WRFDIR/real.exe
mpirun -np $nnodes -machinefile hosts $exe &> real.out
# Run wrf.exe with the full number of processes
exe=$WRFDIR/wrf.exe
mpirun -np $nproc $exe &> wrf.out