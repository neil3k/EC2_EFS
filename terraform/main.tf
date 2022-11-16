#Create compute infrastructure
module "compute" {
  source = "../terraform/modules/compute"

  security_group_name = module.security.security_group_id
  ec2_key_name        = module.security.key_name
  efs_id              = module.efs.efs_file_system_id
  efs_dns             = module.efs.efs_file_system_dns
}

#Call security module to create keys and security groups
module "security" {
  source = "../terraform/modules/security"
  vpc_id = data.aws_vpc.main.id
}

#Create EFS resources
module "efs" {
  source     = "../terraform/modules/efs"
  sec_grp_id = module.security.security_group_id
}