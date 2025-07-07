#!/bin/sh

#submit a Batch job / config (w/o external IP addresses)
input_config=$1
echo "submitting Batch job using input config: $input_config"
gcloud batch jobs submit \
       --no-external-ip-address \
       --network global/networks/default \
       --subnetwork regions/us-central1/subnetworks/default \
       --location=us-central1 \
       --config $input_config
