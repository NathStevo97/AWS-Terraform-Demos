# EKS_Practice

A small set of Terraform files to deploy an EKS cluster on AWS.

Prerequisites:


Terraform Installed - https://learn.hashicorp.com/tutorials/terraform/install-cli


Install and Configure AWS CLI - https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html

Connect to the EKS Cluster:

```bash
aws eks --region region update-kubeconfig --name cluster_name
```
