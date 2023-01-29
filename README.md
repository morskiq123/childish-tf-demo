# Autoscaled and loadbalanced EC2 instances with access to DynamoDB and S3

## What is this?

This is a terraform configuration that implements an autoscaling group that uses an application load balancer to create EC2 instances with `ubuntu 20.04` and `apache2` installed that have access to DynamoDB and S3. The instances use the latest 20.04 ubuntu image as a base and upload the `apache_install.sh` file found under the `asg` module as user data. This means that once the EC2 instance runs the script as part of it's initialization.

## Structure

The configuration is split across different modules, every module containing a `data.tf`, `outputs.tf`, `variables.tf` and `main.tf ` files. 

## How to run



## Variables 


## Diagram of the configuration


