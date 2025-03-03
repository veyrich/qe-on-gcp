#!/bin/sh

source /opt/intel/oneapi/setvars.sh
cd /tmp
gcloud storage cp gs://volkere-mines-demo/qe-7.3.1-ReleasePack.tar.gz .
tar zxvf qe-7.3.1-ReleasePack.tar.gz
cd qe-7.3.1
./configure --disable-openmp --disable-parallel
make pw
sudo make install

