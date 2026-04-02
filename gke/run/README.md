# Quantum Espresso on GKE

## Prepare the container

Use the container mentioned in the provided manifest or prepare your own container (this [Dockerfile](https://github.com/veyrich/qe-on-gcp/tree/main/batch/container/qe-container) can serve as a starting point).

## Create an autopilot cluster

Use the Google Cloud console ([console.cloud.google.com](http://console.cloud.google.com)) or gcloud to create a GKE Autopilot cluster.

## Install kubectl

Depending on your installation use one of the two comamnds below to install kubectl:

`gcloud components install kubectl`

`gcloud components install gke-gcloud-auth-plugin`

OR

`sudo apt-get install kubectl`

`sudo apt-get install google-cloud-cli-gke-gcloud-auth-plugin`

For details see ([this document](https://docs.cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl)).

## Get credentials

`gcloud container clusters get-credentials <cluster-name> --region <region>`

## Create a bucket to hold the data set

`gcloud storage buckets create gs://<bucket-name> --location=<region> --pap --enable-hierarchical-namespace --uniform-bucket-level-access`

## Grant permissions on the bucket to the service account

Verify that the default service account exists

`kubectl get serviceaccounts`

```
NAME      SECRETS   AGE  
default   0         20h
```

Assign the required permissions:

```
gcloud storage buckets add-iam-policy-binding gs://<bucket-name> \`  
    `--member` `"principal://iam.googleapis.com/projects/<project-number>/locations/global/workloadIdentityPools/<project-id>.svc.id.goog/subject/ns/default/sa/default" \`  
    `--role roles/storage.objectUser`
```

For more information, see [Authenticate to Google Cloud APIs from GKE workloads](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity#verify).

## Download and prepare the data set

Clone the [repo](https://github.com/veyrich/qe-on-gcp) for the demo via:

`git clone https://github.com/veyrich/qe-on-gcp.git`

Mount the GCS bucket via gcsfuse and prepare the dataset and run script:

```shell
cd qe-on-gcp/gke/run/
mkdir mnt
gcsfuse --implicit-dirs <bucket-name> mnt
cd mnt
mkdir dataset
cd dataset
tar zxvf ../../../../dataset/Cu1-testcase.tgz 
cd ..
cp ../../../scripts/run-Cu1.sh .
cd ..

```

Edit bucketName in qe-job.yaml, i.e. this section:

```
- name: qe
  csi:
    driver: gcsfuse.csi.storage.gke.io
    volumeAttributes:
      bucketName: <bucketname>
      mountOptions: "implicit-dirs"
```

## Submit the job 

Optionally change the job completion / parallelism settings. For testing start with:

```
completions: 1  
parallelism: 1
```

To run all jobs, change this to:

```
completions: 50  
parallelism: 10
```

Which will run all 50 jobs for the input data set with up to 10 jobs running simultaneously.

`kubectl create -f qe-job.yaml`

## Monitor the job

Monitor the progress of the job via:

`kubectl get jobs; kubectl get pods`

```
NAME       STATUS    COMPLETIONS   DURATION   AGE  
qe-ws42d   Running   0/1           6m16s      6m16s  
NAME               READY   STATUS    RESTARTS   AGE  
qe-ws42d-0-2k5v9   2/2     Running   0          6m17s
```

With completions set to 10:

`kubectl get jobs; kubectl get pods`

```
You will seeing something similar to the below:

NAME       STATUS    COMPLETIONS   DURATION   AGE  
qe-xl6sk   Running   0/10          8s         8s

NAME               READY   STATUS    RESTARTS   AGE  
qe-xl6sk-0-b86z7   2/2     Running   0          8s  
qe-xl6sk-1-6kmhg   0/2     Pending   0          8s  
qe-xl6sk-2-kn5g7   0/2     Pending   0          8s  
qe-xl6sk-3-l5rkw   0/2     Pending   0          8s  
qe-xl6sk-4-xzdgh   0/2     Pending   0          8s
...
```

The pod naming pattern is fairly straightforward:

qe-xl6sk-0-b86z7 in the above breaks down into:

\<job basename\>-\<random job suffix\>-\<job completion index\>-\<random pod suffix\>

To list the pod for a given job completion index run:

`kubectl get pods -l 'batch.kubernetes.io/job-completion-index=4'`

In a scenario where multiple jobs are running use:

`kubectl get pods -l batch.kubernetes.io/job-completion-index=4,job-name=qe-xl6sk`

To get the logs for a given pod use the usual k8s commands, e.g.:

`kubectl logs qe-xl6sk-4-xzdgh`

As individual jobs/pods complete the output will look similar to the following:

`kubectl get jobs ; kubectl get pods`

```
NAME       STATUS    COMPLETIONS   DURATION   AGE  
qe-xl6sk   Running   4/10          27m        27m

NAME               READY   STATUS      RESTARTS   AGE  
qe-xl6sk-0-b86z7   0/2     Completed   0          27m  
qe-xl6sk-1-6kmhg   2/2     Running     0          27m  
qe-xl6sk-2-kn5g7   0/2     Completed   0          27m  
qe-xl6sk-3-l5rkw   0/2     Completed   0          27m  
qe-xl6sk-4-xzdgh   0/2     Completed   0          27m  
qe-xl6sk-5-vm2h5   2/2     Running     0          13m  
qe-xl6sk-6-hr6jb   2/2     Running     0          6m10s  
qe-xl6sk-7-t8b54   2/2     Running     0          3m48s  
qe-xl6sk-8-2gb52   2/2     Running     0          41s  
...
```
