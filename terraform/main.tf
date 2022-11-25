#Create compute infrastructure
module "compute" {
  source = "../terraform/modules/compute"

  security_group_name = module.security.security_group_id
  ec2_key_name        = module.security.key_name
  KMS_key_arn         = module.security.KMS_Key_Arn
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

# Create RDS functionality
module "rds" {
  source     = "../terraform/modules/rds"
  db_subnet  = data.aws_subnets.subnets.ids
  security_group = module.security.security_group_id
}