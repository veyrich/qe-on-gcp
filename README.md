# Quantum Espresso on Google Cloud

## Introduction

This tutorial describes several ways to run a traditional scientific code on [Google Cloud](https://cloud.google.com/). We use [Quantum Espresso](https://www.quantum-espresso.org/) as an example but the approach outlined here should be fairly easy to extend to other codes that operate similarly

The tutorial covers running what is often called an “array job”, i.e. a set of similar jobs that operate similarly but on different data sets. The major advantage of this approach is that one can run a large data set by submitting a single array job and maintaining that job as a single unit rather than having to submit a potentially large number of independent jobs. For details on how this is done see for example the [Slurm documentation](https://slurm.schedmd.com/job_array.html). Other job execution environments offer similar capabilities.

The job execution environments were are considering include:

* Slurm deployed via [Cluster Toolkit](https://github.com/GoogleCloudPlatform/cluster-toolkit)  
* [Google Batch](https://cloud.google.com/batch?hl=en) (both VM and container based)  
* [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine?hl=en)

