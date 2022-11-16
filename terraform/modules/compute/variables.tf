variable "max_size" {
  type = number
  default = 2
}
variable "min_size" {
  type = number
  default = 1
}
variable "security_group_name" {}
variable "ec2_key_name" {}
variable "efs_id" {}
variable "efs_dns" {}
variable "instance_type" {
  default = "t3.micro"
}

