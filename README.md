# Autoscaled and load balanced EC2 instances with access to DynamoDB and S3

## TODO

 ..* Update the diagram
 ..* Fix the dynamoDB deployment
 ..* Fix the userdata apache_install.sh change thew webpage correctly
 ..* Generate terraform-docs 

## What is this?

This is a terraform configuration that implements an autoscaling group that uses an application load balancer to create EC2 instances with `ubuntu 20.04` and `apache2` installed that have access to DynamoDB and S3. The instances use the latest 20.04 ubuntu image as a base and upload the `apache_install.sh` file found under the `asg` module as user data. This means that once the EC2 instance runs the script as part of it's initialization.

## Structure
```bash
│   main.tf
│   outputs.tf
│   variables.tf
│   
└───modules
    ├───asg
    │       apache_install.sh    
    │       data.tf
    │       main.tf
    │       outputs.tf
    │       variables.tf
    │
    ├───iam
    │       data.tf
    │       main.tf
    │       outputs.tf
    │       variables.tf
    │
    ├───networking
    │       data.tf
    │       main.tf
    │       outputs.tf
    │       variables.tf
    │
    ├───s3-dynamo-db
    │       data.tf
    │       main.tf
    │       outputs.tf
    │       variables.tf
    │
    └───sg
            data.tf
            main.tf
            outputs.tf
            variables.tf

```
The configuration is split across different modules, every module containing a `data.tf`, `outputs.tf`, `variables.tf` and `main.tf ` files. 

## How to run

1. Create a user or role that Terraform will use in order to create the resource.
2. Create an access key and configure the AWS CLI to use it. 
3. In the root of the directory run `terraform init`. **NOTE: No remote state of any kind has been included in this configuration!** Afterwards, run `terraform plan` to see the changes that will be created and finally run `terraform apply`. Enter yes when it prompts you to do so.
4. When the resources are built, at the end you should receive an URL. **If you are using the default configuration, make sure that you are connecting to port 80 / using HTTP to connect to the URL! Your browser might be configured to reject HTTP connections** You might need to wait a minute or two until the EC2 instances are initialized. 
5. If the script has been ran successfully, you should be met with an EC2 instance that shows you the default apache2 for ubuntu html page.

**Again, the EC2 have access to the S3 bucket and the DynamoDB, you only need to include your raw HTML/CSS/JS files in the `apache_install.sh` file, so that when you run the configuration they are instsalled along with the apache_install.sh. No SSH connectivity has been provided with this configuration.**

## Variables 

All variables have a description and type provided in all of the `variables.tf` files. **If the variable is declared like this for example** <br>
`variable app_name{}`
**This means that the variable is waiting input from somewhere else. In the case of this configuration, the value is passed through the `main.tf` file in the root directory.**

In this current build, you would have to go in and change the variables by hand, **as there is no .tfvars file currently implemented.**

## Diagram of the configuration

![alt text](https://github.com/morskiq123/childish-tf-demo/blob/master/Diagram.jpg "Diagram.jpg")
