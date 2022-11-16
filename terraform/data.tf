data "aws_canonical_user_id" "current" {}
data "aws_caller_identity" "current" {}

# Use Existing VPC
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["Main VPC"]
  }
}