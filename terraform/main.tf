#Create compute infrastructure
module "compute" {
  source = "../terraform/modules/compute"

  security_group_name = module.security.security_group_id
  ec2_key_name        = module.security.key_name
}

#Call security module to create keys and security groups
module "security" {
  source = "../terraform/modules/security"
  vpc_id = data.aws_vpc.main.id
}

#Create EFS resources
module "ebs" {
  source     = "../terraform/modules/ebs"
  sec_grp_id = module.security.security_group_id
}