#!/bin/bash

#run an individual array job using BATCH_TASK_INDEX
#  rather than command line arguments
echo "-------------------------------"
echo "start @ "`date`

env

echo "@@---------------"
BATCH_TASK_INDEX=$JOB_COMPLETION_INDEX
echo "BATCH_TASK_INDEX=$BATCH_TASK_INDEX"
echo "BATCH_JOB_UID=$BATCH_JOB_UID"
echo "DATA_DIR=$DATA_DIR"

job_dir_prefix=Cu1_24_${BATCH_TASK_INDEX}
output_file=${BATCH_TASK_INDEX}.out
err_file=${BATCH_TASK_INDEX}.err
echo "job_dir_prefix=$job_dir_prefix"
echo "output_file=$output_file"
echo "err_file=$err_file"

env | sort
run_dir=$(mktemp -d --suffix="_$job_dir_prefix")
echo "run_dir=$run_dir"

#use a unique run directory
#  (primarily for VM-based runs)
cp -R $DATA_DIR/$job_dir_prefix/* $run_dir
cp $DATA_DIR/pseudos/* $run_dir
cd $run_dir
ls -l
echo "start pw.x"
echo "pw.x -in pwscf-single-step.in 1>$output_file 2>$err_file"
pw.x -in pwscf-single-step.in 1>$output_file 2>$err_file
echo "pw.x complete"

cp $output_file $DATA_DIR/$job_dir_prefix
cp $err_file $DATA_DIR/$job_dir_prefix
/bin/rm -rf $run_dir

echo "-------------------------------"
echo "done @ "`date`

									  
