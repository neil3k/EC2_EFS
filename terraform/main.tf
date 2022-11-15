#Create dynamodb table for locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

#Create compute infrastructure
module "compute" {
  source = "../terraform/modules/compute"

  mount_id            = module.efs.mount_target_mound
  security_group_name = module.security.security_group_id
  ec2_key_name        = module.security.key_name
  subnets             = data.aws_subnets.subnets.ids[0]
}

#Call security module to create keys and security groups
module "security" {
  source = "../terraform/modules/security"
  vpc_id = data.aws_vpc.main.id
}

#Create EFS resources
module "efs" {
  source     = "../terraform/modules/efs"
  subnet_id  = data.aws_subnets.subnets.ids[0]
  sec_grp_id = module.security.security_group_id
}