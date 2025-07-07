# Running Quantum Espresso jobs using Google Batch and a custom container

This document describes how to run a Quantum Espresso array job using Google Batch and a custom container.

## 1. Create the Docker container (optional)

The repo contains a simple Dockerfile for building the custon container. Simply follow the usual steps to build a container and push it to Docker hub or another container registry such as [Google Cloud's Artifact Registry[ (https://cloud.google.com/artifact-registry/docs.

## 2. Create a bucket for the data

We are using a GCS bucket to store the input and output data. First create a new bucket (replace <GCS Bucket> with a valid bucket name):

```
gcloud storage buckets create gs://<GCS Bucket>
```

## 3. Stage the test data

Mount the bucket (in Cloudshell or on a VM) to be able to stage the test data:

```
mkdir tmpdir
gcsfuse --implicit-dirs <GCS Bucket> tmpdir
```

and then untar the data set archive and copy the run script

```
cd tmpdir
tar zxvf ../../../../dataset/Cu1-testcase.tgz
cp ../run-Cu1.sh .
cd ..
```

## 4. Edit the Google Batch config

Edit the batch config [qe-array.json](https://github.com/veyrich/qe-on-gcp/blob/main/batch/container/run/qe-array.json) to use the actual bucketname, i.e. replace `<GCS Bucket>` with the name of the bucket created above:

```
"volumes": [
  {
  "gcs": {
     "remotePath": "<GCS Bucket>"
         },
     "mountPath": "/tmp/data"
  }
```

and optionally change the taskcount to "1" for testing, i.e. only run one job:

```
"taskCount":"1",
"parallelism":"1",
```

## 5. Submit the batch job

SUbmit using the helper script:

```
./submit-job.sh qe-array.json
```

and monitor the job's status in the Google Cloud console. Cu1_24_0 should take approx. 30 mins to complete
