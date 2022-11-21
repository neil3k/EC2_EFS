variable "name" {
  default = "my-ebs"
}

variable "sec_grp_id" {}

variable "encrypted" {
  type = bool
  default = true
}
