variable "id_sg" {}

variable "id_vpc" {}

variable "id_subnets" {}

variable "app_name" {}

variable "app_asg_service_role" {}

variable "instance_type" {
    #description = "Size of the instance (t2.micro, t3.medium, etc.)"
    default = "t2.micro"
}

variable "lt_drive_size"{
    description = "How much size should be allocated to the EC2 instances"
    type = number
    default = 8
}

variable "lb_port" {
    description = "The port that we will redirect traffic to"
    type = number
    default = 80
    # for demo purposes, change this and lb_protocol as well if you want
    # to change the actual port, i.e., 443 for lb_port and lb_ protocol to "HTTPS"
}  

variable "lb_protocol" {
    description = "The protocol that we're using"
    type = string
    default = "HTTP"
}  

variable "min_size" {
    description = "Minimum number of instances"
    type = number
    default = 2    
}

variable "max_size" {
    description = "Max number of instances"
    type = number
    default = 5
}

variable "desired_size"{
    description = "Desired capacity, i.e., how much they should be w/o scaling"
    type = number
    default = 2
}

variable "scaling_cooldown"{
    description = "How much seconds to wait before another instance is launched for scaling purposes"
    type = number
    default = 300
}

variable "cpu_threshold_up"{
    description = "What CPU utilization will need to be reached in order to scale up"
    type = number
    default = 30 
}

variable "cpu_threshold_down"{
    description = "What CPU utilization will need to be reached in order to scale down"
    type = number
    default = 5 
}