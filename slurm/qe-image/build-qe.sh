#!/bin/sh

source /opt/intel/oneapi/setvars.sh
cd /tmp
#pull QE source code from existing location
#or download QE from https://gitlab.com/QEF/q-e/-/archive/qe-7.3.1/q-e-qe-7.3.1.tar.gz
gcloud storage cp gs://<bucket-name>/qe-7.3.1-ReleasePack.tar.gz .
tar zxvf qe-7.3.1-ReleasePack.tar.gz
cd qe-7.3.1
#potentially disable openmp and mpi for benchmarking
#./configure --disable-openmp --disable-parallel
./configure
make pw
sudo make install

