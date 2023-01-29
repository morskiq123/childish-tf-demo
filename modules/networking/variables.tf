variable "id_vpc" {}

variable "app_name" {}

variable "public_subnets_list" {
    description = "A list of the CIDR blocks for the public subnets"
    type = list
    default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
    description = "A list of the availability zones in which the subnets will be created"
    type = list
    default = ["eu-central-1a", "eu-central-1b"]
}

variable "just_count" {
    description = "A variable for the amount of resources that need to be created"
    default = 2
}

variable "vpc_cidr" {
    description = "The CIDR block for the VPC"
    default = "10.0.0.0/16"
}

variable "route_cidr_block" {
    description = "The CIDR block for the public and private route tables"
    default = "0.0.0.0/0"
}