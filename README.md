# Appsbroker exercise

## Overview

I have attempted to include multiple technologies to demonstration my familiarity with core concepts including:
* IaC - Terraform
* Configuration Management - Ansible
* Pipelines - Jenkins declarative pipeline
* Docker - Container cloud build and deployment to a google container registry
* Resource - MySQL Cloud SQL, GKE, Jenkins compute, Gitlab compute
* Application - a simple PHP application utilizing a MySQL resource

## Network Diagram

https://lucid.app/lucidchart/3b8eeb04-f534-4b42-aaa0-6bcd5d429e66/view?page=0_0&invitationId=inv_84162f8d-1a8b-42c5-8723-421329e5d9a0#

## Secrets & GCP service account

Secrets are managed centrally in the GCP Secret Manager or Jenkins (For service accounts).

Application deployments obtain configuration directly from the GCP Secret Manager.

The GCP IAM service account credentials are stored in the Jenkins credentials manager and pulled in via the pipelines where necessary.

### List of all secrets used in project

* ENV-cloudsql-replicator
* ENV-cloudsql-ro
* ENV-cloudsql-rw
* ENV-gke-password
* ENV-gke-client-certificate
* ENV-gke-client-key
* ENV-gke-cluster-ca-certificate

### Observations

There are many different credential stores available. It could be preferable to take a platform agnostic approach instead. For simplicity, I chose Google Secret Manager.

## Jenkins CI/CD pipelines

My goal in this exercise was to use Jenkins pipelines for build/release/test/deployment stages.

Unfortunately I ran out of time to implement a test pipeline stage.

Additionally I did not integrate Jenkins and Gitlab so there are not build triggers or other nice to haves.

### Observations and Limitations

I have not implemented stage authorization steps for the purpose of this exercise.

Under an AGILE environment using Jira, such authorization steps could be tied directly to Jira tasks via the JIRA api whereby each jenkins pipeline stage checks the status of a corresponding JIRA task before proceeding.

## Terraform

IaC in this exercise is structured in multiple layers by environment.

Each environment has the following 3 layers:
* network layer - All network provisioning including VPC/Subnet, firewall, and routing
* Resource layer - Database (MySQL), Kubernetes (GKE), Gitlab (Compute), Jenkins (Compute)
* Application layer - Simple Kubernetes deployment of Nginx (type LoadBalancer) and PHP (FPM)

This is a fairly common way of structuring terraform configuration but there are many alternate fine grained, parameterised approaches.

## Ansible

I have chosen to provision Gitlab and Jenkins via raw compute resources rather than managed cloud solutions to allow the use of ansible and demonstrate basic configuration management.

Ansible is structured to use simple roles and dependencies to configure VMs with a top level site.yml tp include roles based on host or hostgroup.

This is a common approach to large projects that scales well and cleanly structures the configuration.

### Observations and Limitations

Due to time constraints I did not tie the Provisioning into the Configuration so terraform does not invoke Ansible directly to configure the Gitlab and Jenkins instances.

I am aware that Ansible is also able to perform cloud provisioning but prefer the separation of IaC and configuration management. Terraform still remains a more capable tool with better isolation of team responsibilities.

I did not have time add a dynamic GCP inventory script.

## Docker

I build custom PHP (FPM) and Nginx container deployed to a private GCP repository using the GCP cloud build service.

## Application

A very simple PHP v7.4 HTTP 'Hello World' service

### Observations

I ran out of time but I was planning to build a more elaborate PHP example along with readiness and liveness K8s probes.

## Scripting

Although I did not demonstrate coding skills via PHP I did include a bash cloud_build.sh script for building docker images via the Google Cloud Build service.

I hope this is enough to demonstrate some basic coding ability.

## Many missing parts

There are so many missing parts to this exercise that would make it a suitable production environment, not least:

* Lack of monitoring (ELK, prometheous, graphana, stackdriver dashboards,...)
* Lack of central logging (ELK)
* Low spec of compute resources
* Missing redundancy and backups
* Missing Cloud Armor and LB configuration including security policies
* No Secure VPN access
* No High Availability cross zone configuration (Although GKE does this out of the box?)
* No network isolation of resources, applications, and devops resources.
* Missing configuration of the Cloud SQL replicas
* Lack of auto-scaling of the Nginx/PHP FPM services
* Lack of auto-healing capabilities (liveness, readiness probes)
* General production ready configuration of the various services

## Challenges faced during this exercise

The usual suspect(s):

* Error: Error waiting for instance to create: The zone 'projects/appsbroker-356110/zones/us-central1-b' does not have enough resources available to fulfill the request.  Try a different zone, or try again later.
* Error: Error waiting for instance to create: The zone 'projects/appsbroker-356110/zones/europe-west2-a' does not have enough resources available to fulfill the request.  Try a different zone, or try again later.
* Error: Error waiting for instance to create: The zone 'projects/appsbroker-356110/zones/europe-west2-b' does not have enough resources available to fulfill the request.  Try a different zone, or try again later.
* Error: Error waiting for instance to create: The zone 'projects/appsbroker-356110/zones/europe-west2-c' does not have enough resources available to fulfill the request.  Try a different zone, or try again later.
* Did I mention usage quotas?
