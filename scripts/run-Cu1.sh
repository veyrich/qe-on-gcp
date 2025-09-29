#!/bin/bash

echo "-------------------------------"
echo "start @ "`date`

JOB_INDEX=""

if [[ -n "$1" ]]; then
    JOB_INDEX="$1"
elif [[ -n "$SLURM_ARRAY_TASK_ID" ]]; then
    JOB_INDEX="$SLURM_ARRAY_TASK_ID"
    echo "SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID"
elif [[ -n "$BATCH_TASK_INDEX" ]]; then
    JOB_INDEX="$BATCH_TASK_INDEX"
    echo "BATCH_TASK_INDEX=$BATCH_TASK_INDEX"
    echo "BATCH_JOB_UID=$BATCH_JOB_UID"
elif [[ -n "$JOB_COMPLETION_INDEX" ]]; then
    JOB_INDEX="$JOB_COMPLETION_INDEX"
    echo "JOB_COMPLETION_INDEX: $JOB_COMPLETION_INDEX"
else
    JOB_INDEX="0"
    echo "WARNING: No argument provided or environment variable not set."
    exit 1
fi

echo "--- JOB_INDEX Assignment Complete ---"
echo "JOB_INDEX: $JOB_INDEX"

echo "DATA_DIR=$DATA_DIR"

job_dir_prefix=Cu1_24_${JOB_INDEX}
output_file=${JOB_INDEX}.out
err_file=${JOB_INDEX}.err
echo "job_dir_prefix=$job_dir_prefix"
echo "output_file=$output_file"
echo "err_file=$err_file"

#env | sort
run_dir=$(mktemp -d --suffix="_$job_dir_prefix")
echo "run_dir=$run_dir"

#use a unique run directory
#  (primarily for VM-based runs)
cp -R $DATA_DIR/$job_dir_prefix/* $run_dir
cp $DATA_DIR/pseudos/* $run_dir
cd $run_dir
ls -l
echo "start pw.x"
pw.x -in pwscf-single-step.in 1>$output_file 2>$err_file
echo "pw.x complete"

cp $output_file $DATA_DIR/$job_dir_prefix
cp $err_file $DATA_DIR/$job_dir_prefix
/bin/rm -rf $run_dir

echo "-------------------------------"
echo "done @ "`date`

