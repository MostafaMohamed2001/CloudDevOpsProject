
provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"

  vpc_cidr = var.vpc_cidr

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  
  acl_ingress =var.acl_ingress
  acl_egress  = var.acl_egress

}

module "server" {
  source = "./modules/server"

  security_group_name = var.security_group_name
  vpc_id              = module.network.vpc_id

  ingress_rules = var.ingress_rules

  key_name        = var.key_name
  public_key_path = var.public_key_path
  instance_type   = var.instance_type

  subnet_id = module.network.public_subnet_ids["public_1"]
}
