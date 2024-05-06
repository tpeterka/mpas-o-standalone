#!/bin/bash

export SPACKENV=mpas
export YAML=$PWD/env.yaml

# create spack environment
echo "creating spack environment $SPACKENV"
spack env deactivate > /dev/null 2>&1
spack env remove -y $SPACKENV > /dev/null 2>&1
spack env create $SPACKENV $YAML

# activate environment
echo "activating spack environment"
spack env activate $SPACKENV

# spack develop netcdf-c@4.9+mpi
# spack add netcdf-c@4.9+mpi cflags='-g'
spack add netcdf-c@4.9+mpi

# spack develop mpas-o-scorpio@master+hdf5 build_type=Debug
spack add mpas-o-scorpio+hdf5

# install everything in environment
echo "installing dependencies in environment"
spack install

# reset the environment (workaround for spack behavior)
spack env deactivate
spack env activate $SPACKENV

# set build flags
echo "setting flags for building MPAS-Ocean"
export MPAS_EXTERNAL_LIBS=""
export MPAS_EXTERNAL_LIBS="${MPAS_EXTERNAL_LIBS} -lgomp"
export NETCDF=`spack location -i netcdf-c`
export NETCDFF=`spack location -i netcdf-fortran`
export PNETCDF=`spack location -i parallel-netcdf`
export PIO=`spack location -i mpas-o-scorpio`
export HDF5=`spack location -i hdf5`
export USE_PIO2=true
export OPENMP=true
export HDF5_USE_FILE_LOCKING=FALSE
export MPAS_SHELL=/bin/bash
export CORE=ocean
export SHAREDLIB=true

# set LD_LIBRARY_PATH
echo "setting flags for running MPAS-Ocean"
export LD_LIBRARY_PATH=$NETCDF/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$NETCDFF/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$HDF5/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$PIO/lib:$LD_LIBRARY_PATH

# give openMP 1 core for now to prevent using all cores for threading
# could set a more reasonable number to distribute cores between mpi + openMP
export OMP_NUM_THREADS=1

