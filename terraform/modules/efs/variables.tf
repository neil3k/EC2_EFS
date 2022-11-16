variable "name" {
  default = "my-efs"
}
variable "sec_grp_id" {}
variable "encrypted" {
  type = bool
  default = true
}