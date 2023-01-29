provider "aws" {
  region = var.region
}

module "iam" {
  source = "./modules/iam"
  region = var.region
  app_name = var.app_name
}

module "networking" {
  source = "./modules/networking"
  app_name = var.app_name
  id_vpc = module.networking.id_vpc
}

module "sg" {
  source = "./modules/sg"
  app_name = var.app_name
  id_vpc = module.networking.id_vpc
}

module "asg" { 
  source = "./modules/asg"
  app_name = var.app_name
  id_vpc = module.networking.id_vpc
  id_subnets = module.networking.id_subnets
  id_sg = module.sg.id_sg
  app_asg_service_role = module.iam.app_asg_service_role
}

module "s3-dynamo-db"{
  source = "./modules/s3-dynamo-db"
  app_name = var.app_name
}