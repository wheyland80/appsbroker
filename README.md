# Appsbroker exercise

## Overview

I have attempted to include multiple technologies to demonstration my familiarity with core concepts including:
* IaC - terraform
* Configuration Management - Ansible
* Pipelines - Jenkins declarative pipeline
* Docker - Container cloud build and deployment to a google container registry
* Resource - A single node MySQL instance
* Application - a simple PHP application utilizing a MySQL resource

## Secrets & GCP service account

Secrets are managed centrally in the GCP Secret Manager. Jenkins, Terraform, and ansible all integrate with the GCP Secret Manager to obtain secrets during provisioning and configuration management.

Application deployments obtain configuration directly from the GCP Secret Manager.

The GCP IAM service account credentials are stored in the Jenkins credentials manager and pulled in via the pipelines where necessary.

### List of all secrets used and corresponding labels

### Observations

There are many different credential stores available. It could be preferable to take a platform agnostic approach instead. For simplicity, I chose Google Secret Manager.

## CI/CD pipeline

In this exercise I use Jenkins pipelines for build/release/test/deployment stages.

### Observations and Limitations

I have not implemented stage authorization steps for the purpose of this exercise.

Under an AGILE environment using Jira, such authorization steps could be tied directly to Jira tasks via the JIRA api whereby each jenkins pipeline stage checks the status of a corresponding JIRA task before proceeding.

## Terraform

IaC in this exercise is structured in multiple layers by environment.

Each environment has the following 3 layers:
* network layer - All network provisioning including VPC/Subnet, firewall, and routing
* Resource layer - Database (MySQL)
* Application layer - A very simple PHP application.

This is a fairly common way of structuring terraform configuration but there are many alternate fine grained, parameterised approaches.

## Ansible

I have chosen to provision raw compute resources rather than managed cloud solutions to allow the use of ansible and demonstrate configuration management.

Ansible is structured to use simple roles and dependencies to configure VMs with a top level site.yml tp include roles based on host or hostgroup.

This is a common approach to large projects that scales well and cleanly structures the configuration.

### Observations and Limitations

I am aware that Ansible is also able to perform cloud provisioning but prefer the separation of IaC and configuration management. Terraform still remains a more capable tool with better isolation of team responsibilities.

## Docker

I build a custom PHP container and MySQL container deployed to a private GCP repository using the GCP cloud build service.

## Application

A very simple PHP v7.4 HTTP service and MySQL database