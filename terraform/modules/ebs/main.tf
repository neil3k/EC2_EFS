# Declare the data source and grab all available az's
data "aws_availability_zones" "available" {
  state = "available"
}

#Creating EBS file system
resource "aws_ebs_volume" "ebs" {
  for_each          = toset(data.aws_availability_zones.available.names)
  encrypted         = var.encrypted
  availability_zone = each.value
  size              = 20

  tags = {
    Name = var.name
  }
}