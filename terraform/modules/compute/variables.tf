variable "max_size" {
  type = number
  default = 2
}
variable "min_size" {
  type = number
  default = 1
}
variable "desired_capacity" {
  type = number
  default = 1
}
variable "security_group_name" {}
variable "ec2_key_name" {}
variable "instance_type" {
  default = "t3.micro"
}
variable "public_ip" {
  type = bool
  default = true
}
variable "kms_key_arn" {}

